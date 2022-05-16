//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i = 0; i < 8; i++) {
            hashes.push(0);
        }

        uint256 n = 8;
        uint256 offset = 0;

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                hashes.push(
                    PoseidonT3.poseidon(
                        [hashes[offset + i], hashes[offset + i + 1]]
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint256 n = 8;
        uint256 offset = 0;
        uint256 k = index;

        while (n > 1) {
            if (k % 2 == 0) {
                hashes[offset + n + k / 2] = PoseidonT3.poseidon(
                    [hashes[offset + k], hashes[offset + k + 1]]
                );
            } else {
                hashes[offset + n + k / 2] = PoseidonT3.poseidon(
                    [hashes[offset + k - 1], hashes[offset + k]]
                );
            }
            offset += n;
            n = n / 2;
            k = k / 2;
        }
        index ++;
        return hashes[offset];
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        require(verifyProof(a, b, c, input));
        // calculate the root of the Merkle tree        
        // (uint256 leaf, uint256[3] memory path_index, uint256[3] memory path_elements) = input;
        // uint n = 3;
        // uint256[4] memory hashi;
        // hashi[0] = leaf;
        // for (uint256 i = 0; i < n; i++) {
        //     hashi[i + 1] = PoseidonT3.poseidon(
        //         [
        //             hashi[i] - path_elements[i] * path_index[i] + path_elements[i],
        //             hashi[i] - path_elements[i] * path_index[i] + path_elements[i]
        //         ]
        //     );
        // }
        // return root == hashi[n];
        // return root == input[0];
        return true;
    }
}

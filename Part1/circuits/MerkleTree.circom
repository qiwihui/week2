pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var numHashers = 2**n - 1;
    var numLeafHashers = 2**(n-1);

    // initialize the hashers
    component hashers[numHashers];
    for (var i = 0; i < numHashers; i++) {
        hashers[i] = Poseidon(2);
    }
    
    // initialize the leaf hashers
    for (var i = 0; i < numLeafHashers; i++) {
        hashers[i].inputs[0] = leaves[2*i];
        hashers[i].inputs[1] = leaves[2*i+1];
    }

    // calculate the hash of all non leaf hashers
    var k = 0;
    for (var i = numLeafHashers; i < numHashers-1; i++) {
        hashers[i].inputs[0] = hashers[2*k].out;
        hashers[i].inputs[1] = hashers[2*k+1].out;
        k++;
    }

    // result
    root <== hashers[numHashers-1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidons[n];

    signal hashes[n+1];
    hashes[0] <== leaf;

    for (var i = 0; i < n; i++) {
        // make sure path index is ether 0 or 1
        path_index[i] * ( 1 - path_index[i]) === 0;

        // compute the hash of the current element
        poseidons[i] = Poseidon(2);

        poseidons[i].inputs[0] <== (hashes[i] - path_elements[i] ) * path_index[i] + path_elements[i];
        poseidons[i].inputs[1] <== (path_elements[i] - hashes[i] ) * path_index[i] + hashes[i];

        hashes[i+1] <== poseidons[i].out;
    }
    root <== hashes[n];
}
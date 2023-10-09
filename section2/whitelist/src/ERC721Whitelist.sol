// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { ERC721, ERC721Enumerable } from "oz/token/ERC721/extensions/ERC721Enumerable.sol";
import "oz/utils/cryptography/MerkleProof.sol";

contract ERC721Whitelist is ERC721Enumerable {

  bytes32 immutable private merkleRoot;
  mapping(address => bool) public claimed;

  constructor(string memory _name, string memory _symbol, bytes32 _merkleRoot) ERC721(_name, _symbol) {
    merkleRoot = _merkleRoot;
  }

  function inWhitelist(bytes32[] memory _merkleProof, address _who) internal view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(_who));
    return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
  }


function mint(bytes32[] memory _merkleProof) external {
    // TODO:
    // 1. Check if the user is in the whitelist
    // 2. Check if the user has already claimed the token
    // 3. Mint the token to the user
    // 4. Mark the user as claimed
  }
}
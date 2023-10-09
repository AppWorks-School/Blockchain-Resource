// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { ERC721Whitelist } from "../src/ERC721Whitelist.sol";
import { Merkle } from "murky/src/Merkle.sol";
import "forge-std/console.sol";

contract ERC721WhitelistTest is Test {

  ERC721Whitelist public whitelist;
  Account public user1 = makeAccount("leaf1");
  Account public user2 = makeAccount("leaf2");
  Account public user3 = makeAccount("leaf3");
  Account public user4 = makeAccount("leaf4");
  Merkle m = new Merkle();

  bytes32[] public leaf;

  function setUp() public {
    leaf = new bytes32[](4);
    leaf[0] = keccak256(abi.encodePacked(user1.addr));
    leaf[1] = keccak256(abi.encodePacked(user2.addr));
    leaf[2] = keccak256(abi.encodePacked(user3.addr));
    leaf[3] = keccak256(abi.encodePacked(user4.addr));

    bytes32 root = m.getRoot(leaf);

    whitelist = new ERC721Whitelist("Whitelist", "WHT", root);
  }
  
  function test_mint() public {
    vm.startPrank(user1.addr);
    uint256 indexInLeaf = 0;
    bytes32[] memory proof = m.getProof(leaf, indexInLeaf);
    whitelist.mint(proof);
    vm.stopPrank();
  }

  function test_mint_fail_with_wrong_index() public {
    // TODO:
    // 1. Prank user1
    // 2. Mint to user1 with wrong index, should revert with "ERC721Whitelist: Invalid proof."
  }

  function test_mint_fail_when_duplicate() public {
    // TODO:
    // 1. Prank user1
    // 2. Mint to user1
    // 3. Mint to user1 again, should revert with "ERC721Whitelist: Already claimed." 
  }
}
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { ERC721 } from 'oz/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract NFTWithRoyalty is ERC721 {

  constructor(address feeReceiver) ERC721("NFTWithRoyalty", "NFTWR") {
    // TODO: set default royalty fee to 1000 (10%)
  }

  function mint(uint256 tokenId) external {
    // TODO: mint token to msg.sender
  }

  function mintWithRoyaltyFee(uint256 tokenId, address feeReceiver) external {
    // TODO: mint token to msg.sender and set royalty fee to feeReceiver
  }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract testERC721 is ERC721 {
  constructor() ERC721("Test erc721", "TEST721") {}

  uint256 public currentIndex;

  function mint(address _to) external {
    _mint(_to, currentIndex);
    currentIndex++;
  }
}
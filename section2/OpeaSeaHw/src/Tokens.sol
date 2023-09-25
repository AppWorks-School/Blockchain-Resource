// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { ERC721 } from "oz/token/ERC721/ERC721.sol";
import { ERC20 } from "oz/token/ERC20/ERC20.sol";

contract NFT is ERC721 {

  uint256 public tokenId;
  constructor() ERC721("FakeNFT", "FNFT") {}

  function mint() public {
    _mint(msg.sender, tokenId++); 
  }
}

contract FT is ERC20 {
  constructor() ERC20("Fungible token", "FT") {}

  function mint(uint256 amount) public {
    _mint(msg.sender, amount);
  }
}


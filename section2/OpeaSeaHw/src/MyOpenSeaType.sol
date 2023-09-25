// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { IERC721 } from "oz/token/ERC721/IERC721.sol";

contract MyOpenSeaType {

  struct Order {
    IERC721 nft;
    uint256 tokenId;
    address seller;
    address paymentToken;
    uint256 price;
    uint256 deadline;
    uint256 nonce;
  }
  
  struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  struct OrderWithSignature {
    Order order;
    Signature signature;
  }

}
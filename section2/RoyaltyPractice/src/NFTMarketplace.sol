// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { IERC721 } from "oz/contracts/token/ERC721/IERC721.sol";
import { IERC2981 } from "oz/contracts/interfaces/IERC2981.sol";

contract NFTMarketplace {

  struct Order {
    bool exist;
    address nft;
    address owner;
    uint256 tokenId;
    uint256 price;
  }

  mapping(bytes32 => Order) public orders;

  function createOrder(address nft, uint256 tokenId, uint256 price) external {
    address owner = IERC721(nft).ownerOf(tokenId);
    require(owner == msg.sender, "Only token owner can create order");
    orders[keccak256(abi.encodePacked(nft, tokenId))] = Order(true, nft, owner, tokenId, price);
  }

  function fillOrder(address nft, uint256 tokenId) external payable {
    bytes32 _hash = keccak256(abi.encodePacked(nft, tokenId));
    require(orders[_hash].exist, "Order does not exist");
    Order memory order = orders[_hash];
    require(msg.value == order.price, "Incorrect price");
    IERC721(order.nft).safeTransferFrom(order.owner, msg.sender, order.tokenId);
    if (IERC2981(order.nft).supportsInterface(type(IERC2981).interfaceId)) {
      (address royaltyReceiver, uint256 royaltyAmount) = IERC2981(order.nft).royaltyInfo(order.tokenId, msg.value);
      payable(royaltyReceiver).transfer(royaltyAmount);
      payable(order.owner).transfer(msg.value - royaltyAmount);
    }
    delete orders[_hash];
  }
}
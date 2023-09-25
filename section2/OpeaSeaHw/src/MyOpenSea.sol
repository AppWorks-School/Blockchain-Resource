// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IERC721 } from "oz/token/ERC721/IERC721.sol";
import { IERC20 } from "oz/token/ERC20/IERC20.sol";
import { ECDSA } from "oz/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "oz/utils/cryptography/MessageHashUtils.sol";
import { SafeERC20 } from "oz/token/ERC20/utils/SafeERC20.sol";
import { MyOpenSeaType } from "./MyOpenSeaType.sol";

contract MyOpenSea is MyOpenSeaType {

  using MessageHashUtils for bytes32;

  mapping (bytes32 => bool) orders;
  mapping (address => uint256) nonce;
  event FulfillOrder(Order order, address buyer);

  function _verifySignature(Order memory order, Signature memory sig) internal pure returns (bool) {
    bytes32 signedMessageHash = keccak256(abi.encode(order)).toEthSignedMessageHash();
    return ECDSA.recover(signedMessageHash, sig.v, sig.r, sig.s) == order.seller;
  }

  function fulfillOrder(OrderWithSignature memory orderWithSig) public payable {
    Order memory order = orderWithSig.order;
    require(_verifySignature(order, orderWithSig.signature), "MyOpenSea: invalid signature");
    require(nonce[order.seller] == order.nonce, "MyOpenSea: invalid nonce");
    require(block.timestamp < order.deadline, "MyOpenSea: order expired");

    if (order.paymentToken == address(0)) {
      require(msg.value == order.price, "MyOpenSea: invalid payment");
      (bool success,) =  payable(order.seller).call{ value: msg.value }("");
      require(success, "MyOpenSea: payment failed");
    } else {
      IERC20 paymentToken = IERC20(order.paymentToken);
      SafeERC20.safeTransferFrom(paymentToken, msg.sender, order.seller, order.price);
    }
    nonce[order.seller]++;
    _executeOrder(order, msg.sender);

    emit FulfillOrder(order, msg.sender);
  }

  function _executeOrder(Order memory order, address sender) internal {
    order.nft.safeTransferFrom(order.seller, sender, order.tokenId);
    bytes32 orderHash = keccak256(abi.encode(order));
    orders[orderHash] = true;
  }
}
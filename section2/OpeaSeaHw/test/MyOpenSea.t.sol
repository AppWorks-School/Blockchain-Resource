// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { MyOpenSea } from "../src/MyOpenSea.sol";
import { MyOpenSeaType } from "../src/MyOpenSeaType.sol";
import { NFT, FT } from "../src/Tokens.sol";
import { ECDSA } from "oz/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "oz/utils/cryptography/MessageHashUtils.sol";
import { IERC721 } from "oz/token/ERC721/IERC721.sol";

contract MyOpenSeaTest is Test, MyOpenSeaType {

  using MessageHashUtils for bytes32;

  Account user1;
  NFT nft;
  FT token;
  MyOpenSea openSea;

  function setUp() public {
    openSea = new MyOpenSea();
    nft = new NFT();
    token = new FT();
    user1 = makeAccount("user1");
    vm.startPrank(user1.addr);
    nft.mint();
    nft.setApprovalForAll(address(openSea), true);
    vm.stopPrank();
  }

  function makeOrder(Account memory user, Order memory order) public pure returns (OrderWithSignature memory orderWithSig) {
    bytes32 digest = keccak256(abi.encode(order)).toEthSignedMessageHash();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.key, digest);
    orderWithSig = OrderWithSignature(order, Signature(v, r, s));
  }

  function testEthTrade() public {
    Order memory order = Order(
      IERC721(nft),
      0,
      user1.addr,
      address(0),
      1 ether,
      block.timestamp + 1 days,
      0
    );
    OrderWithSignature memory fullOrder = makeOrder(user1, order);

    Account memory user2 = makeAccount("user2");
    vm.deal(user2.addr, 100 ether);
    vm.prank(user2.addr);
    openSea.fulfillOrder{ value: 1 ether }(fullOrder);
  }

  function testErc20Trade() public {
    
    Order memory order = Order(
      IERC721(nft),
      0,
      user1.addr,
      address(token),
      100 * 10 ** token.decimals(),
      block.timestamp + 1 days,
      0
    );
    OrderWithSignature memory fullOrder = makeOrder(user1, order);

    Account memory user2 = makeAccount("user2");
    vm.startPrank(user2.addr);
    token.mint(100 * 10 ** token.decimals());
    token.approve(address(openSea), 100 * 10 ** token.decimals());
    openSea.fulfillOrder(fullOrder);
    vm.stopPrank();
  }
} 
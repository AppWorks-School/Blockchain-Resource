// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { NFTWithRoyalty } from "../src/NFTWithRoyalty.sol";
import { NFTMarketplace } from "../src/NFTMarketplace.sol";
import "forge-std/console.sol";

contract NFTWithRoyaltyTest is Test {

  NFTWithRoyalty nft;
  NFTMarketplace marketplace;

  Account defaultFeeReciever = makeAccount("defaultFeeReciever");
  Account customFeeReceiver = makeAccount("customFeeReceiver");
  Account maker = makeAccount("maker");
  Account taker = makeAccount("taker");

  uint256 tokenIdForMaker = 1;
  uint256 tokenIdForCustomFeeReceiver = 10000;

  function setUp() public {
    vm.deal(taker.addr, 100 ether);
    
    nft = new NFTWithRoyalty(defaultFeeReciever.addr);
    marketplace = new NFTMarketplace();

    vm.startPrank(maker.addr);
    nft.mint(tokenIdForMaker);
    nft.mintWithRoyaltyFee(tokenIdForCustomFeeReceiver, customFeeReceiver.addr);
    nft.setApprovalForAll(address(marketplace), true);
    vm.stopPrank();
  }

  function test_default_fee_receiver() public {

    uint256 listingPrice = 1 ether;

    vm.prank(maker.addr);
    marketplace.createOrder(address(nft), tokenIdForMaker, listingPrice);

    vm.prank(taker.addr);
    marketplace.fillOrder{value: listingPrice}(address(nft), tokenIdForMaker);

    uint256 royaltyAmount = listingPrice * 1000 / 10000;

    assertEq(nft.ownerOf(tokenIdForMaker), taker.addr);
    assertEq(defaultFeeReciever.addr.balance, royaltyAmount);
    assertEq(maker.addr.balance, listingPrice - royaltyAmount);
  }

  function test_custom_fee_receiver() public {

    uint256 listingPrice = 10 ether;

    vm.prank(maker.addr);
    marketplace.createOrder(address(nft), tokenIdForCustomFeeReceiver, listingPrice);

    vm.prank(taker.addr);
    marketplace.fillOrder{value: listingPrice}(address(nft), tokenIdForCustomFeeReceiver);

    uint256 royaltyAmount = listingPrice * 1000 / 10000;

    assertEq(nft.ownerOf(tokenIdForCustomFeeReceiver), taker.addr);
    assertEq(customFeeReceiver.addr.balance, royaltyAmount);
    assertEq(maker.addr.balance, listingPrice - royaltyAmount);
  }
}
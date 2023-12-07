// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { EIP20Interface } from "compound-protocol/contracts/EIP20Interface.sol";
import { CErc20 } from "compound-protocol/contracts/CErc20.sol";
import "test/helper/CompoundPracticeSetUp.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";

interface IBorrower {
  function borrow() external;
}

contract CompoundPracticeTest is CompoundPracticeSetUp {
  EIP20Interface public USDC = EIP20Interface(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  address public user;

  IBorrower public borrower;

  function setUp() public override {
    super.setUp();

    // Deployed in CompoundPracticeSetUp helper
    borrower = IBorrower(borrowerAddress);
    vm.makePersistent(address(borrower));
    vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/RT3UW2hCYor5k6FJBIqMx5hm3sgdhKwm");

    user = makeAddr("User");  

    uint256 initialBalance = 10000 * 10 ** USDC.decimals();
    deal(address(USDC), user, initialBalance);

    vm.label(address(cUSDC), "cUSDC");
    vm.label(borrowerAddress, "Borrower");
  }

  function test_compound_mint_interest() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC

    uint256 mintedAmount = 100 * 10 ** USDC.decimals();
    USDC.approve(address(cUSDC), mintedAmount);
    uint256 mintCode = cUSDC.mint(mintedAmount);

    assertEq(mintCode, 0);

    // TODO: 2. Modify block state to generate interest
    vm.roll(block.number + 100);

    // TODO: 3. Redeem and check the redeemed amount
    uint256 redeemCode = cUSDC.redeem(cUSDC.balanceOf(user));
    assertEq(redeemCode, 0);

    assertGt(USDC.balanceOf(user), mintedAmount);
  }

  function test_compound_mint_interest_with_borrower() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC
    uint256 mintedAmount = 100 * 10 ** USDC.decimals();
    USDC.approve(address(cUSDC), mintedAmount);
    uint256 mintCode = cUSDC.mint(mintedAmount);

    assertEq(mintCode, 0);


    // 2. Borrower contract will borrow some USDC
    borrower.borrow();

    // TODO: 3. Modify block state to generate interest
     vm.roll(block.number + 100);

    // TODO: 4. Redeem and check the redeemed amount
    uint256 redeemCode = cUSDC.redeem(cUSDC.balanceOf(user));
    assertEq(redeemCode, 0);

    assertGt(USDC.balanceOf(user), mintedAmount);
  }

  function test_compound_mint_interest_with_borrower_advanced() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC
    uint256 mintedAmount = 100 * 10 ** USDC.decimals();
    USDC.approve(address(cUSDC), mintedAmount);
    uint256 mintCode = cUSDC.mint(mintedAmount);

    assertEq(mintCode, 0);

    address anotherBorrower = makeAddr("Another Borrower");
    // TODO: 2. Borrow some USDC with another borrower
    uint256 borrowAmount = 50 * 10 ** USDC.decimals();
    
    vm.startPrank(anotherBorrower);

    EIP20Interface Dai = EIP20Interface(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    CErc20 cDai = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

    deal(address(Dai),anotherBorrower ,borrowAmount);
    Dai.approve(address(cDai), borrowAmount);

    uint256 borrowCode = cDai.mint(borrowAmount);
    assertEq(borrowCode, 0);

    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address[] memory cTokens = new address[](1);
    cTokens[0] = address(cDai);
    troll.enterMarkets(cTokens);

    // TODO: 3. Modify block state to generate interest
    vm.roll(block.number + 1000);

    // TODO: 4. Redeem and check the redeemed amount
    vm.startPrank(user); 
    uint256 redeemCode = cUSDC.redeem(cUSDC.balanceOf(user));
    assertEq(redeemCode, 0);

    // console.log(USDC.balanceOf(user));
    // console.log(mintedAmount);

    assertGt(USDC.balanceOf(user), mintedAmount);
  }

  function test_compound_mint_interest_with_borrower_advanced() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC


    address anotherBorrower = makeAddr("Another Borrower");
    // TODO: 2. Borrow some USDC with another borrower
    // vm.startPrank(anotherBorrower);

    // TODO: 3. Modify block state to generate interest


    // TODO: 4. Redeem and check the redeemed amount
    // vm.startPrank(user); 
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/console.sol";
import { EIP20Interface } from "compound-protocol/contracts/EIP20Interface.sol";
import { CErc20 } from "compound-protocol/contracts/CErc20.sol";
import "test/helper/CompoundPracticeSetUp.sol";

interface IBorrower {
  function borrow() external;
}

contract CompoundPracticeTest is CompoundPracticeSetUp {
  EIP20Interface public USDC = EIP20Interface(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  address public user;

  IBorrower public borrower;

  function setUp() public override {
    uint256 forkId = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/-CmqkVjFZ7gnwUdbfGpt_dasLBkBR1ds");
    vm.selectFork(forkId);

    super.setUp();

    // Deployed in CompoundPracticeSetUp helper
    borrower = IBorrower(borrowerAddress);

    user = makeAddr("User");  

    uint256 initialBalance = 10000 * 10 ** USDC.decimals();
    deal(address(USDC), user, initialBalance);

    vm.label(address(cUSDC), "cUSDC");
    vm.label(borrowerAddress, "Borrower");
  }

  function test_compound_mint_interest() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC
    uint balance0 = USDC.balanceOf(user);
    console.log(balance0);
    USDC.approve(address(cUSDC), 10000 * 10 ** USDC.decimals());
    assertEq(cUSDC.mint(10000 * 10 ** USDC.decimals()), 0);

    // TODO: 2. Modify block state to generate interest
    vm.roll(block.number + 100);

    // TODO: 3. Redeem and check the redeemed amount
    assertEq(cUSDC.redeem(cUSDC.balanceOf(user)), 0);
    uint balance1 = USDC.balanceOf(user);
    console.log(balance1);
    assertGt(balance1, balance0);
  }

  function test_compound_mint_interest_with_borrower() public {
    vm.startPrank(user); 
    // TODO: 1. Mint some cUSDC with USDC
    uint balance0 = USDC.balanceOf(user);
    console.log(balance0);
    USDC.approve(address(cUSDC), 10000 * 10 ** USDC.decimals());
    assertEq(cUSDC.mint(10000 * 10 ** USDC.decimals()), 0);

    // 2. Borrower.borrow() will borrow some USDC
    borrower.borrow();

    // TODO: 3. Modify block state to generate interest
    vm.roll(block.number + 100);

    // TODO: 4. Redeem and check the redeemed amount
    assertEq(cUSDC.redeem(cUSDC.balanceOf(user)), 0);
    uint balance1 = USDC.balanceOf(user);
    console.log(balance1);
    assertGt(balance1, balance0);
  }
}

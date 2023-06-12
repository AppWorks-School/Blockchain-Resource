// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BalanceChecker.sol";
import "../src/AaveFlashLoan.sol";

contract AaveFlashLoanTest is Test {
  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  BalanceChecker public checker;
  AaveFlashLoan public aaveFlashLoan;

  function setUp() public {
    string memory rpc = vm.envString("MAINNET_RPC_URL");
    vm.createSelectFork(rpc);

    checker = new BalanceChecker();
    aaveFlashLoan = new AaveFlashLoan();

    uint256 initialBalance = 50_000 * 10 ** 6;
    deal(USDC, address(aaveFlashLoan), initialBalance);

    vm.label(address(checker), "BalanceChecker");
    vm.label(address(aaveFlashLoan), "Flash Loan");
  } 

  function testAaveFlashLoan() public {
    assertEq(checker.pass(), false);

    aaveFlashLoan.execute(checker);

    assertEq(checker.pass(), true);
  }
}

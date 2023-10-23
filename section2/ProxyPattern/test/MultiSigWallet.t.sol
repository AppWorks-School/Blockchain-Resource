// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { testERC20 } from "../src/test/testERC20.sol";
import { testERC721 } from "../src/test/testERC721.sol";
import { MultiSigWallet } from "../src/MultiSigWallet/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  MultiSigWallet public wallet;

  testERC20 public erc20;
  testERC721 public erc721;

  function setUp() public {
    vm.prank(admin);
    wallet = new MultiSigWallet([alice, bob, carol]);
    vm.deal(address(wallet), 100 ether);

    erc20 = new testERC20();
    erc721 = new testERC721();
  }

  function test_submitTransaction() public {
    // 1. prank as one of the owner
    vm.startPrank(alice);
    // 2. form a transfer transaction
    wallet.submitTransaction(bob, 10 ether, "");
    vm.stopPrank();
    
    // 3. check the transaction is submitted
    (address to, uint256 value, bytes memory data,,)= wallet.transactions(0);
    assertEq(to, bob);
    assertEq(value, 10 ether);
    assertEq(data.length, 0);
  }

  function test_confirmTransaction() public {
    // 1. prank as one of the owner
    vm.startPrank(alice);
    // 2. form a transfer transaction
    wallet.submitTransaction(bob, 10 ether, "");
    vm.stopPrank();
    // 3. bob confirm the transaction
    vm.prank(bob);
    wallet.confirmTransaction();

    // 4. check the transaction is confirmed
    assertEq(wallet.isConfirmed(0, bob), true); 
  }

  function test_executeTransaction() public {
    // 1. prank as one of the owner
    vm.startPrank(alice);
    // 2. form a transfer transaction
    wallet.submitTransaction(bob, 10 ether, "");
    vm.stopPrank();
    // 3. bob confirm the transaction
    vm.prank(bob);
    wallet.confirmTransaction();
    // 4. carol confirm the transaction
    vm.prank(carol);
    wallet.confirmTransaction();

    // 5. execute the transaction
    vm.prank(alice);
    wallet.executeTransaction();

    // 6. check the transaction is executed
    (,,,bool executed,) = wallet.transactions(0);
    assertEq(executed, true);
    assertEq(bob.balance, 10 ether);
    assertEq(address(wallet).balance, 90 ether);
  }

  function test_mint_erc20() public {
    // 1. prank as one of the owner
    vm.startPrank(alice);
    // 2. form a transfer transaction
    bytes memory mintERC20 = abi.encodeWithSelector(testERC20.mint.selector, address(wallet), 10 ether);
    wallet.submitTransaction(address(erc20), 0, mintERC20);
    vm.stopPrank();

    // 3. bob confirm the transaction
    vm.prank(bob);
    wallet.confirmTransaction();

    // 4. carol confirm the transaction
    vm.prank(carol);
    wallet.confirmTransaction();

    // 5. execute the transaction
    vm.prank(alice);
    wallet.executeTransaction();

    // 6. check the transaction is executed
    (,,,bool executed,) = wallet.transactions(0);
    assertEq(executed, true);
    assertEq(erc20.balanceOf(address(wallet)), 10 ether);
  }

  function test_mint_erc721() public {
    // 1. prank as one of the owner
    vm.startPrank(alice);
    // 2. form a transfer transaction
    bytes memory mintERC721 = abi.encodeWithSelector(testERC721.mint.selector, address(wallet));
    wallet.submitTransaction(address(erc721), 0, mintERC721);
    vm.stopPrank();

    // 3. bob confirm the transaction
    vm.prank(bob);
    wallet.confirmTransaction();

    // 4. carol confirm the transaction
    vm.prank(carol);
    wallet.confirmTransaction();

    // 5. execute the transaction
    vm.prank(alice);
    wallet.executeTransaction();

    // 6. check the transaction is executed
    (,,,bool executed,) = wallet.transactions(0);
    assertEq(executed, true);
    assertEq(erc721.balanceOf(address(wallet)), 1);
  }
}
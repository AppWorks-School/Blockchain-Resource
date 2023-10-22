// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { testERC20 } from "../src/test/testERC20.sol";
import { testERC721 } from "../src/test/testERC721.sol";
import { MultiSigWallet } from "../src/MultiSigWallet/MultiSigWallet.sol";
// import { BasicProxy } from "../src/BasicProxy.sol";
import { BasicProxy } from "../src/Answers/BasicProxy.ans.sol";

contract BasicProxyTest is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  MultiSigWallet public wallet;
  BasicProxy public proxy;
  MultiSigWallet public proxyWallet;

  testERC20 public erc20;
  testERC721 public erc721;

  function setUp() public {
    vm.prank(admin);
    wallet = new MultiSigWallet([alice, bob, carol]);
    proxy = new BasicProxy(address(wallet));
    proxyWallet = MultiSigWallet(address(proxy));

    erc20 = new testERC20();
    erc721 = new testERC721();
  }

  function test_updateOwner() public {
    address one = address(0x1);
    proxyWallet.updateOwner(1, one);
    assertEq(proxyWallet.owner1(), one);
  }

}
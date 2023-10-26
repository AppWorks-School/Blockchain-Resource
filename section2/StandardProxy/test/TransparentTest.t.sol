// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Test, console } from "forge-std/Test.sol";
import { Transparent } from "../src/Transparent.sol";
import { MultiSigWallet, MultiSigWalletV2 } from "../src/MultiSigWallet/MultiSigWalletV2.sol";

interface ITransparentUpgradeableProxy {
  function upgradeToAndCall(address newImplementation, bytes memory data) external;
}

contract TransparentTest is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  Transparent proxy;
  MultiSigWallet wallet;
  MultiSigWalletV2 walletV2;
  MultiSigWallet proxyWallet;
  MultiSigWalletV2 proxyWalletV2;

  function setUp() public {
    vm.startPrank(admin);
    wallet = new MultiSigWallet();
    walletV2 = new MultiSigWalletV2();
    proxy = new Transparent(
      address(wallet),
      abi.encodeWithSelector(wallet.initialize.selector, [alice, bob, carol])
    );
    vm.stopPrank();
  }

  function test_transparent_upgradeToAndCall_success() public {
    // TODO:
    // 1. check if proxy is correctly proxied,  assert that proxyWallet.VERSION() is "0.0.1"
    // 2. assert if user call upgradeToAndCall will revert
    // 3. upgrade to V2
    // 4. assert user call upgradeToAndCall will return "23573451"
  }
}
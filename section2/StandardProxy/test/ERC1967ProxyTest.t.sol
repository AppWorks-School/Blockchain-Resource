// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Test, console } from "forge-std/Test.sol";
import { ERC1967Proxy } from "../src/ERC1967Proxy.sol";
import { UpgradeableProxy } from "../src/UpgradeableProxy.sol";
import { MultiSigWallet, MultiSigWalletV2 } from "../src/MultiSigWallet/MultiSigWalletV2.sol";

contract ERC1967ProxyTest is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  ERC1967Proxy proxy;
  MultiSigWallet wallet;
  MultiSigWalletV2 walletV2;
  MultiSigWallet proxyWallet;
  MultiSigWalletV2 proxyWalletV2;

  function setUp() public {
    vm.startPrank(admin);
    wallet = new MultiSigWallet();
    walletV2 = new MultiSigWalletV2();
    proxy = new ERC1967Proxy(
      address(wallet),
      abi.encodeWithSelector(wallet.initialize.selector, [alice, bob, carol])
    );
    vm.stopPrank();
  }

  function test_storage_collision_on_upgradeProxy() public {
    UpgradeableProxy upgradeProxy;
    upgradeProxy = new UpgradeableProxy(
      address(wallet),
      abi.encodeWithSelector(wallet.initialize.selector, [alice, bob, carol])
    );
    vm.expectRevert();
    MultiSigWallet(address(upgradeProxy)).VERSION();
  }

  function test_ERC1967_avoid_storage_collision() public {
    // TODO:
    // 1. check if proxy is correctly proxied,  assert that proxyWallet.VERSION() is "0.0.1"
    // 2. test upgradeToAndCall won't result in storage collision
    // 3. assert contract is updated
  }

  function test_ERC1967_onlyAdmin_can_upgrade() public {
    // TODO: test if only admin could upgrade this proxy
  }

  function test_call_upgradeToAndCall_23573451() public {
    // TODO:
    // 1. upgrade to V2 and initiliaze
    // 2. test if you could call upgradeToAndCall_23573451()
  }
}
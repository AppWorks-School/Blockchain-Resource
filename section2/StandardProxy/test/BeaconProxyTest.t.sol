// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Test, console } from "forge-std/Test.sol";
import { BeaconProxy } from "../src/BeaconProxy/BeaconProxy.sol";
import { UpgradeableBeacon } from "../src/BeaconProxy/UpgradeableBeacon.sol";
import { UpgradeableProxy } from "../src/UpgradeableProxy.sol";
import { MultiSigWallet, MultiSigWalletV2 } from "../src/MultiSigWallet/MultiSigWalletV2.sol";

contract BeaconProxyTest is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  BeaconProxy proxy1;
  BeaconProxy proxy2;
  BeaconProxy proxy3;
  UpgradeableBeacon beacon;

  MultiSigWallet wallet;
  MultiSigWalletV2 walletV2;
  MultiSigWallet proxyWallet;
  MultiSigWalletV2 proxyWalletV2;

  function setUp() public {
    vm.startPrank(admin);

    wallet = new MultiSigWallet();
    walletV2 = new MultiSigWalletV2();
    beacon = new UpgradeableBeacon(address(wallet));
    proxy1 = new BeaconProxy(address(beacon));
    proxy2 = new BeaconProxy(address(beacon));
    proxy3 = new BeaconProxy(address(beacon));

    vm.stopPrank();
  }

  function test_BeaconProxy_upgradeTo() public {
    // TODO:
    // 1. check if proxy is correctly proxied,  assert that proxyWallet.VERSION() is "0.0.1", both with proxy1, proxy2, proxy3
    // 2. upgrade beacon implementation
    // 3. check if proxy is correctly proxied,  assert that proxyWallet.VERSION() is "0.0.2", both with proxy1, proxy2, proxy3
  }
}
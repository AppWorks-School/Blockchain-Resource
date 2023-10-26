// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Test, stdStorage, StdStorage } from "forge-std/Test.sol";
import { SlotsManipulate } from "../src/utils/Slots.sol";

contract SlotManipulateTest is Test {

  using stdStorage for StdStorage;

  address randomAddress;
  SlotsManipulate instance;

  function setUp() public {
    instance = new SlotsManipulate();
  }

  function bytes32ToAddress(bytes32 _bytes32) internal pure returns (address) {
    return address(uint160(uint256(_bytes32)));
  }

  function testValueSet() public {
    // TODO:
    // 1. set bytes32(keccak256("appwork.week8")) to 2023_4_27

    // 2. Assert that the value is set 
    // assertEq(
    //   uint256(vm.load(address(instance), keccak256("appworks.week8"))),
    //   2023_4_27
    // );
  }

  function testSetProxyImplementation() public {
    // TODO:
    // 1. set Proxy Implementation address
    // 2. assert that value is set 
  }

  function testSetBeaconImplementation() public {
    // TODO:
    // 1. set Beacon Implementation address
    // 2. assert that value is set 
  }

  function testSetAdminImplementation() public {
    // TODO:
    // 1. set admin address
    // 2. assert that value is set 
  }

  function testSetProxiableImplementation() public {
    // TODO:
    // 1. set Proxiable address
    // 2. assert that value is set 
  }

}
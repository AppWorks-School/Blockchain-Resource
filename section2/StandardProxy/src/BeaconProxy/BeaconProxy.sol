// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IBeacon } from "./IBeacon.sol";
import { Slots } from "../utils/Slots.sol";
import { Proxy } from "../utils/Proxy.sol";

contract BeaconProxy is Slots, Proxy {

  bytes32 constant BEACON_SLOT = bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1);

  constructor(address _beacon) {
    _setSlotToAddress(BEACON_SLOT, _beacon);
  }

  function _getBeacon() internal view returns (address) {
    return _getSlotToAddress(BEACON_SLOT);
  }

  function _implemenation() internal view returns (address) {
    return IBeacon(_getBeacon()).implementation();
  }

  fallback() external payable {
    _delegate(_implemenation());
  }
}
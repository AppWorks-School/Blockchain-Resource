// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Slots } from "../utils/Slots.sol";
import { Proxy } from "../utils/Proxy.sol";

contract UpgradeableBeacon is Slots, Proxy {

  bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  constructor(address _impl) {
    _setSlotToAddress(ADMIN_SLOT, msg.sender);
    _setSlotToAddress(IMPLEMENTATION_SLOT, _impl);
  }

  modifier onlyAdmin {
    require(msg.sender == _getSlotToAddress(ADMIN_SLOT), "only admin");
    _;
  }

  function upgradeTo(address newImplementation) external onlyAdmin {
    _setSlotToAddress(IMPLEMENTATION_SLOT, newImplementation);
  }

  function implementation() external view returns (address) {
    return _getSlotToAddress(IMPLEMENTATION_SLOT);
  }  
}
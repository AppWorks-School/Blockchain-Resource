// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Slots } from "../utils/Slots.sol";
import { Proxy } from "../utils/Proxy.sol";

contract UpgradeableBeacon is Slots, Proxy {

  bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  constructor(address _impl) {
    // TODO:
    // 1. set admin owner address at ADMIN_SLOT
    // 2. set implementation address at IMPLEMENTATION_SLOT
  }

  modifier onlyAdmin {
    // TODO:
    // 1. check if msg.sender is equal to admin owner address, if no then revert with Message "only admin"
    _;
  }

  function upgradeTo(address newImplementation) external onlyAdmin {
    // TODO: set implementation address at IMPLEMENTATION_SLOT
  }

  function implementation() external view returns (address) {
    // TODO: return implementation address
  }  
}
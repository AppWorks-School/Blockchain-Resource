// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Slots } from "./utils/Slots.sol";
import { Proxy } from "./utils/Proxy.sol";

contract ERC1967Proxy is Slots, Proxy {

  constructor(address _impl, bytes memory _data) {
    // TODO:
    // 1. set the implementation address at bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    // 2. set admin owner address at bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    // 3. if data exist, then initialize proxy with _data
  }

  function implementation() public view returns (address impl) {
    // TODO: return the implementation address
  }

  modifier onlyAdmin {
    // TODO: check if msg.sender is equal to admin owner address
    _;
  }

  function upgradeToAndCall(address newImplementation, bytes memory _data) external onlyAdmin {
    // TODO:
    // 1. upgrade the implementation address
    // 2. initialize proxy, if data exist, then initialize proxy with _data
  }

  fallback() external payable virtual {
    _delegate(implementation());
  }

  receive() external payable {
    _delegate(implementation());
  }
}
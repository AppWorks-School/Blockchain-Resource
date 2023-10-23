// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy.sol";
import { Ownable } from "./Ownable.sol";

contract UpgradeableProxy is Proxy, Ownable {

  bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  constructor(address _implementation) {
    _setImpl(_implementation);
    initializeOwnable(msg.sender);
  }

  function implementation() public view returns (address impl) {
    assembly {
      impl := sload(_IMPLEMENTATION_SLOT)
    }
  }

  function _setImpl(address _newImpl) internal {
    assembly {
      sstore(_IMPLEMENTATION_SLOT, _newImpl)
    }
  }

  function upgradeTo(address _implementation) external onlyOwner {
    _setImpl(_implementation);
  }

  fallback() external payable {
    _delegate(implementation());
  }

  receive() external payable {}
}
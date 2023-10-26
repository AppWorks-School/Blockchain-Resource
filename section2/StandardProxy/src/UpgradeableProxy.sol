// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Proxy } from "./utils/Proxy.sol";

contract UpgradeableProxy is Proxy {

  address impl;
  address admin;

  constructor(address _impl, bytes memory _data) payable {
    admin = msg.sender;
    impl = _impl;
    if (_data.length > 0) {
      (bool success, ) = impl.delegatecall(_data);
      require(success, "init failed");
    }
  }

  modifier onlyAdmin {
    require(msg.sender == admin, "only admin");
    _; 
  }

  function upgradeToAndCall(address _impl, bytes calldata _data) external payable onlyAdmin {
    impl = _impl;
    (bool success, ) = impl.delegatecall(_data);
    require(success, "init failed");
  }
}
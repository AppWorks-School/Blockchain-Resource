// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy.sol";

contract UpgradeableProxy is Proxy {
  // TODO:
  // 1. inherit or copy the code from BasicProxy
  // 2. add upgradeTo function to upgrade the implementation contract
  // 3. add upgradeToAndCall, which upgrade the implemnetation contract and call the init function again
}
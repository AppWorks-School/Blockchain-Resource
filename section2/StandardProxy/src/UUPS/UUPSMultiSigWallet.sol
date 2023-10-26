// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { MultiSigWallet } from "../MultiSigWallet/MultiSigWallet.sol";
import { Slots } from "../utils/Slots.sol";
import { Proxiable } from "./Proxiable.sol";

contract UUPSMultiSigWallet is Slots, MultiSigWallet, Proxiable {

  function proxiableUUID() public pure returns (bytes32) {
    return bytes32(keccak256("PROXIABLE"));
  }

  function updateCodeAddress(address newImplementation, bytes memory data) external onlyAdmin {
    // TODO:
    // 1. check if newimplementation is compatible with proxiable
    // 2. update the implementation address
    // 3. initialize proxy, if data exist, then initialize proxy with _data
  }
}
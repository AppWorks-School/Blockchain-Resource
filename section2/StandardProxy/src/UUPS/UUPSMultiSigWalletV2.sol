
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { MultiSigWalletV2 } from "../MultiSigWallet/MultiSigWalletV2.sol";
import { Slots } from "../utils/Slots.sol";
import { Proxiable } from "./Proxiable.sol";

contract UUPSMultiSigWalletV2 is Slots, MultiSigWalletV2, Proxiable {

  function proxiableUUID() external pure returns (bytes32) {
    return bytes32(keccak256("PROXIABLE"));
  }
}
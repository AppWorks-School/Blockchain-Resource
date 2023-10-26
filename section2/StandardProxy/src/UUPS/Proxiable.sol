// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Proxiable {
  function proxiableUUID() external pure returns (bytes32);
}
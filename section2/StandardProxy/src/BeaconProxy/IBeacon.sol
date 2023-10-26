// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IBeacon {
  function implementation() external view returns (address); 
}
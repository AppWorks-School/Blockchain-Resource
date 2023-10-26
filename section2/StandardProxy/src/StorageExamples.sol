// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

// 1. Gap the storage contract
contract LogicGapExample {
  uint256[50] private __gap;
  uint256 public normaldata1;
  uint256 public normaldata2;
  bytes32 public normaldata3;
}

// 2. Inherit the storage contract
//    Both logic contract and storage contract inherit this storage contract
contract CommonStorageExample {
  address public implementation;
  address public admin;
}

// 3. Logic contract inherit the storage contract to store data
contract EternalStorage {
  mapping(bytes32 => uint256) internal uintStorage;
  mapping(bytes32 => string) internal stringStorage;
  mapping(bytes32 => address) internal addressStorage;
  mapping(bytes32 => bytes) internal bytesStorage;
  mapping(bytes32 => bool) internal boolStorage;
  mapping(bytes32 => int256) internal intStorage;
}
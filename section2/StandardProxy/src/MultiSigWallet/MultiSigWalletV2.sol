// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { MultiSigWallet } from "./MultiSigWallet.sol";

contract MultiSigWalletV2 is MultiSigWallet {

  bool public v2Initialized;

  function VERSION() external view virtual override returns (string memory) {
    return "0.0.2";
  }

  function v2Initialize() external {
    require(!v2Initialized, "already initialized");
    v2Initialized = true;
  }

  function cancelTransaction() external onlyOwner {
    require(v2Initialized, "not initialized");
    delete transactions[transactions.length - 1];
  }

  function upgradeToAndCall_23573451() external pure returns (string memory) {
    return "23573451";
  }

}
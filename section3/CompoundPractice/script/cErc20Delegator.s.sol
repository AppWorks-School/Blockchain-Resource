// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";

contract cErc20Delegator is Script {
    // cErc20Delegator constuctor
    cErc20Delegator = new CErc20Delegator(
        underlying_,
        comptroller_,
        interestRateModel_,
        initialExchangeRateMantissa_,
        name_,
        symbol_,
        decimals_,
        admin_,
        implementation_,
        becomeImplementationData
    );
}
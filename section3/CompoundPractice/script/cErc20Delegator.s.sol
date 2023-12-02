// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";

contract cErc20Delegator is Script {
    function run() {
        vm.startBroadcast();

        // 1. Deploy a underlying ERC20 contract
        // 2. Deploy Comptroller
            // 2.1 Deploy Comptroller Implementation contract (Comptroller)
            // 2.2 Deploy Comptroller Proxy contract (Unitroller)
            // 2.3 Set Implentation contract address
            // 2.4 Change brain (Proxy address) for Comptroller using _become function
            // 2.5 Set Price Oracle
        // 3. Deploy InterestRateModel
        // 4. initialExchangeRateMantissa_ -> 1e18
        // 5. name_ -> ctoken name
        // 6. symbol_ -> ctoken symbol
        // 7. decimals_ -> 18
        // 8. admin_ -> address(this)
        // 9. implementation_ -> CErc20Delegate
        // 10. becomeImplementationData -> unused, 0x

        // cErc20Delegator = new CErc20Delegator(
        //     underlying_,
        //     comptroller_,
        //     interestRateModel_,
        //     initialExchangeRateMantissa_,
        //     name_,
        //     symbol_,
        //     decimals_,
        //     admin_,
        //     implementation_,
        //     becomeImplementationData
        // );

        vm.stopBroadcast();
    }
}
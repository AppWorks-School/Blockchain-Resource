// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
import "compound-protocol/contracts/PriceOracle.sol";
import "contracts/MyToken.sol";

contract CompoundDelegator is Script {
    address underlying_;
    Comptroller comptroller_;
    InterestRateModel interestRateModel_;
    uint initialExchangeRateMantissa_;
    string name_;
    string symbol_;
    uint8 decimals_;
    address payable admin_;
    address implementation_;
    bytes becomeImplementationData;
    ERC20 public UL;
    CErc20Delegator public cUL;

    function run() public {
        vm.startBroadcast();

        // 1. Deploy a underlying ERC20 contract
        UL = new MyToken("underlying ERC20 token", "UL");
        underlying_ = address(UL);
        // 2. Deploy Comptroller
            // 2.1 Deploy Comptroller Implementation contract (Comptroller)
            Comptroller comptroller = new Comptroller();
            // 2.2 Deploy Comptroller Proxy contract (Unitroller)
            Unitroller unitroller = new Unitroller();
            // 2.3 Set Implentation contract address
            uint errorCode = unitroller._setPendingImplementation(address(comptroller));
            require(errorCode == 0, "Set Implementation Failed");
            // 2.4 Change brain (Proxy address) for Comptroller using _become function
            comptroller._become(unitroller);
            // 2.5 Set Price Oracle
            SimplePriceOracle simplePriceOracle = new SimplePriceOracle();
            comptroller_ = Comptroller(address(unitroller));
            comptroller_._setPriceOracle(PriceOracle(simplePriceOracle));
        // 3. Deploy InterestRateModel -> WhitePaperInterestRateModel, rate = 0%
            WhitePaperInterestRateModel interestRateModel = new WhitePaperInterestRateModel(0, 0);
            interestRateModel_ = InterestRateModel(address(interestRateModel));
        // 4. initialExchangeRateMantissa_ -> 1e18
            initialExchangeRateMantissa_ = 1 ether;
        // 5. name_ -> ctoken name
            name_ = "compound underlying ERC20 token";
        // 6. symbol_ -> ctoken symbol
            symbol_ = "cUL";
        // 7. decimals_ -> 18
            decimals_ = 18;
        // 8. admin_ -> address(this)
            admin_ = payable(address(this));
        // 9. implementation_ -> CErc20Delegate
            CErc20Delegate cErc20Delegate = new CErc20Delegate();
            implementation_ = address(cErc20Delegate);
        // 10. becomeImplementationData -> unused, 0x00
            becomeImplementationData = new bytes(0x00);

        cUL = new CErc20Delegator(
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

        vm.stopBroadcast();
    }
}
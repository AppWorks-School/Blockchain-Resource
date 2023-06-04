// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "contracts/Underlying.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import "compound-protocol/contracts/ComptrollerInterface.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/Unitroller.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
import "compound-protocol/contracts/PriceOracle.sol";

/* 
    According to CErc20Delegator constructor :
    constructor(
        address underlying_,
        ComptrollerInterface comptroller_,
        InterestRateModel interestRateModel_,
        uint initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address payable admin_,
        address implementation_,
        bytes memory becomeImplementationData)
    
    we need to prepare
        1. underlying_ -> an ERC20 contract (decimals = 18)         ok
            1.1 contracts/Underlying.sol
        2. Comptroller -> Unitroller                                ok
            2.1 admin create comptroller and unitroller
            2.2 admin call unitroller._setPendingImplementation(address comptroller) -> check error code == 0
            2.3 admin call comptroller._become(unitroller)
        3. InterestRateModel -> use WhitePaperInterestRateModel     ok
            3.1 WhitePaperInterestRateModel constructor :
                constructor(uint baseRatePerYear, uint multiplierPerYear) 
            3.2 利率模型合約中的借貸利率設定為 0% 
                baseRatePerYear -> 0, multiplierPerYear -> 0
        4. initialExchangeRateMantissa_ = 1e18                      ok
        5. name_ -> ctoken name                                     ok
        6. symbol_ -> ctoken symbol                                 ok
        7. decimals_ -> 18                                          ok
        8. admin_ -> use address(this)                              ok
        9. implementation_ -> CErc20Delegate                        ok
            9.1 new a CErc20Delegate
            9.2 use the address of CErc20Delegate as argument
        10. becomeImplementationData -> currently unused            ok
        11. use SimplePriceOracle as Oracle                         ok
            11.1 new SimplePriceOracle
            11.2 unitroller._setPriceOracle(PriceOracle(SimplePriceOracle))
*/

contract CompoundDelegator is  Script {
    // CErc20Delegator constructor's arguments
    address underlying_;
    ComptrollerInterface comptroller_;
    InterestRateModel interestRateModel_;
    uint initialExchangeRateMantissa_;
    string name_;
    string symbol_;
    uint8 decimals_;
    address payable admin_;
    address implementation_;
    bytes becomeImplementationData;

    // other contracts
    Underlying underlying;
    WhitePaperInterestRateModel interestRateModel;
    CErc20Delegate cErc20Delegate;
    Comptroller comptroller;
    Unitroller unitroller;
    SimplePriceOracle simplePriceOracle;

    CErc20Delegator cErc20Delegator;

    function run() public {

        vm.startBroadcast();
        // --- prepare contracts before deploy Erc20Delegator ---
        // 1. underlying_ -> an ERC20 contract (decimals = 18)
        underlying = new Underlying("Underlying", "UDL", 18);

        // 2. Comptroller -> Unitroller
        // 2.1 admin create comptroller and unitroller
        comptroller = new Comptroller();
        unitroller = new Unitroller();
        // 2.2 admin call unitroller._setPendingImplementation(address(comptroller)) -> check error code == 0
        uint errorCode = unitroller._setPendingImplementation(address(comptroller));
        require(errorCode == 0, "failed to set pendingImplementation");
        // 2.3 admin call comptroller._become(unitroller)
        comptroller._become(unitroller);

        // 11.1 new SimplePriceOracle
        simplePriceOracle = new SimplePriceOracle();
        // 11.2 unitroller._setPriceOracle(PriceOracle(SimplePriceOracle))
        Comptroller(address(unitroller))._setPriceOracle(PriceOracle(simplePriceOracle));

        // 3. InterestRateModel -> use WhitePaperInterestRateModel, 0% rate
        interestRateModel = new WhitePaperInterestRateModel(0, 0);

        // 9. implementation_ -> CErc20Delegate
        cErc20Delegate = new CErc20Delegate();

        // ------------------------------------------------------
        // --- Erc20Delegator contructor's arguments ---
        // 4. ~ 8. & 10.
        underlying_ = address(underlying);
        comptroller_ = ComptrollerInterface(address(unitroller));
        interestRateModel_ = InterestRateModel(address(interestRateModel));
        initialExchangeRateMantissa_ = 1 ether; // 1e18
        name_ = "Compound Underlying";
        symbol_ = "cUDL";
        decimals_ = 18;
        admin_ = payable(address(this));
        implementation_ = address(cErc20Delegate);
        becomeImplementationData = '';
        // ------------------------------------------------------
        // set cERC20Delegator
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

        
        vm.stopBroadcast();
    }
}
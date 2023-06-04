// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/console.sol";
import "../lib/forge-std/src/Script.sol";
import {CErc20Delegator} from "../lib/compound-protocol/contracts/CErc20Delegator.sol";
import {CErc20Delegate} from "../lib/compound-protocol/contracts/CErc20Delegate.sol";
import {ComptrollerInterface} from "../lib/compound-protocol/contracts/ComptrollerInterface.sol";
import {Comptroller} from "../lib/compound-protocol/contracts/Comptroller.sol";
import {Unitroller} from "../lib/compound-protocol/contracts/Unitroller.sol";
import {WhitePaperInterestRateModel} from "../lib/compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import {SimplePriceOracle} from "../lib/compound-protocol/contracts/SimplePriceOracle.sol";
import {TestERC20} from "../contracts/TestERC20.sol";

contract MyScript is Script {
function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);
    vm.startBroadcast(deployerPrivateKey);

    // Create Oracle
    SimplePriceOracle priceOracle = new SimplePriceOracle();
    // Create ERC token
    TestERC20 underlyingToken = new TestERC20("underlyingToken", "UTK", 18);

    // Comptoller proxy setting
    Unitroller unitroller = new Unitroller();
    Comptroller comptroller = new Comptroller();
    Comptroller unitrollerProxy = Comptroller(address(unitroller));
    unitroller._setPendingImplementation(address(comptroller));
    comptroller._become(unitroller);
    unitrollerProxy._setPriceOracle(priceOracle);

    // Using WhitePaperInterestRateModel and set lending rate to 0
    WhitePaperInterestRateModel interestRateModel = new WhitePaperInterestRateModel(0, 0);

    //Call CErc20Delegator
    CErc20Delegate delegate = new CErc20Delegate();
    CErc20Delegator cErc20 = new CErc20Delegator(address(underlyingToken),
                                                ComptrollerInterface(address(unitroller)),
                                                interestRateModel,
                                                1, //initialExchangeRate
                                                "cUnderlyingToken",
                                                "cUTK",
                                                18, //decimals
                                                payable(admin),
                                                address(delegate),
                                                new bytes(0) );
    vm.stopBroadcast();

    }
}
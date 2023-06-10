// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
//cToken
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
//comptroller
import "compound-protocol/contracts/Unitroller.sol";
import "compound-protocol/contracts/Comptroller.sol";
//interestModel
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";

//priceOracle
import "compound-protocol/contracts/SimplePriceOracle.sol";

contract MyScript is Script {
    // oracle
    SimplePriceOracle public priceOracle;
    // whitepaper
    WhitePaperInterestRateModel public whitePaper;
    // comprtroller
    Unitroller public unitroller;
    Comptroller public comptroller;
    Comptroller public unitrollerProxy;
    // cToken
    ERC20 public mt;
    CErc20Delegate public cMTDelegate;
    CErc20Delegator public cMT;

    function run() external {
        // get key
        uint256 deployerPrivateKey = vm.envUint("key");
        vm.startBroadcast(deployerPrivateKey);

        // set oracle
        priceOracle = new SimplePriceOracle(); // deploy oracle contract
        // set whitepaper
        whitePaper = new WhitePaperInterestRateModel(0, 0); // deploy interestRate contract
        // set comptroller
        unitroller = new Unitroller(); // deploy unitroller contract
        comptroller = new Comptroller(); // deploy comptroller contract
        unitrollerProxy = Comptroller(address(unitroller));
        unitroller._setPendingImplementation(address(comptroller)); // set Implementation contract
        comptroller._become(unitroller);
        unitrollerProxy._setPriceOracle(priceOracle); // set oracle

        // set cToken
        mt = new ERC20("My Token", "MT"); // deploy erc20 contract, create MT token
        cMTDelegate = new CErc20Delegate(); // deploy CErc20Delegate contract
        bytes memory data = new bytes(0x00);
        cMT = new CErc20Delegator(
            address(mt),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1e18,
            "Compound My Token",
            "cMT",
            18,
            payable(msg.sender),
            address(cMTDelegate),
            data
        ); // deploy CErc20Delegator contract

        vm.stopBroadcast();
    }
}

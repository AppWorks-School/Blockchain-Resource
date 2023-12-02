// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import { ComptrollerInterface } from "compound-protocol/contracts/ComptrollerInterface.sol";
import { SimplePriceOracle } from "compound-protocol/contracts/SimplePriceOracle.sol";
import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";
import { CToken } from "compound-protocol/contracts/CToken.sol";
import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { InterestRateModel } from "compound-protocol/contracts/InterestRateModel.sol";
import { MyERC20 } from "../src/MyERC20.sol";

contract MyCompoundTest is Test {
    address payable public admin;

    address public user;

    function setUp() public {
        admin = payable(makeAddr("admin"));
        user = makeAddr("User");
    }

    function test_DepolyCompound() public {
        vm.startPrank(admin);
        // 1. new Unitroller
        Unitroller unitroller = new Unitroller();

        // 2. new Comptroller
        Comptroller comptroller = new Comptroller();
        // 2.1 new simple price oracle
        SimplePriceOracle priceOracle = new SimplePriceOracle();
        // 2.2 set price oracle by _setPriceOracle function
        (uint success) = comptroller._setPriceOracle(priceOracle);
        require(success == 0, "_setPriceOracle failed");

        // 3. unitroller set comtroller by _setPendingImplementation function
        (success) = unitroller._setPendingImplementation(address(comptroller));
        require(success == 0, "_setPendingImplementation failed");

        // 4. comptroller set unitroller by _become function
        comptroller._become(unitroller);

        // 5. new underlying token, decimails is 18
        MyERC20 underlying = new MyERC20("yoasobi", "YAB", 18);
        // 6. new CErc20Delegate token, decimails is 18
        CErc20Delegate cERC20Delegate = new CErc20Delegate();
        // 7. new InterestRateModel
        WhitePaperInterestRateModel interestRateModel = new WhitePaperInterestRateModel(0, 0);
        // 8. new CErc20Delegator
        CErc20Delegator cERC20Delegator = new CErc20Delegator(
            address(underlying),
            ComptrollerInterface(comptroller),
            InterestRateModel(interestRateModel),
            1e18,
            "cyoasobi",
            "cYAB",
            18,
            admin,
            address(cERC20Delegate),
            bytes("")
        );

        // 9. support the cToken by _supportMarket function
        (success) = comptroller._supportMarket(CToken(address(cERC20Delegator)));
        require(success == 0, "_supportMarket failed");

        vm.stopPrank();

        // test a user mint cToken
        uint256 initialBalance = 10000 * 10 ** underlying.decimals();
        deal(address(underlying), user, initialBalance);
        
        vm.startPrank(user);

        underlying.approve(address(cERC20Delegator), initialBalance);
        uint256 supplyMarket = 1000 * 10 ** underlying.decimals();
        (success) = cERC20Delegator.mint(supplyMarket);
        assertEq(success, 0);

        console.log("my erc20 balance of user: %d", underlying.balanceOf(user));
        assertEq(underlying.balanceOf(user) == initialBalance-supplyMarket, true);
        console.log("my cERC20 balance of user: %d", cERC20Delegator.balanceOf(user));
        assertEq(cERC20Delegator.balanceOf(user) == supplyMarket, true);

        vm.stopPrank();
    }

    
}
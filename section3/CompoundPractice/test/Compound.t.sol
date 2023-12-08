// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
import "compound-protocol/contracts/PriceOracle.sol";
import "contracts/MyToken.sol";

contract Compound is Test {
    Comptroller public comptroller;
    InterestRateModel public interestRateModel;
    WhitePaperInterestRateModel public interestRateModel;
    SimplePriceOracle public simplePriceOracle;


    function setup() public {
        // deploy comptroller
        Comptroller comptroller = new Comptroller();
        Unitroller unitroller = new Unitroller();
        uint errorCode = unitroller._setPendingImplementation(address(comptroller));
        require(errorCode == 0, "Set Implementation Failed");
        comptroller._become(unitroller);
        // oracle
        simplePriceOracle = new SimplePriceOracle();
        comptroller = Comptroller(address(unitroller));
        comptroller._setPriceOracle(PriceOracle(simplePriceOracle));
        interestRateModel = new WhitePaperInterestRateModel(0, 0);

        // Deploy cERC20 tokenA
        tokenA = new MyToken("tokenA", "tokenA");
        CErc20Delegate cErc20Delegate = new CErc20Delegate();
        cToken = new CErc20Delegator(
            address(token),
            comptroller,
            InterestRateModel(address(interestRateModel)),
            1 ether,
            token.name,
            token.symbol,
            18,
            payable(address(this)),
            address(cErc20Delegate),
            becomeImplementationData
        );
        comptroller._supportMarket(cToken(address(tokenA)));

        // Deploy cERC20 tokenB
        tokenA = new MyToken("tokenA", "tokenA");
        CErc20Delegate cErc20Delegate = new CErc20Delegate();
        cToken = new CErc20Delegator(
            address(token),
            comptroller,
            InterestRateModel(address(interestRateModel)),
            1 ether,
            token.name,
            token.symbol,
            18,
            payable(address(this)),
            address(cErc20Delegate),
            becomeImplementationData
        );
        comptroller._supportMarket(cToken(address(tokenB)));

        // users
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testMintAndRedeem() public {
        // user 1 use 100 ERC20 tokens to mint 100 cERC20 tokens.
        // user 1 use 100 cERC20 tokens to redeem 100 ERC20 tokens.
    }

    function testBorrowAndRepay() public {

    }

    function testLiquidateByAdjustCollateralFactor() public {

    }

    function testLiquidateByAdjustTokenBPrice() public {

    }
}

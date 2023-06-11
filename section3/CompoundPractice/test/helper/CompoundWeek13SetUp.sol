// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {CErc20Delegator} from "compound-protocol/contracts/CErc20Delegator.sol";
import {CErc20Delegate} from "compound-protocol/contracts/CErc20Delegate.sol";
import {ComptrollerInterface} from "compound-protocol/contracts/ComptrollerInterface.sol";
import {Comptroller} from "compound-protocol/contracts/Comptroller.sol";
import {Unitroller} from "compound-protocol/contracts/Unitroller.sol";
import {WhitePaperInterestRateModel} from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import {SimplePriceOracle} from "compound-protocol/contracts/SimplePriceOracle.sol";
import {PriceOracle} from "compound-protocol/contracts/PriceOracle.sol";
import {InterestRateModel} from "compound-protocol/contracts/InterestRateModel.sol";
import { CToken } from "compound-protocol/contracts/CToken.sol";
import {TestERC20} from "../../contracts/TestERC20.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";


contract CompoundWeek13SetUp is Test {
  Unitroller unitroller;
  Comptroller comptroller;
  Comptroller proxyComptroller;
  SimplePriceOracle simplePriceOracle;
  PriceOracle priceOracle;

  ERC20 TokenA;
  ERC20 TokenB;

  string nameA = "CTokenA";
  string symbolA = "cTA";
  string nameB = "CTokenB";
  string symbolB = "cTB";
  uint8 decimalsA = 18;
  uint8 decimalsB = 18;

  CErc20Delegate cErc20DelegateA;
  CErc20Delegator cTokenA;

  CErc20Delegate cErc20DelegateB;
  CErc20Delegator cTokenB;

  address public admin;

  function setUp() public virtual {
    admin = makeAddr("admin");

    vm.startPrank(admin);

    // Deploy Comptroller
    unitroller = new Unitroller();
    comptroller = new Comptroller();
    simplePriceOracle = new SimplePriceOracle();
    priceOracle = simplePriceOracle;
    uint closeFactor = 0;
    uint liquidationIncentive = 0;

    unitroller._setPendingImplementation(address(comptroller));
    comptroller._become(unitroller);

    // Delegate call
    proxyComptroller = Comptroller(address(unitroller));
    proxyComptroller._setLiquidationIncentive(liquidationIncentive);
    proxyComptroller._setCloseFactor(closeFactor);
    proxyComptroller._setPriceOracle(priceOracle);

    // Deploy underlying Erc20 token ABC
    TokenA = new ERC20("TokenA", "TA");
    TokenB = new ERC20("TokenB", "TB");

    // Deploy CTokenA
    uint baseRatePerYearA = 0;
    uint mutliplierPerYearA = 0;
    InterestRateModel interestRateModelA = new WhitePaperInterestRateModel(baseRatePerYearA, mutliplierPerYearA);
    uint exchangeRateMantissaA = 1 * 1e18;
    cErc20DelegateA = new CErc20Delegate();

    cTokenA = new CErc20Delegator(
      address(TokenA),
      proxyComptroller,
      interestRateModelA,
      exchangeRateMantissaA,
      nameA,
      symbolA,
      decimalsA,
      payable(admin),
      address(cErc20DelegateA),
      new bytes(0)
    );

    // Deploy CTokenB
    uint baseRatePerYearB = 0;
    uint mutliplierPerYearB = 0;
    InterestRateModel interestRateModelB = new WhitePaperInterestRateModel(baseRatePerYearB, mutliplierPerYearB);
    uint exchangeRateMantissaB = 1 * 1e18;
    cErc20DelegateB = new CErc20Delegate();

    cTokenB = new CErc20Delegator(
      address(TokenB),
      proxyComptroller,
      interestRateModelB,
      exchangeRateMantissaB,
      nameB,
      symbolB,
      decimalsB,
      payable(admin),
      address(cErc20DelegateB),
      new bytes(0)
    );

    // Add CTokenA, CTokenB to market
    proxyComptroller._supportMarket(CToken(address(cTokenA)));
    proxyComptroller._supportMarket(CToken(address(cTokenB)));

    uint mintAmountA = 1000 * 10 ** TokenA.decimals();
    uint mintAmountB = 1000 * 10 ** TokenA.decimals();

    deal(address(TokenA), admin, mintAmountA);
    TokenA.approve(address(cTokenA), mintAmountA);
    cTokenA.mint(mintAmountA);

    deal(address(TokenB), admin, mintAmountB);
    TokenB.approve(address(cTokenB), mintAmountB);
    cTokenB.mint(mintAmountB);

    vm.stopPrank();
  }
}

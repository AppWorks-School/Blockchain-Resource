// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "solmate/tokens/ERC20.sol";
import { ComptrollerInterface } from "compound-protocol/contracts/ComptrollerInterface.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { InterestRateModel } from "compound-protocol/contracts/InterestRateModel.sol";
import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";
import { Timelock } from "compound-protocol/contracts/Timelock.sol";
import { PriceOracle } from "compound-protocol/contracts/PriceOracle.sol";
import { SimplePriceOracle } from "compound-protocol/contracts/SimplePriceOracle.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";

contract FiatToken is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol, decimals) {}
}

contract LendingPracticeTest is Test {
    ERC20 public usdt;
    FiatToken public usdtERC20;
    ComptrollerInterface public comptrollerInterface;
    Unitroller public unitroller;
    InterestRateModel public interestRateModel;
    WhitePaperInterestRateModel public whitePaperInterestRateModel;
    uint public borrowRate;
    CErc20Delegate public cerc20Delegate;
    CErc20Delegator public cerc20Delegator;
    Timelock public admin;
    address public user;
    PriceOracle public priceOracle;
    SimplePriceOracle public simplePriceOracle;
    Comptroller public comptroller;
    Comptroller public unitrollerProxy;
    function setUp() public {
        usdtERC20 = new FiatToken("USDT", "USDT", 18);
        usdt = ERC20(address(usdtERC20));
        unitroller = new Unitroller();
        comptrollerInterface = ComptrollerInterface(address(unitroller));
        uint baseRatePerYear = 50000000000000000;
        uint multiplierPerYear = 120000000000000000;
        whitePaperInterestRateModel = new WhitePaperInterestRateModel(baseRatePerYear, multiplierPerYear);
        // 設定借貸利率為 0
        borrowRate = whitePaperInterestRateModel.getBorrowRate(0, 0, 0);
        interestRateModel = InterestRateModel(address(whitePaperInterestRateModel));
        user = makeAddr("User");
        admin = new Timelock(user, 172800);
        bytes memory empty;
        // 設定 exchange rate 為 1 => initialExchangeRateMantissa_ = 1
        cerc20Delegator = new CErc20Delegator(address(usdt), comptrollerInterface, interestRateModel, 1, "Compound USDT", "cUSDT", 18, payable(address(admin)), address(cerc20Delegate), empty);
        // 使用 SimplePriceOracle 作為 Oracle
        simplePriceOracle = new SimplePriceOracle();
        priceOracle = PriceOracle(address(simplePriceOracle));
        comptroller = new Comptroller();
        unitrollerProxy = Comptroller(address(unitroller));
        unitrollerProxy._setPriceOracle(priceOracle);
    }
}
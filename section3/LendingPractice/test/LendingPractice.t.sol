// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "solmate/tokens/ERC20.sol";
import { ComptrollerInterface } from "compound-protocol/contracts/ComptrollerInterface.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { InterestRateModel } from "compound-protocol/contracts/InterestRateModel.sol";
import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";
import { CErc20 } from "compound-protocol/contracts/CErc20.sol";
import { CToken } from "compound-protocol/contracts/CToken.sol";
import { Timelock } from "compound-protocol/contracts/Timelock.sol";
// import { PriceOracle } from "compound-protocol/contracts/PriceOracle.sol"; // 不須透過 Price Oracle interface
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
    // CErc20Delegator public cerc20Delegator; // 以 cUsdt 命名比較直觀
    CErc20Delegator public cUsdt;
    Timelock public admin = admin = new Timelock(user1, 172800); // 172800 = 2 days => Timelock 合約判斷 MINIMUM_DELAY = 2 days
    address public user1;
    address public user2;
    // PriceOracle public priceOracle; // 不須透過 Price Oracle interface
    SimplePriceOracle public simplePriceOracle;
    Comptroller public comptroller;
    Comptroller public unitrollerProxy;
    bytes public data = new bytes(0x00); // 或者 0x00 即可

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        /*** Comptroller ***/
        unitroller = new Unitroller();
        comptroller = new Comptroller();
        unitrollerProxy = Comptroller(address(unitroller));
        /*** interest rate model ***/
        uint baseRatePerYear = 50000000000000000;
        uint multiplierPerYear = 120000000000000000;
        whitePaperInterestRateModel = new WhitePaperInterestRateModel(baseRatePerYear, multiplierPerYear);
        // 設定借貸利率為 0
        borrowRate = whitePaperInterestRateModel.getBorrowRate(0, 0, 0);
        interestRateModel = InterestRateModel(address(whitePaperInterestRateModel));
        /*** Price Oracle ***/
        // unitrollerProxy._setPriceOracle(priceOracle); // 需先 _setPendingImplementation, _become 才可以 _setPriceOracle
        unitroller._setPendingImplementation(address(comptroller));
        comptroller._become(unitroller);
        // 使用 SimplePriceOracle 作為 Oracle
        // priceOracle = PriceOracle(address(simplePriceOracle)); // 不須透過 Price Oracle interface
        simplePriceOracle = new SimplePriceOracle();
        unitrollerProxy._setPriceOracle(simplePriceOracle);
        /*** CToken ***/
        usdtERC20 = new FiatToken("USDT", "USDT", 18);
        usdt = ERC20(address(usdtERC20));
        comptrollerInterface = ComptrollerInterface(address(unitroller));
        cerc20Delegate = new CErc20Delegate();
        // 設定 exchange rate 為 1 => initialExchangeRateMantissa_ = 1 * 10 ** 18
        // cerc20Delegator = new CErc20Delegator(address(usdt), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound USDT", "cUSDT", 18, payable(address(admin)), address(cerc20Delegate), empty);
        cUsdt = new CErc20Delegator(address(usdt), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound USDT", "cUSDT", 18, payable(address(admin)), address(cerc20Delegate), data);
        /*** 重要初始設定 ***/
        // 抵押率
        // unitrollerProxy._setCollateralFactor(CToken(address(cUsdt)), 0.05e18);
        // // 清算係數 = 0.05
        // unitrollerProxy._setCloseFactor(0.05e18); // 0.05e18 = 500000000000000000 = 50% decimals=20
    }
    // 2. User1 mint/redeem cERC20
    // User1 使用 100 顆（100 * 10^18） ERC20 去 mint 出 100 cERC20 token，再用 100 cERC20 token redeem 回 100 顆 ERC20
    function testMintRedeem() public {
        // 設定 cToken price
        simplePriceOracle.setUnderlyingPrice(CToken(address(cUsdt)), 1e18); // 不可由 user1 執行 因為是當前合約部署 Compound
        // 加入市場創建資金池
        unitrollerProxy._supportMarket(CToken(address(cUsdt))); // 不可由 user1 執行 因為是當前合約部署 Compound
        vm.startPrank(user1);
        uint amount100 = 100000000000000000000;
        // 轉錢給 user1
        deal(address(usdt), user1, amount100);
        console.log("user1's usdt: ", usdt.balanceOf(user1));
        // address[] memory cTokens = new address[](1);
        // cTokens[0] = address(cUsdt);
        // unitrollerProxy.enterMarkets(cTokens); // 需要借款時才需要抵押
        usdt.approve(address(cUsdt), amount100);
        CErc20(address(cUsdt)).mint(amount100);
        console.log("unitrollerProxy's usdt: ", usdt.balanceOf(address(cUsdt)));
        cUsdt.approve(address(cUsdt), amount100);
        CErc20(address(cUsdt)).redeem(amount100);
    }

    // 3. User1 borrow/repay
    // - 部署第二份 cERC20 合約，以下稱它們的 underlying tokens 為 token A 與 token B。
    // - 在 Oracle 中設定一顆 token A 的價格為 $1，一顆 token B 的價格為 $100
    // - Token B 的 collateral factor 為 50%
    // - User1 使用 1 顆 token B 來 mint cToken
    // - User1 使用 token B 作為抵押品來借出 50 顆 token A
    function testBorrowRepay() public {
        // - 部署第二份 cERC20 合約，以下稱它們的 underlying tokens 為 token A 與 token B。
        ERC20 tokenAERC20 = new FiatToken("tokanA", "tokenA", 18);
        ERC20 tokenBERC20 = new FiatToken("tokanA", "tokenB", 18);
        ERC20 tokenA = ERC20(address(tokenAERC20));
        ERC20 tokenB = ERC20(address(tokenBERC20));
        CErc20Delegator cTokenA = new CErc20Delegator(address(tokenA), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenA", "cTokenA", 18, payable(address(admin)), address(cerc20Delegate), data);
        CErc20Delegator cTokenB = new CErc20Delegator(address(tokenB), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenB", "cTokenB", 18, payable(address(admin)), address(cerc20Delegate), data);
        // - 在 Oracle 中設定一顆 token A 的價格為 $1，一顆 token B 的價格為 $100
        // 設定 underlying token price
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenA)), 1e18);
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 100 * 1e18);
        unitrollerProxy._supportMarket(CToken(address(cTokenA)));
        unitrollerProxy._supportMarket(CToken(address(cTokenB)));
        // - Token B 的 collateral factor 為 50%
        unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.5e18);
        // 轉錢給 user1
        deal(address(tokenB), user1, 1e18);
        deal(address(tokenA), address(cTokenA), type(uint).max); // cTokenA 資金池需要有 tokenA 才能讓人借款出去 tokenA
        console.log("tokenA of cTokenA: ", tokenA.balanceOf(address(cTokenA)));
        // - User1 使用 1 顆 token B 來 mint cToken
        vm.startPrank(user1);
        uint deposit = 1e18;
        tokenB.approve(address(cTokenB), deposit);
        cTokenB.mint(deposit);
        // - User1 使用 token B 作為抵押品來借出 50 顆 token A
        // cTokenB 做為抵押品
        address[] memory cTokenBs = new address[](1);
        cTokenBs[0] = address(cTokenB);
        unitrollerProxy.enterMarkets(cTokenBs);
        uint borrowAmount = 50 * 1e18;
        console.log("cTokenA: ", address(cTokenA));
        console.log("cTokenB: ", address(cTokenB));
        cTokenA.borrow(borrowAmount);
        vm.stopPrank();
    }

    // 4. 延續 (3.) 的借貸場景，調整 token B 的 collateral factor，讓 User1 被 User2 清算
    function testLiquidateBorrowForCollateral() public {
        // - 部署第二份 cERC20 合約，以下稱它們的 underlying tokens 為 token A 與 token B。
        ERC20 tokenAERC20 = new FiatToken("tokanA", "tokenA", 18);
        ERC20 tokenBERC20 = new FiatToken("tokanA", "tokenB", 18);
        ERC20 tokenA = ERC20(address(tokenAERC20));
        ERC20 tokenB = ERC20(address(tokenBERC20));
        CErc20Delegator cTokenA = new CErc20Delegator(address(tokenA), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenA", "cTokenA", 18, payable(address(admin)), address(cerc20Delegate), data);
        CErc20Delegator cTokenB = new CErc20Delegator(address(tokenB), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenB", "cTokenB", 18, payable(address(admin)), address(cerc20Delegate), data);
        // - 在 Oracle 中設定一顆 token A 的價格為 $1，一顆 token B 的價格為 $100
        // 設定 underlying token price
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenA)), 1e18);
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 100 * 1e18);
        unitrollerProxy._supportMarket(CToken(address(cTokenA)));
        unitrollerProxy._supportMarket(CToken(address(cTokenB)));
        // - Token B 的 collateral factor 為 50%
        unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.5e18);
        // 轉錢給 user1
        deal(address(tokenB), user1, 1e18);
        deal(address(tokenA), address(cTokenA), type(uint).max); // cTokenA 資金池需要有 tokenA 才能讓人借款出去 tokenA
        console.log("tokenA of cTokenA: ", tokenA.balanceOf(address(cTokenA)));
        // - User1 使用 1 顆 token B 來 mint cToken
        vm.startPrank(user1);
        uint deposit = 1e18;
        tokenB.approve(address(cTokenB), deposit);
        cTokenB.mint(deposit);
        // - User1 使用 token B 作為抵押品來借出 50 顆 token A
        // cTokenB 做為抵押品
        address[] memory cTokenBs = new address[](1);
        cTokenBs[0] = address(cTokenB);
        unitrollerProxy.enterMarkets(cTokenBs);
        uint borrowAmount = 50 * 1e18;
        console.log("cTokenA: ", address(cTokenA));
        console.log("cTokenB: ", address(cTokenB));
        cTokenA.borrow(borrowAmount);
        vm.stopPrank();

        // 調整 tokenB's collateral factory
        unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.1e18);

        // 讓 User1 被 User2 清算
        // 假設 cTokenA close factory 為 0.5
        unitrollerProxy._setCloseFactor(0.5e18);
        unitrollerProxy._setLiquidationIncentive(1.08e18);

        deal(address(tokenA), user2, 1000e18); 
        console.log("user1's cTokenB balanceOf: ", cTokenB.balanceOf(user1)); // 1000000000000000000
        // 10000000000000000000 (= 1000000000000000000 * 100000000000000000000 * 100000000000000000 / 1e18 ** 2) < borrow amount => 可被清算
        console.log("user1's cTokenB value: ", cTokenB.balanceOf(user1) * simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenB))) * 0.1e18 / 1e18 ** 2);
        console.log("user1's cTokenA borrow amount: ", cTokenA.borrowBalanceCurrent(user1));
        console.log("cTokenB's close factory: ", unitrollerProxy.closeFactorMantissa());
        console.log("user1's liquidateBorrow amount: ", cTokenB.balanceOf(user1) * unitrollerProxy.closeFactorMantissa() / 1e18);
        // 25000000000000000000
        // uint mintAmount = cTokenA.borrowBalanceCurrent(user1) * simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))) * 0.1e18 * unitrollerProxy.closeFactorMantissa() / 1e18 ** 3;
        /***** 借錢與 collateral factory 無關 *****/
        uint repayAmount = cTokenA.borrowBalanceCurrent(user1) * simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))) * unitrollerProxy.closeFactorMantissa() / 1e18 ** 2;
        console.log("repayAmount: ", repayAmount);

        (, uint liquidity, uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        assertGt(shortfall, 0); 

        vm.startPrank(user2);
        /***** 因為 user1 是借款 tokenA 所以直接拿 tokenA 幫 user1 還錢就好。 *****/
        // tokenA.approve(address(cTokenA), repayAmount); // 2500000000000000000
        // cTokenA.mint(repayAmount);
        console.log("user2's cTokenA balanceOf: ", cTokenA.balanceOf(user2));
        console.log("user2's tokenA balanceOf: ", tokenA.balanceOf(user2));
        console.log("address(cTokenA)'s tokenA balanceOf: ", tokenA.balanceOf(address(cTokenA)));
        console.log("address(cTokenB)'s tokenB balanceOf: ", tokenB.balanceOf(address(cTokenB)));
        console.log("user1's cTokenB balanceOf: ", cTokenB.balanceOf(user1));
        // cTokenA.approve(address(cTokenA), mintAmount);
        tokenA.approve(address(cTokenA), repayAmount);
        cTokenA.liquidateBorrow(user1, repayAmount, CToken(address(cTokenB)));
    }

    // 延續 (3.) 的借貸場景，調整 oracle 中 token B 的價格，讓 User1 被 User2 清算
    function testLiquidateBorrowPrice() public {
        // - 部署第二份 cERC20 合約，以下稱它們的 underlying tokens 為 token A 與 token B。
        ERC20 tokenAERC20 = new FiatToken("tokanA", "tokenA", 18);
        ERC20 tokenBERC20 = new FiatToken("tokanA", "tokenB", 18);
        ERC20 tokenA = ERC20(address(tokenAERC20));
        ERC20 tokenB = ERC20(address(tokenBERC20));
        CErc20Delegator cTokenA = new CErc20Delegator(address(tokenA), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenA", "cTokenA", 18, payable(address(admin)), address(cerc20Delegate), data);
        CErc20Delegator cTokenB = new CErc20Delegator(address(tokenB), comptrollerInterface, interestRateModel, 1 * 10 ** 18, "Compound cTokenB", "cTokenB", 18, payable(address(admin)), address(cerc20Delegate), data);
        // - 在 Oracle 中設定一顆 token A 的價格為 $1，一顆 token B 的價格為 $100
        // 設定 underlying token price
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenA)), 1e18);
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 100 * 1e18);
        unitrollerProxy._supportMarket(CToken(address(cTokenA)));
        unitrollerProxy._supportMarket(CToken(address(cTokenB)));
        // - Token B 的 collateral factor 為 50%
        unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.5e18);
        // 轉錢給 user1
        deal(address(tokenB), user1, 1e18);
        deal(address(tokenA), address(cTokenA), type(uint).max); // cTokenA 資金池需要有 tokenA 才能讓人借款出去 tokenA
        console.log("tokenA of cTokenA: ", tokenA.balanceOf(address(cTokenA)));
        // - User1 使用 1 顆 token B 來 mint cToken
        vm.startPrank(user1);
        uint deposit = 1e18;
        tokenB.approve(address(cTokenB), deposit);
        cTokenB.mint(deposit);
        // - User1 使用 token B 作為抵押品來借出 50 顆 token A
        // cTokenB 做為抵押品
        address[] memory cTokenBs = new address[](1);
        cTokenBs[0] = address(cTokenB);
        unitrollerProxy.enterMarkets(cTokenBs);
        uint borrowAmount = 50 * 1e18;
        console.log("cTokenA: ", address(cTokenA));
        console.log("cTokenB: ", address(cTokenB));
        cTokenA.borrow(borrowAmount);
        vm.stopPrank();
        console.log("after - user1's tokenB: ", tokenB.balanceOf(user1));
        console.log("after - user1's cTokenB: ", cTokenB.balanceOf(user1));
        console.log("after - user1's tokenA: ", tokenA.balanceOf(user1));
        console.log("after - user1's cTokenA: ", cTokenA.balanceOf(user1));

        // 假設調整 oracle 中 token B 的價格
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 40e18);
        // 調整 tokenB's collateral factory
        // unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.1e18);

        // 讓 User1 被 User2 清算
        unitrollerProxy._setCloseFactor(0.5e18);
        unitrollerProxy._setLiquidationIncentive(1.08e18);

        deal(address(tokenA), user2, 1000e18);
        uint repayAmount = cTokenA.borrowBalanceCurrent(user1) * simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))) * unitrollerProxy.closeFactorMantissa() / 1e18 ** 2;

        (, uint liquidity, uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        console.log("liquidity: ", liquidity);
        console.log("shorfall: ", shortfall);
        assertGt(shortfall, 0);

        // user2 清算 user1
        vm.startPrank(user2);
        tokenA.approve(address(cTokenA), repayAmount);
        cTokenA.liquidateBorrow(user1, repayAmount, CToken(address(cTokenB)));
    }
}
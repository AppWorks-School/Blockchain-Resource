// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "solmate/tokens/ERC20.sol";

import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { ComptrollerInterface } from "compound-protocol/contracts/ComptrollerInterface.sol";

import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { InterestRateModel } from "compound-protocol/contracts/InterestRateModel.sol";

import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";

import { SimplePriceOracle } from "compound-protocol/contracts/SimplePriceOracle.sol";

import { CToken } from "compound-protocol/contracts/CToken.sol";
import { CErc20 } from "compound-protocol/contracts/CErc20.sol";

import { AaveFlashLoan } from "../src/AaveFlashLoan.sol";

contract AaveV3PracticeHw14Test is Test {
    // 鏈上 token
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // decimals = 6
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; // decimals = 18

    address public user1;
    address public user2;
    address public admin;

    ERC20 public tokenA;
    ERC20 public tokenB;

    Comptroller public comptroller;
    Unitroller public unitroller;
    Comptroller public unitrollerProxy;
    WhitePaperInterestRateModel public whitePaperInterestRateModel;
    uint public borrowRate;
    bytes public becomeImplementationData_;
    CErc20Delegate public implementation;

    CErc20Delegator public cTokenA;
    CErc20Delegator public cTokenB;
    
    SimplePriceOracle public simplePriceOracle;

    AaveFlashLoan public aaveFlashLoan;

    function setUp() public {
        // fork mainnet
        string memory rpc = vm.envString("MAINNET_RPC_URL");
        // vm.createSelectFork(rpc);
        // vm.createSelectFork(rpc, 17465000);
        vm.createSelectFork(rpc);
        vm.rollFork(17465000);

        // role
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // token
        tokenA = ERC20(address(USDC));
        tokenB = ERC20(address(UNI));

        // 準備實作 cUSDC cToken 所需參數
        // 1. underlying token
        address underlying_ = address(tokenA);
        // 2. comptroller
        unitroller = new Unitroller();
        comptroller = new Comptroller();
        unitrollerProxy = Comptroller(address(unitroller));

        unitroller._setPendingImplementation(address(comptroller));
        comptroller._become(unitroller);
        ComptrollerInterface comptroller_ = ComptrollerInterface(address(unitroller));
        // Price Oracle
        simplePriceOracle = new SimplePriceOracle();
        unitrollerProxy._setPriceOracle(simplePriceOracle);
        // 3. interestRateModel
        uint baseRatePerYear = 50000000000000000;
        uint multiplierPerYear = 120000000000000000;
        whitePaperInterestRateModel = new WhitePaperInterestRateModel(baseRatePerYear, multiplierPerYear);
        // 設定借貸利率為 0
        borrowRate = whitePaperInterestRateModel.getBorrowRate(0, 0, 0);
        /*** Price Oracle ***/
        // unitrollerProxy._setPriceOracle(priceOracle); // 需先 _setPendingImplementation, _become 才可以 _setPriceOracle
        unitroller._setPendingImplementation(address(comptroller));
        comptroller._become(unitroller);
        // 使用 SimplePriceOracle 作為 Oracle
        // priceOracle = PriceOracle(address(simplePriceOracle)); // 不須透過 Price Oracle interface
        simplePriceOracle = new SimplePriceOracle();
        unitrollerProxy._setPriceOracle(simplePriceOracle);
        InterestRateModel interestRateModel_ = InterestRateModel(address(whitePaperInterestRateModel));
        // 4. 初始 exchange rate - 一個 cToken 可以換多少 underlying token
        uint initialExchangeRateMantissa_ = 1 * 10 ** 6; // 18 - 18 + 6 = 1e6
        // 5. 設定 cToken metadata
        string memory name_ = "Compound USDC";
        string memory symbol_ = "cUSDC";
        uint8 decimals_ = 18;
        // 6. 指定 admin
        admin = makeAddr("Admin");
        address payable admin_ = payable(address(admin));
        // 7. 指定 implementation
        implementation = new CErc20Delegate();
        address implementation_ = address(implementation);
        // 8. 設定 data
        becomeImplementationData_ = new bytes(0x00); // or new bytes(0)
        // 9. 實作 cToken
        cTokenA = new CErc20Delegator(
            underlying_,
            comptroller_,
            interestRateModel_, 
            initialExchangeRateMantissa_, 
            name_,
            symbol_,
            decimals_,
            admin_,
            implementation_,
            becomeImplementationData_
        );
        // UNI 與 USDC 差異
        // 1. underlying token
        underlying_ = address(tokenB);
        // 4. 初始 exchange rate - 一個 cToken 可以換多少 underlying token
        initialExchangeRateMantissa_ = 1 * 10 ** 18; // 18 - 18 + 18
        // 5. 設定 cToken metadata
        name_ = "Compound Uniswap";
        symbol_ = "cUNI";
        decimals_ = 18;
        // 自己實作 cUNI cToken - 因為題目設定 decimals 都與鏈上不同。
        cTokenB = new CErc20Delegator(
            underlying_,
            comptroller_,
            interestRateModel_, 
            initialExchangeRateMantissa_, 
            name_,
            symbol_,
            decimals_,
            admin_,
            implementation_,
            becomeImplementationData_
        );

        // 設定 Compound 其他相關係數
        // vm.startPrank(admin); // only admin can set close factor - 所以是指部署的人也就是 address(this) 而不是 admin
        // 1. 設定 close factor (清算係數-清算率)
        unitrollerProxy._setCloseFactor(0.5e18); // 50%
        // 2. 設定 liquidation incentive (清算獎勵)
        unitrollerProxy._setLiquidationIncentive(1.08e18); // 8% - 須包含 1 因為才能包含到本金
        // 3. 設定 underlying token's price (標的資產)
        
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenA)), 1e30); // 10 ** (18 - 6 + 18)
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 5e18);
        unitrollerProxy._supportMarket(CToken(address(cTokenA)));
        unitrollerProxy._supportMarket(CToken(address(cTokenB)));
        // 4. 設定 collateral factor (抵押係數 - 抵押率)
        unitrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.5e18); // 因為要用 UNI 抵押然後借款 USDC

        // 其他場景預設
        deal(address(tokenB), user1, 1000 * 10 ** tokenB.decimals()); // 因為 UNI 宣告為 ERC20 所以要加 address
        deal(address(tokenA), address(cTokenA), 10000 * 10 ** tokenA.decimals()); // cTokenA 資金池需要有 tokenA 才能讓人借款出去 tokenA

        aaveFlashLoan = new AaveFlashLoan();
    }

    // tokenA = USDC, tokenB = UNI
    function testFlashLoan() public {
        // console.log("USDC's price: ", simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))));
        // console.log("UNI's price: ", simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenB))));
        // console.log("user1's tokenB: ", tokenB.balanceOf(user1));
        vm.startPrank(user1);
        // 1. user1 拿 1000 顆 UNI 存款
        tokenB.approve(address(cTokenB), 1000 * 10 ** tokenB.decimals());
        cTokenB.mint(1000 * 10 ** tokenB.decimals());
        // 2. user1 拿 1000 顆 UNI 作為抵押 - 實際上是設定 cTokenB 為抵押品
        // - user1 使用 token B 作為抵押品來借出 50 顆 token A
        // cTokenB 做為抵押品
        address[] memory cTokenBs = new address[](1);
        cTokenBs[0] = address(cTokenB);
        unitrollerProxy.enterMarkets(cTokenBs);
        // 3. user1 借款 2500 USDC
        console.log("before - user1's USDC: ", tokenA.balanceOf(user1));
        console.log("before - user1's cUSDC: ", cTokenA.balanceOf(user1));
        uint borrowAmount = 2500 * 10 ** tokenA.decimals();
        console.log("tokenA(USDC).decimals: ", tokenA.decimals());
        cTokenA.borrow(borrowAmount);
        console.log("after - user1's UNI: ", tokenB.balanceOf(user1));
        console.log("after - user1's cUNI: ", cTokenB.balanceOf(user1));
        console.log("after - user1's USDC: ", tokenA.balanceOf(user1));
        console.log("after - user1's cUSDC: ", cTokenA.borrowBalanceStored(user1));
        // 4. 將 UNI 價格改為 $4 使 User1 產生 Shortfall
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 4e18);
        console.log("cUNI's price: ", simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenB))));
        (, uint liquidity, uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        console.log("liquidity: ", liquidity);
        console.log("shorfall: ", shortfall);
        assertGt(shortfall, 0);
        vm.stopPrank();
        // 5.  User2 透過 AAVE 的 Flash loan 來借錢清算 User1
        vm.startPrank(user2);    

        console.log("before - user2's UNI: ", tokenB.balanceOf(user2));
        // 計算應該花多少錢幫 user1 還錢
        console.log("cTokenA's price: ", simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))));
        // underlyingToken(cTokenA) decimals 為 30 所以要除以 1e30
        uint repayAmount = 
        cTokenA.borrowBalanceCurrent(user1) * simplePriceOracle.getUnderlyingPrice(CToken(address(cTokenA))) * unitrollerProxy.closeFactorMantissa() 
        / (1e18 * 1e30);
        console.log("repayAmount", repayAmount);
        console.log("borrowAmount /2: ", borrowAmount /2);
         // Set up callback data for liquidation in flashloan
        bytes memory callbackdata = abi.encode(address(user1), address(cTokenA), address(cTokenB), address(tokenB));
        console.log("cTokenA address: ", address(cTokenA));
        console.log("cTokenB address: ", address(cTokenB));
        aaveFlashLoan.execute(
            repayAmount,
            callbackdata
        );
        console.log("user2: ", address(user2));
        console.log("after - user2's UNI: ", tokenB.balanceOf(user2));
        console.log("user2 usdc balance: ", tokenA.balanceOf(address(user2)));
        assertGe(tokenA.balanceOf(address(user2)), 63 * 10 ** tokenA.decimals());
        vm.stopPrank();
    }
}

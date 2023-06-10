// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
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

contract SimpleCompoundTest is Test {
    // oracle
    SimplePriceOracle public priceOracle;
    // whitepaper
    WhitePaperInterestRateModel public whitePaper;
    // comprtroller
    Unitroller public unitroller;
    Comptroller public comptroller;
    Comptroller public unitrollerProxy;
    // cTokenA
    ERC20 public MT;
    CErc20Delegate public cMTDelegateA;
    CErc20Delegator public cMT;

    // cTokenB
    ERC20 public YT;
    CErc20Delegate public cMTDelegateB;
    CErc20Delegator public cYT;

    // user
    address public user1;
    address public user2;

    function setUp() public {
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

        // set cTokenA
        MT = new ERC20("My Token", "MT"); // deploy erc20 contract, create MT token
        cMTDelegateA = new CErc20Delegate(); // deploy CErc20Delegate contract
        bytes memory data = new bytes(0x00);
        cMT = new CErc20Delegator(
            address(MT),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1e18,
            "Compound My Token",
            "cMT",
            18,
            payable(msg.sender),
            address(cMTDelegateA),
            data
        ); // deploy cMT
        unitrollerProxy._supportMarket(CToken(address(cMT)));

        // set cTokenB
        YT = new ERC20("Your Token", "YT"); // deploy erc20 contract, create YT token
        cMTDelegateB = new CErc20Delegate(); // deploy CErc20Delegate contract
        cYT = new CErc20Delegator(
            address(YT),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1e18,
            "Compound Your Token",
            "cYT",
            18,
            payable(msg.sender),
            address(cMTDelegateB),
            data
        ); // deploy cYT
        unitrollerProxy._supportMarket(CToken(address(cYT)));

        // set tokenA, tokenB oracle price
        priceOracle.setUnderlyingPrice(CToken(address(cMT)), 1);
        priceOracle.setUnderlyingPrice(CToken(address(cYT)), 100);
        // set cTokenB collateral factor
        unitrollerProxy._setCollateralFactor(CToken(address(cMT)), 1 * 1e18);
        unitrollerProxy._setCollateralFactor(CToken(address(cYT)), 5 * 1e17);
        // set close factor, for liquidate
        unitrollerProxy._setCloseFactor(5 * 1e17);
        // set liquidation incentive
        unitrollerProxy._setLiquidationIncentive(108 * 1e16);

        // user
        user1 = makeAddr("User1");
        user2 = makeAddr("User2");

        uint256 initialBalanceA = 10000 * 10 ** MT.decimals();
        uint256 initialBalanceB = 10000 * 10 ** YT.decimals();
        // give user1 tokenA, tokenB
        deal(address(MT), user1, initialBalanceA);
        deal(address(YT), user1, initialBalanceB);

        // give user2 tokenA, tokenB
        deal(address(MT), user2, initialBalanceA);
        deal(address(YT), user2, initialBalanceB);
    }

    function testCompoundMintRedeem() public {
        vm.startPrank(user1);

        // check MT balance of user = 10000
        require(
            ERC20(MT).balanceOf(user1) == 10000 * 10 ** MT.decimals(),
            "invalid balance"
        );
        // user1 approve 100 MT and mint to CMT
        ERC20(MT).approve(address(cMT), 100 * 10 ** MT.decimals());
        cMT.mint(100 * 10 ** cMT.decimals());
        // user1 now MT balance = 9900
        assertEq(ERC20(MT).balanceOf(user1), 9900 * 10 ** MT.decimals());
        // user1 now cMT balance = 100
        assertEq(
            CErc20Delegator(cMT).balanceOf(user1),
            100 * 10 ** cMT.decimals()
        );
        // redeem
        cMT.redeem(100 * 10 ** cMT.decimals());
        // user1 now MT balance = 10000
        assertEq(ERC20(MT).balanceOf(user1), 10000 * 10 ** MT.decimals());
        // user1 now cMT balance = 0
        assertEq(CErc20Delegator(cMT).balanceOf(user1), 0);

        vm.stopPrank();
    }

    function testCompoundBorrowRepay() public {
        // give cTokenA contract tokenA (for borrow)
        deal(address(MT), address(cMT), 10000 * 10 ** MT.decimals());
        vm.startPrank(user1);

        // check YT balance of user1 = 10000
        require(
            ERC20(YT).balanceOf(user1) == 10000 * 10 ** YT.decimals(),
            "invalid balance"
        );
        // user1 approve 1 YT and mint to CYT
        ERC20(YT).approve(address(cYT), 1 * 10 ** YT.decimals());
        cYT.mint(1 * 10 ** cYT.decimals());
        // user1 now cYT balance = 1
        assertEq(
            CErc20Delegator(cYT).balanceOf(user1),
            1 * 10 ** YT.decimals()
        );
        // user1 add cTokenB to his liquidity calculation
        address[] memory addr = new address[](1);
        addr[0] = address(cYT);
        unitrollerProxy.enterMarkets(addr);
        // user1 borrow 50 TokenA
        // price: 1:100
        // cTokenB collateral factor: 0.5
        // so, 1 CTokenB to 50 TokenA)
        uint borrowAmount = 50 * 10 ** MT.decimals();
        cMT.borrow(borrowAmount);
        // user1 now have 10000 + 50 tokenA
        assertEq(
            ERC20(MT).balanceOf(user1),
            10000 * 10 ** MT.decimals() + borrowAmount
        );
        // user1 approve and repay 50 tokenA (no interest)
        ERC20(MT).approve(address(cMT), borrowAmount);
        cMT.repayBorrow(borrowAmount);
        // user1 now have 10000 tokenA
        assertEq(ERC20(MT).balanceOf(user1), 10000 * 10 ** MT.decimals());

        vm.stopPrank();
    }

    function testCompoundLiquidateWithCollateralFactorChange() public {
        // same as test2
        // ==========================================================
        deal(address(MT), address(cMT), 10000 * 10 ** MT.decimals());
        vm.startPrank(user1);
        require(
            ERC20(YT).balanceOf(user1) == 10000 * 10 ** YT.decimals(),
            "invalid balance"
        );
        ERC20(YT).approve(address(cYT), 1 * 10 ** YT.decimals());
        cYT.mint(1 * 10 ** cYT.decimals());
        assertEq(
            CErc20Delegator(cYT).balanceOf(user1),
            1 * 10 ** YT.decimals()
        );
        address[] memory addr = new address[](1);
        addr[0] = address(cYT);
        unitrollerProxy.enterMarkets(addr);
        cMT.borrow(50 * 10 ** MT.decimals());
        assertEq(
            ERC20(MT).balanceOf(user1),
            10000 * 10 ** MT.decimals() + 50 * 10 ** MT.decimals()
        );
        vm.stopPrank();
        // ==========================================================
        // same as test2

        // change collateral factor
        unitrollerProxy._setCollateralFactor(CToken(address(cYT)), 4 * 1e17);
        vm.startPrank(user2);
        // check user1 has excess collateral
        (, , uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        require(shortfall > 0, "account has not excess collateral");
        // prepare MT to do liquidate
        ERC20(MT).approve(address(cMT), 100 * 10 ** MT.decimals());
        // user2 liquidates user1 collateral
        cMT.liquidateBorrow(user1, 25 * 10 ** MT.decimals(), cYT);
        // user2 cYT now > 0
        assertGt(CErc20Delegator(cYT).balanceOf(user2), 0);

        vm.stopPrank();
    }

    function testCompoundLiquidateWithOracleTokenBChange() public {
        // same as test2
        // ==========================================================
        deal(address(MT), address(cMT), 10000 * 10 ** MT.decimals());
        vm.startPrank(user1);
        require(
            ERC20(YT).balanceOf(user1) == 10000 * 10 ** YT.decimals(),
            "invalid balance"
        );
        ERC20(YT).approve(address(cYT), 1 * 10 ** YT.decimals());
        cYT.mint(1 * 10 ** cYT.decimals());
        assertEq(
            CErc20Delegator(cYT).balanceOf(user1),
            1 * 10 ** YT.decimals()
        );
        address[] memory addr = new address[](1);
        addr[0] = address(cYT);
        unitrollerProxy.enterMarkets(addr);
        cMT.borrow(50 * 10 ** MT.decimals());
        assertEq(
            ERC20(MT).balanceOf(user1),
            10000 * 10 ** MT.decimals() + 50 * 10 ** MT.decimals()
        );
        vm.stopPrank();
        // ==========================================================
        // same as test2

        // change oracle tokenB
        priceOracle.setUnderlyingPrice(CToken(address(cYT)), 99);
        vm.startPrank(user2);

        // check user1 has excess collateral
        (, , uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        require(shortfall > 0, "account has not excess collateral");
        // prepare MT to do liquidate
        ERC20(MT).approve(address(cMT), 100 * 10 ** MT.decimals());
        // user2 liquidates user1 collateral
        cMT.liquidateBorrow(user1, 25 * 10 ** MT.decimals(), cYT);
        // user2 cYT now > 0
        assertGt(CErc20Delegator(cYT).balanceOf(user2), 0);

        vm.stopPrank();
    }
}

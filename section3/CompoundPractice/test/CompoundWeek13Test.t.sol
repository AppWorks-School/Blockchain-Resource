// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "test/helper/CompoundWeek13SetUp.sol";

contract CompoundWeek13Test is CompoundWeek13SetUp {

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    uint constant tokenAInitBalance = 100 * 1e18;
    uint constant tokenBInitBalance = 100 * 1e18;

    function setUp() public override {
        super.setUp();
        // Initialize balance
        deal(address(TokenA), user1, tokenAInitBalance);
        deal(address(TokenB), user1, tokenBInitBalance);
        deal(address(TokenA), user2, tokenAInitBalance);
        deal(address(TokenB), user2, tokenBInitBalance);
    }

    function test_mint_redeem() public {
        uint mintAmount = 100 * 10 ** TokenA.decimals();

        vm.startPrank(user1);

        // 1. Approve compound to use TokenA
        TokenA.approve(address(cErc20DelegateA), mintAmount);

        // 2. Mint CToken
        uint success = cErc20DelegateA.mint(mintAmount);
        require(success == 0, "mint fail");
        assertEq(cErc20DelegateA.balanceOf(user1), mintAmount); // exchange rate = 1:1, so CToken = mintAmount

        // 3. Redeem TokenA
        success = cErc20DelegateA.redeemUnderlying(mintAmount);
        require(success == 0, "redeem fail");
        assertEq(mintAmount, TokenA.balanceOf(user1));

        vm.stopPrank();
    }

    function test_borrow_repay() public {
        // 1. Set price of TokenA, TokenB and set TokenB collateral factor
        vm.startPrank(admin);
        simplePriceOracle.setDirectPrice(address(TokenA), 1 * 1e18);
        simplePriceOracle.setDirectPrice(address(TokenB), 100 * 1e18);
        uint success =proxyComptroller._setCollateralFactor(CToken(address(cErc20DelegateB)), 0.5 * 1e18);
        require(success == 9, "set collateral factor fail");
        vm.stopPrank();

        // 2. Mint 1 CTokenB with 1 TokenB
        vm.startPrank(user1);
        uint mintAmount = 1 * 10 ** TokenB.decimals();
        TokenB.approve(address(cErc20DelegateB), mintAmount);
        success = cErc20DelegateB.mint(mintAmount);
        require(success == 0, "mint fail");
        assertEq(cErc20DelegateB.balanceOf(user1), mintAmount);

        // 3. User1 enable CTokenB in market
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cErc20DelegateB);
        uint[] memory successes =proxyComptroller.enterMarkets(cTokens);
        require(successes[0] == 0, "enter market fail");

        // 4. User1 borrow 50 TokenA
        uint borrowAmount = 50 * 10 ** TokenA.decimals();
        success = cErc20DelegateA.borrow(borrowAmount);
        require(success == 0, "borrow fail");
        assertEq(TokenA.balanceOf(user1), tokenAInitBalance + borrowAmount);

        // 5. User1 repay 50 TokenA
        TokenA.approve(address(cErc20DelegateA), borrowAmount);
        success = cErc20DelegateA.repayBorrow(borrowAmount);
        require(success == 0, "repay fail");

        // 6. User1 disable CTokenB in market, no debt left
        success =proxyComptroller.exitMarket(cTokens[0]);
        require(success == 0, "exit market fail");
    }

    function test_liquidate_by_adjust_collateral_factor() public {
        // 1. set price of TokenA, TokenB, TokenB collateral factor, close factor and liquidation incentive
        vm.startPrank(admin);
        simplePriceOracle.setDirectPrice(address(TokenA), 1 * 1e18);
        simplePriceOracle.setDirectPrice(address(TokenB), 100 * 1e18);
        uint success =proxyComptroller._setCollateralFactor(CToken(address(cErc20DelegateB)), 0.5 * 1e18);
        require(success == 0, "set collateral factor fail");
        success =proxyComptroller._setCloseFactor(0.5 * 1e18);
        require(success == 0, "set close factor fail");
        success =proxyComptroller._setLiquidationIncentive(1 * 1e18);
        require(success == 0, "set liquidation incenctive fail");
        vm.stopPrank();

        // 2. Mint 1 CTokenB with 1 TokenB
        vm.startPrank(user1);
        uint mintAmount = 1 * 10 ** TokenB.decimals();
        TokenB.approve(address(cErc20DelegateB), mintAmount);
        success = cErc20DelegateB.mint(mintAmount);
        require(success == 0, "mint fail");
        assertEq(cErc20DelegateB.balanceOf(user1), mintAmount);

        // 3. User1 enable CTokenB in market
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cErc20DelegateB);
        uint[] memory successes =proxyComptroller.enterMarkets(cTokens);
        require(successes[0] == 0, "enter market fail");

        // 4. User1 borrow 50 TokenA
        uint borrowAmount = 50 * 10 ** TokenA.decimals();
        success = cErc20DelegateA.borrow(borrowAmount);
        require(success == 0, "borrow fail");
        assertEq(TokenA.balanceOf(user1), tokenAInitBalance + borrowAmount);
        vm.stopPrank();

        // 5. Compound governance decide to adjust TokenB collater factor to 0.1
        vm.startPrank(admin);
       proxyComptroller._setCollateralFactor(CToken(address(cErc20DelegateB)), 0.1 * 1e18);
        vm.stopPrank();

        // 6. User2 liquidate user1 collateral asset
        vm.startPrank(user2);
        uint closeFactorMantissa =proxyComptroller.closeFactorMantissa();
        uint liquidateAmount = borrowAmount * closeFactorMantissa / 1e18;
        TokenA.approve(address(cErc20DelegateA), liquidateAmount);
        success = cErc20DelegateA.liquidateBorrow(user1, liquidateAmount, cErc20DelegateB);
        require(success == 0, "liquidate fail");

        assertEq(cErc20DelegateB.balanceOf(user2), 0.243 * 1e18);
        vm.stopPrank();
    }

    function test_liquidate_by_adjust_TokenB_price() public {
        // 1. set price of TokenA, TokenB, TokenB collateral factor, close factor and liquidation incentive
        vm.startPrank(admin);
        simplePriceOracle.setDirectPrice(address(TokenA), 1 * 1e18);
        simplePriceOracle.setDirectPrice(address(TokenB), 100 * 1e18);
        uint success =proxyComptroller._setCollateralFactor(CToken(address(cErc20DelegateB)), 0.5 * 1e18);
        require(success == 0, "set collateral factor fail");
        success =proxyComptroller._setCloseFactor(0.5 * 1e18);
        require(success == 0, "set close factor fail");
        success =proxyComptroller._setLiquidationIncentive(1 * 1e18);
        require(success == 0, "set liquidation incenctive fail");
        vm.stopPrank();

        // 2. Mint 1 CTokenB with 1 TokenB
        vm.startPrank(user1);
        uint mintAmount = 1 * 10 ** TokenB.decimals();
        TokenB.approve(address(cErc20DelegateB), mintAmount);
        success = cErc20DelegateB.mint(mintAmount);
        require(success == 0, "mint fail");
        assertEq(cErc20DelegateB.balanceOf(user1), mintAmount);

        // 3. User1 enable CTokenB in market
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cErc20DelegateB);
        uint[] memory successes =proxyComptroller.enterMarkets(cTokens);
        require(successes[0] == 0, "enter market fail");

        // 4. User1 borrow 50 TokenA
        uint borrowAmount = 50 * 10 ** TokenA.decimals();
        success = cErc20DelegateA.borrow(borrowAmount);
        require(success == 0, "borrow fail");
        assertEq(TokenA.balanceOf(user1), tokenAInitBalance + borrowAmount);
        vm.stopPrank();

        // 5. TokenB price drop to 50
        vm.startPrank(admin);
        simplePriceOracle.setDirectPrice(address(TokenB), 50 * 1e18);
        vm.stopPrank();

        // 6. User2 liquidate user1 collateral asset
        vm.startPrank(user2);
        uint closeFactorMantissa =proxyComptroller.closeFactorMantissa();
        uint liquidateAmount = borrowAmount * closeFactorMantissa / 1e18;
        TokenA.approve(address(cErc20DelegateA), liquidateAmount);
        success = cErc20DelegateA.liquidateBorrow(user1, liquidateAmount, cErc20DelegateB);
        require(success == 0, "liquidate fail");

        assertEq(cErc20DelegateB.balanceOf(user2), 0.486 * 1e18);
        vm.stopPrank();
    }
}
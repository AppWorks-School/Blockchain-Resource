// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SimpleSwapSetUp } from "./helper/SimpleSwapSetUp.sol";

contract SimpleSwapAddLiquidityTest is SimpleSwapSetUp {
    function setUp() public override {
        super.setUp();
    }

    function test_revert_addLiquidity_when_tokenA_amount_is_zero() public {
        uint256 amountA = 0;
        uint256 amountB = 42 * 10 ** tokenBDecimals;
        vm.prank(maker);
        vm.expectRevert("SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        simpleSwap.addLiquidity(amountA, amountB);
    }

    function test_revert_addLiquidity_when_tokenB_amount_is_zero() public {
        uint256 amountA = 42 * 10 ** tokenADecimals;
        uint256 amountB = 0;
        vm.prank(maker);
        vm.expectRevert("SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        simpleSwap.addLiquidity(amountA, amountB);
    }

    function test_addLiquidity_should_add_liquidity() public {
        uint256 amountA = 42 * 10 ** tokenADecimals;
        uint256 amountB = 420 * 10 ** tokenBDecimals;
        uint256 liquidity = Math.sqrt(amountA * amountB);

        vm.startPrank(maker);
        vm.expectEmit(true, true, true, true);

        // reverse because tokenB is smaller than tokenA in decimals
        emit AddLiquidity(maker, amountA, amountB, liquidity);
        simpleSwap.addLiquidity(amountA, amountB);
        assertEq(tokenA.balanceOf(address(maker)), 1000 * 10 ** tokenADecimals - amountA);
        assertEq(tokenB.balanceOf(address(maker)), 1000 * 10 ** tokenBDecimals - amountB);

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        assertEq(reserveA, amountA);
        assertEq(reserveB, amountB);
        vm.stopPrank();
    }
}

contract SimpleSwapAddLiquidityAfterInitial is SimpleSwapSetUp {
    uint256 reserveAAfterFirstAddLiquidity;
    uint256 reserveBAfterFirstAddLiquidity;

    function setUp() public override {
        super.setUp();
        uint256 amountA = 45 * (10 ** tokenADecimals);
        uint256 amountB = 20 * 10 ** tokenBDecimals;
        vm.prank(maker);
        simpleSwap.addLiquidity(amountA, amountB);
        (reserveAAfterFirstAddLiquidity, reserveBAfterFirstAddLiquidity) = simpleSwap.getReserves();
    }

    function test_revert_addLiquidity_when_tokenA_amount_is_zero() public {
        uint256 amountA = 0;
        uint256 amountB = 42 * 10 ** tokenBDecimals;
        vm.prank(maker);
        vm.expectRevert("SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        simpleSwap.addLiquidity(amountA, amountB);
    }

    function test_revert_addLiquidity_when_tokenB_amount_is_zero() public {
        uint256 amountA = 42 * 10 ** tokenADecimals;
        uint256 amountB = 0;
        vm.prank(maker);
        vm.expectRevert("SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        simpleSwap.addLiquidity(amountA, amountB);
    }

    function test_addLiquidity_should_add_liquidity_when_tokenA_proportion_is_the_same_as_tokenB_proportion() public {
        uint256 amountA = 90 * 10 ** tokenADecimals;
        uint256 amountB = 40 * 10 ** tokenBDecimals;
        uint256 liquidity = Math.sqrt(amountA * amountB);

        uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
        uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(maker);
        vm.expectEmit(true, true, true, true);

        emit AddLiquidity(maker, amountA, amountB, liquidity);
        simpleSwap.addLiquidity(amountA, amountB);
        assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore - amountA);
        assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore - amountB);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore + amountA);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore + amountB);

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        assertEq(reserveA, reserveAAfterFirstAddLiquidity + amountA);
        assertEq(reserveB, reserveBAfterFirstAddLiquidity + amountB);
        vm.stopPrank();
    }

    function test_addLiquidity_should__add_liquidity_when_tokenA_proportion_is_greaterthan_tokenB_proportion() public {
        uint256 amountA = 90 * 10 ** tokenADecimals;
        uint256 amountB = 50 * 10 ** tokenBDecimals;
        uint256 actualAmountB = (amountA * reserveBAfterFirstAddLiquidity) / reserveAAfterFirstAddLiquidity;
        uint256 liquidity = Math.sqrt(amountA * actualAmountB);

        uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
        uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(maker);
        vm.expectEmit(true, true, true, true);

        emit AddLiquidity(maker, amountA, actualAmountB, liquidity);
        simpleSwap.addLiquidity(amountA, amountB);
        assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore - amountA);
        assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore - actualAmountB);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore + amountA);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore + actualAmountB);

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        assertEq(reserveA, reserveAAfterFirstAddLiquidity + amountA);
        assertEq(reserveB, reserveBAfterFirstAddLiquidity + actualAmountB);
        vm.stopPrank();
    }

    function test_addLiquidity_should__add_liquidity_when_tokenA_proportion_is_lessthan_tokenB_proportion() public {
        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 40 * 10 ** tokenBDecimals;
        uint256 actualAmountA = (amountB * reserveAAfterFirstAddLiquidity) / reserveBAfterFirstAddLiquidity;
        uint256 liquidity = Math.sqrt(actualAmountA * amountB);

        uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
        uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(maker);
        vm.expectEmit(true, true, true, true);

        emit AddLiquidity(maker, actualAmountA, amountB, liquidity);
        simpleSwap.addLiquidity(amountA, amountB);
        assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore - actualAmountA);
        assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore - amountB);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore + actualAmountA);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore + amountB);

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        assertEq(reserveA, reserveAAfterFirstAddLiquidity + actualAmountA);
        assertEq(reserveB, reserveBAfterFirstAddLiquidity + amountB);
        vm.stopPrank();
    }

    function test_addLiquidity_should_be_able_to_add_liquidity_after_swap() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(tokenB);
        uint256 amountIn = 45 * (10 ** tokenADecimals);
        uint256 reserveAAfterSwap;
        uint256 reserveBAfterSwap;

        vm.startPrank(maker);
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
        (reserveAAfterSwap, reserveBAfterSwap) = simpleSwap.getReserves();

        uint256 amountA = 18 * 10 ** tokenADecimals;
        uint256 amountB = 2 * 10 ** tokenBDecimals;
        uint256 totalSupply = simpleSwap.totalSupply();

        {
            uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
            uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
            uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
            uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

            uint256 liquidityA = (amountA * totalSupply) / reserveAAfterSwap;
            uint256 liquidityB = (amountB * totalSupply) / reserveBAfterSwap;
            uint256 liquidity = (liquidityA < liquidityB) ? liquidityA : liquidityB;

            vm.expectEmit(true, true, true, true);
            emit AddLiquidity(maker, amountA, amountB, liquidity);
            simpleSwap.addLiquidity(amountA, amountB);
            assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore - amountA);
            assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore - amountB);
            assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore + amountA);
            assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore + amountB);
        }

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        assertEq(reserveA, reserveAAfterSwap + amountA);
        assertEq(reserveB, reserveBAfterSwap + amountB);
        vm.stopPrank();
    }
}

contract SimpleSwapRemoveLiquidity is SimpleSwapSetUp {
    function setUp() public override {
        super.setUp();

        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 100 * 10 ** tokenBDecimals;

        vm.startPrank(maker);
        simpleSwap.approve(address(simpleSwap), uint256(2 ** 256 - 1));
        simpleSwap.addLiquidity(amountA, amountB);
        vm.stopPrank();
    }

    function test_revert_removeLiquidity_when_lp_token_balance_is_zero() public {
        vm.expectRevert("SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");
        vm.prank(maker);
        simpleSwap.removeLiquidity(0);
    }

    function test_removeLiquidity_should_remove_liquidity_when_lp_token_balance_greaterthan_zero() public {
        uint256 lpTokenAmount = 10 * 10 ** slpDecimals;
        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        uint256 totalSupply = simpleSwap.totalSupply();
        uint256 amountA = (lpTokenAmount * reserveA) / totalSupply;
        uint256 amountB = (lpTokenAmount * reserveB) / totalSupply;

        uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
        uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(maker);
        emit RemoveLiquidity(maker, amountA, amountB, lpTokenAmount);
        simpleSwap.removeLiquidity(lpTokenAmount);
        assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore + amountA);
        assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore + amountB);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore - amountA);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore - amountB);
        vm.stopPrank();
    }

    function test_removeLiquidity_should_remove_liquidity_after_swap() public {
        vm.prank(taker);
        simpleSwap.swap(address(tokenA), address(tokenB), 10 * (10 ** tokenADecimals));

        uint256 lpTokenAmount = 10 * 10 ** slpDecimals;
        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();
        uint256 totalSupply = simpleSwap.totalSupply();
        uint256 amountA = (lpTokenAmount * reserveA) / totalSupply;
        uint256 amountB = (lpTokenAmount * reserveB) / totalSupply;

        uint256 makerBalanceABefore = tokenA.balanceOf(address(maker));
        uint256 makerBalanceBBefore = tokenB.balanceOf(address(maker));
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(maker);
        emit RemoveLiquidity(maker, amountA, amountB, lpTokenAmount);
        simpleSwap.removeLiquidity(lpTokenAmount);
        assertEq(tokenA.balanceOf(address(maker)), makerBalanceABefore + amountA);
        assertEq(tokenB.balanceOf(address(maker)), makerBalanceBBefore + amountB);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore - amountA);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore - amountB);
        vm.stopPrank();
    }
}

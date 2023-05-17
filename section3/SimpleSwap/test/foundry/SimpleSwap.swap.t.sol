// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { SimpleSwapSetUp } from "./helper/SimpleSwapSetUp.sol";

contract SimpleSwapSwapTest is SimpleSwapSetUp {
    function setUp() public override {
        super.setUp();
        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 100 * 10 ** tokenBDecimals;
        vm.prank(maker);
        simpleSwap.addLiquidity(amountA, amountB);
    }

    function test_revert_when_tokenIn_is_not_tokenA_or_tokenB() public {
        address tokenIn = address(0);
        address tokenOut = address(tokenB);
        uint256 amountIn = 10 * 10 ** tokenADecimals;

        vm.prank(taker);
        vm.expectRevert("SimpleSwap: INVALID_TOKEN_IN");
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
    }

    function test_revert_when_tokenOut_is_not_tokenA_or_tokenB() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(0);
        uint256 amountIn = 10 * 10 ** tokenADecimals;

        vm.prank(taker);
        vm.expectRevert("SimpleSwap: INVALID_TOKEN_OUT");
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
    }

    function test_revert_when_tokenIn_is_the_same_as_tokenOut() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(tokenA);
        uint256 amountIn = 10 * 10 ** tokenADecimals;

        vm.prank(taker);
        vm.expectRevert("SimpleSwap: IDENTICAL_ADDRESS");
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
    }

    function test_revert_when_amountIn_is_zero() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(tokenB);
        uint256 amountIn = 0;

        vm.prank(taker);
        vm.expectRevert("SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
    }

    function test_should_be_able_to_swap_from_tokenA_to_tokenB() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(tokenB);
        uint256 amountIn = 100 * 10 ** tokenADecimals;
        uint256 amountOut = 50 * 10 ** tokenBDecimals;

        uint256 takerBalanceABefore = tokenA.balanceOf(taker);
        uint256 takerBalanceBBefore = tokenB.balanceOf(taker);
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(taker);
        vm.expectEmit(true, true, true, true);
        emit Swap(taker, tokenIn, tokenOut, amountIn, amountOut);
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
        assertEq(tokenA.balanceOf(address(taker)), takerBalanceABefore - amountIn);
        assertEq(tokenB.balanceOf(address(taker)), takerBalanceBBefore + amountOut);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore + amountIn);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore - amountOut);
        vm.stopPrank();
    }

    function test_should_be_able_to_swap_from_tokenB_to_tokenA() public {
        address tokenIn = address(tokenB);
        address tokenOut = address(tokenA);
        uint256 amountIn = 100 * 10 ** tokenBDecimals;
        uint256 amountOut = 50 * 10 ** tokenADecimals;

        uint256 takerBalanceABefore = tokenA.balanceOf(taker);
        uint256 takerBalanceBBefore = tokenB.balanceOf(taker);
        uint256 simpleSwapBalanceABefore = tokenA.balanceOf(address(simpleSwap));
        uint256 simpleSwapBalanceBBefore = tokenB.balanceOf(address(simpleSwap));

        vm.startPrank(taker);
        vm.expectEmit(true, true, true, true);
        emit Swap(taker, tokenIn, tokenOut, amountIn, amountOut);
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
        assertEq(tokenA.balanceOf(address(taker)), takerBalanceABefore + amountOut);
        assertEq(tokenB.balanceOf(address(taker)), takerBalanceBBefore - amountIn);
        assertEq(tokenA.balanceOf(address(simpleSwap)), simpleSwapBalanceABefore - amountOut);
        assertEq(tokenB.balanceOf(address(simpleSwap)), simpleSwapBalanceBBefore + amountIn);
        vm.stopPrank();
    }
}

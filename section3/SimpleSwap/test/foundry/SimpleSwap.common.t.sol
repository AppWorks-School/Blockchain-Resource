// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { SimpleSwapSetUp } from "./helper/SimpleSwapSetUp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleSwapGetterTest is SimpleSwapSetUp {
    function setUp() public override {
        super.setUp();
    }

    function test_getReserve() public {
        uint256 reserveA;
        uint256 reserveB;

        (reserveA, reserveB) = simpleSwap.getReserves();

        assertEq(reserveA, 0);
        assertEq(reserveB, 0);
    }

    function test_getReserve_after_add_liquidity() public {
        uint256 reserveA;
        uint256 reserveB;
        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 100 * 10 ** tokenBDecimals;

        vm.prank(taker);
        simpleSwap.addLiquidity(amountA, amountB);

        (reserveA, reserveB) = simpleSwap.getReserves();

        assertEq(reserveA, amountA);
        assertEq(reserveB, amountB);
    }

    function test_getTokenA() public {
        assertEq(simpleSwap.getTokenA(), address(tokenA));
    }

    function test_getTokenB() public {
        assertEq(simpleSwap.getTokenB(), address(tokenB));
    }
}

contract SimpleSwapLpTokenTest is SimpleSwapSetUp {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public override {
        super.setUp();

        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 100 * 10 ** tokenBDecimals;

        vm.startPrank(maker);

        simpleSwap.addLiquidity(amountA, amountB);
        simpleSwap.approve(address(simpleSwap), type(uint256).max);

        vm.stopPrank();
    }

    function test_lpToken_after_adding_liquidity() public {
        uint256 amountA = 100 * 10 ** tokenADecimals;
        uint256 amountB = 100 * 10 ** tokenBDecimals;
        uint256 liquidity = Math.sqrt(amountA * amountB);
        uint256 makerBalance = simpleSwap.balanceOf(maker);

        vm.startPrank(maker);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), maker, liquidity);
        simpleSwap.addLiquidity(amountA, amountB);

        assertEq(simpleSwap.balanceOf(maker), liquidity + makerBalance);

        vm.stopPrank();
    }

    function test_lpToken_after_removing_liquidity() public {
        uint256 lpTokenAmount = 10 * 10 ** slpDecimals;
        uint256 makerBalance = simpleSwap.balanceOf(maker);

        vm.startPrank(maker);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(simpleSwap), address(0), lpTokenAmount);
        simpleSwap.removeLiquidity(lpTokenAmount);

        assertEq(simpleSwap.balanceOf(maker), makerBalance - lpTokenAmount);

        vm.stopPrank();
    }

    function test_lpToken_should_be_able_to_transfer() public {
        uint256 lpTokenAmount = 42 * 10 ** slpDecimals;

        vm.startPrank(maker);

        vm.expectEmit(true, true, true, true);
        emit Transfer(maker, taker, lpTokenAmount);
        simpleSwap.transfer(taker, lpTokenAmount);

        vm.stopPrank();
    }

    function test_lpToken_should_be_able_to_approve() public {
        uint256 lpTokenAmount = 42 * 10 ** slpDecimals;

        vm.startPrank(maker);

        vm.expectEmit(true, true, true, true);
        emit Approval(maker, taker, lpTokenAmount);
        simpleSwap.approve(taker, lpTokenAmount);

        vm.stopPrank();
    }
}

contract SimpleSwapKValueCheck is SimpleSwapSetUp {
    uint256 public k;

    function setUp() public override {
        super.setUp();
        uint256 amountA = 30 * 10 ** tokenADecimals;
        uint256 amountB = 300 * 10 ** tokenBDecimals;
        vm.prank(maker);
        simpleSwap.addLiquidity(amountA, amountB);
        k = amountA * amountB;
    }

    function test_kValue_should_greater_than_eq_original_kValue_after_multiple_swaps() public {
        address tokenIn = address(tokenA);
        address tokenOut = address(tokenB);
        uint256 amountIn = 70 * 10 ** tokenADecimals;

        vm.startPrank(taker);

        simpleSwap.swap(tokenIn, tokenOut, amountIn);
        simpleSwap.swap(tokenIn, tokenOut, amountIn);
        simpleSwap.swap(tokenIn, tokenOut, amountIn);

        vm.stopPrank();

        uint256 reserveA;
        uint256 reserveB;
        (reserveA, reserveB) = simpleSwap.getReserves();

        assertGe(reserveA * reserveB, k);
    }
}

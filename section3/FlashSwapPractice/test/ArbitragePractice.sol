// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { Arbitrage } from "../contracts/Arbitrage.sol";
import { FlashSwapSetUp } from "./helper/FlashSwapSetUp.sol";

contract ArbitragePracticeTest is FlashSwapSetUp {
    Arbitrage public arbitrage;
    address maker = makeAddr("Maker");

    function setUp() public override {
        super.setUp();

        // mint 100 ETH, 10000 USDC to maker
        vm.deal(maker, 100 ether);
        usdc.mint(maker, 10_000 * 10 ** usdc.decimals());

        // maker provide liquidity to wethUsdcPool, wethUsdcSushiPool
        vm.startPrank(maker);
        // maker provide 50 ETH, 4000 USDC to wethUsdcPool
        usdc.approve(address(uniswapV2Router), 4_000 * 10 ** usdc.decimals());
        uniswapV2Router.addLiquidityETH{ value: 50 ether }(
            address(usdc),
            4_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );

        // maker provide 50 ETH, 6000 USDC to wethUsdcSushiPool
        usdc.approve(address(sushiSwapV2Router), 6_000 * 10 ** usdc.decimals());
        sushiSwapV2Router.addLiquidityETH{ value: 50 ether }(
            address(usdc),
            6_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        vm.stopPrank();

        // deploy arbitrage contract
        arbitrage = new Arbitrage();
    }

    // Uni pool price is 1 ETH = 80 USDC (lower price pool)
    // Sushi pool price is 1 ETH = 120 USDC (higher price pool)
    // We can arbitrage between these two pools
    // Method 1 is
    //  - borrow WETH from lower price pool
    //  - swap WETH for USDC in higher price pool
    //  - repay USDC to lower pool
    // Method 2 is
    //  - borrow USDC from higher price pool
    //  - swap USDC for WETH in lower pool
    //  - repay WETH to higher pool
    // for testing convenient, we implement the method 1 here, and the exact WETH borrow amount is 5 WETH
    function test_arbitrage_with_flash_swap() public {
        uint256 borrowETH = 5 ether;
        // token0 is WETH, token1 is USDC
        arbitrage.arbitrage(address(wethUsdcPool), address(wethUsdcSushiPool), borrowETH);

        // we can earn 98.184746 with 5 ETH flash swap
        assertEq(usdc.balanceOf(address(arbitrage)), 98184746);
    }
}

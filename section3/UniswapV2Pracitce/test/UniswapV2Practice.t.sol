// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { UniswapV2SetUp } from "./helper/UniswapV2SetUp.sol";

contract UniswapV2PracticeTest is UniswapV2SetUp {
    address maker = makeAddr("Maker");
    address taker = makeAddr("Taker");

    function setUp() public override {
        super.setUp();

        // mint 100ETH, 10000 USDC to maker
        deal(maker, 100 ether);
        usdc.mint(maker, 10000 ** usdc.decimals());

        // maker provide 100ETH
        vm.startPrank(address(maker));
        usdc.approve(address(uniswapV2Router), 10000 ** usdc.decimals());
        uniswapV2Router.addLiquidityETH{ value: 100 ether }(
            address(usdc),
            10000 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        vm.stopPrank();

        // mint 1000 USDC to taker
        usdc.mint(taker, 1000 * usdc.decimals());
    }

    function test_swapExactETHForTokens() public {}

    function test_addLiquidityETH() public {}

    function test_removeLiquidityETH() public {}

    function test_swapExactTokensForETH() public {}
}

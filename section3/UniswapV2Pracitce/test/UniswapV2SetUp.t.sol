// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { UniswapV2SetUp } from "./helper/UniswapV2SetUp.sol";

contract UniswapV2SetUpTest is UniswapV2SetUp {
    function setUp() public override {
        super.setUp();
    }

    function test_factory_address_not_zero() public {
        assertEq(address(uniswapV2Factory) != address(0), true);
    }

    function test_factory_feeTo_eq_zero() public {
        address feeTo = uniswapV2Factory.feeTo();
        assertEq(feeTo == address(0), true);
    }

    function test_router_factory_address() public {
        assertEq(uniswapV2Router.factory(), address(uniswapV2Factory));
    }

    function test_router_weth9() public {
        assertEq(uniswapV2Router.WETH(), address(weth));
    }

    function test_weth_usdc_pool() public {
        assertEq(wethUsdcPool.token0(), address(weth));
        assertEq(wethUsdcPool.token1(), address(usdc));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { FlashSwapSetUp } from "./helper/FlashSwapSetUp.sol";
import { FakeLendingProtocol } from "../contracts/FakeLendingProtocol.sol";
import { Liquidator } from "../contracts/Liquidator.sol";

contract FlashSwapPracticeTest is FlashSwapSetUp {
    FakeLendingProtocol fakeLendingProtocol;
    Liquidator liquidator;

    address maker = makeAddr("Maker");

    function setUp() public override {
        super.setUp();

        // mint 100 ETH, 10000 USDC to maker
        vm.deal(maker, 100 ether);
        usdc.mint(maker, 10_000 * 10 ** usdc.decimals());

        // maker provide 100 ETH, 10000 USDC to wethUsdcPool
        vm.startPrank(maker);
        usdc.approve(address(uniswapV2Router), 10_000 * 10 ** usdc.decimals());
        uniswapV2Router.addLiquidityETH{ value: 100 ether }(
            address(usdc),
            10_000 * 10 ** usdc.decimals(),
            0,
            0,
            maker,
            block.timestamp
        );
        vm.stopPrank();

        // deploy fake lending protocol
        fakeLendingProtocol = new FakeLendingProtocol{ value: 1 ether }(address(usdc));

        // deploy liquidator
        liquidator = new Liquidator(address(fakeLendingProtocol), address(uniswapV2Router), address(uniswapV2Factory));
    }

    function test_flash_swap() public {
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(usdc);

        liquidator.liquidate(path, 80 * 10 ** usdc.decimals());

        uint256 profit = address(liquidator).balance;
        assertEq(profit, 191121752353835700);
    }
}

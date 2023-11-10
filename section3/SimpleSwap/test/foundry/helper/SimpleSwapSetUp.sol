// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import { Test } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TestERC20 } from "../../../contracts/test/TestERC20.sol";
import { SimpleSwap } from "../../../contracts/SimpleSwap.sol";
import { ISimpleSwapEvent } from "../../../contracts/interface/ISimpleSwap.sol";

contract SimpleSwapSetUp is Test, ISimpleSwapEvent {
    address public taker = makeAddr("taker");
    address public maker = makeAddr("maker");

    TestERC20 public tokenA;
    TestERC20 public tokenB;
    uint256 public tokenADecimals;
    uint256 public tokenBDecimals;
    uint256 public slpDecimals;

    SimpleSwap public simpleSwap;

    function setUp() public virtual {
        tokenB = new TestERC20("token B", "TKB");
        tokenA = new TestERC20("token A", "TKA");

        tokenADecimals = tokenA.decimals();
        tokenBDecimals = tokenB.decimals();
        simpleSwap = new SimpleSwap(address(tokenA), address(tokenB));
        slpDecimals = simpleSwap.decimals();

        tokenA.mint(taker, 1000 * 10 ** tokenADecimals);
        tokenA.mint(maker, 1000 * 10 ** tokenADecimals);
        tokenB.mint(taker, 1000 * 10 ** tokenBDecimals);
        tokenB.mint(maker, 1000 * 10 ** tokenBDecimals);

        vm.startPrank(taker);
        tokenA.approve(address(simpleSwap), 1000 * 10 ** tokenADecimals);
        tokenB.approve(address(simpleSwap), 1000 * 10 ** tokenADecimals);
        vm.stopPrank();

        vm.startPrank(maker);
        tokenA.approve(address(simpleSwap), 1000 * 10 ** tokenADecimals);
        tokenB.approve(address(simpleSwap), 1000 * 10 ** tokenADecimals);
        vm.stopPrank();

        vm.label(address(tokenA), "tokenA");
        vm.label(address(tokenB), "tokenB");
    }
}

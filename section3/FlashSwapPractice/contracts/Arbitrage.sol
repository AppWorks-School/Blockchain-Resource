// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Callee } from "v2-core/interfaces/IUniswapV2Callee.sol";

// This is a practice contract for flash swap arbitrage
contract Arbitrage is IUniswapV2Callee, Ownable {

    struct CallbackData {
        address priceLowerPool;
        address priceHigherPool;
        uint256 borrowETH;
        uint256 repayLowerPoolUSDC;
        uint256 borrowHigherPoolUSDC;
    } 

    //
    // EXTERNAL NON-VIEW ONLY OWNER
    //

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Withdraw failed");
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Withdraw failed");
    }

    //
    // EXTERNAL NON-VIEW
    //

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(sender == address(this), "Sender is not this contract");
        require(amount0 > 0 || amount1 > 0, "amount0 or amount1 should greater than zero");
        
        CallbackData memory callbackData = abi.decode(data, (CallbackData));
        require(msg.sender == callbackData.priceLowerPool, "msg.sender is not priceLowerPool");

        // token0 是 WETH
        address token0 = IUniswapV2Pair(callbackData.priceLowerPool).token0();
        // 用 WETH 去 priceHigherPool 換出 USDC
        IERC20(token0).transfer(callbackData.priceHigherPool, callbackData.borrowETH);
        IUniswapV2Pair(callbackData.priceHigherPool).swap(0, callbackData.borrowHigherPoolUSDC, address(this), "");
        // 還 USDC 給 priceLowerPool
        address token1 = IUniswapV2Pair(callbackData.priceLowerPool).token1();
        IERC20(token1).transfer(callbackData.priceLowerPool, callbackData.repayLowerPoolUSDC);
    }

    // Method 1 is
    //  - borrow WETH from lower price pool
    //  - swap WETH for USDC in higher price pool
    //  - repay USDC to lower pool
    // Method 2 is
    //  - borrow USDC from higher price pool
    //  - swap USDC for WETH in lower pool
    //  - repay WETH to higher pool
    // for testing convenient, we implement the method 1 here
    function arbitrage(address priceLowerPool, address priceHigherPool, uint256 borrowETH) external {
        // 1. 計算在需提供多少 USDC 去 lower price pool 借出 borrowETH 
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(priceLowerPool).getReserves();
        uint256 amountIn = _getAmountIn(borrowETH, uint256(reserve1), uint256(reserve0));

        // 2. 計算用 borrowETH 在 higher price pool 可以換多少 USDC
        (reserve0, reserve1,) = IUniswapV2Pair(priceHigherPool).getReserves();
        uint256 amountOut = _getAmountOut(borrowETH, uint256(reserve0), uint256(reserve1));
        
        CallbackData memory callbackData = CallbackData({
            priceLowerPool: priceLowerPool,
            priceHigherPool: priceHigherPool,
            borrowETH: borrowETH,
            repayLowerPoolUSDC: amountIn,
            borrowHigherPoolUSDC: amountOut
        });
        IUniswapV2Pair(priceLowerPool).swap(borrowETH, 0, address(this), abi.encode(callbackData));
    }

    //
    // INTERNAL PURE
    //

    // copy from UniswapV2Library
    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

    // copy from UniswapV2Library
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}

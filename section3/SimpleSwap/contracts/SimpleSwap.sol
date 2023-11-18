// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    address private _tokenA;
    address private _tokenB;
    address public token0;
    address public token1;
    uint256 private reserve0;
    uint256 private reserve1;

    constructor(address tokenA, address tokenB) ERC20("SimpleSwap", "ss") {
        require(tokenA != tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        require(tokenA.code.length > 0, "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(tokenB.code.length > 0, "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "SimpleSwap: ZERO_ADDRESS");
        _tokenA = tokenA;
        _tokenB = tokenB;
    }

    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == _tokenA || tokenIn == _tokenB, "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == _tokenA || tokenOut == _tokenB, "SimpleSwap: INVALID_TOKEN_OUT");
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        amountOut = getAmountOut(tokenIn, amountIn);
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        (uint256 amount0Out, uint256 amount1Out) = tokenIn == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
        _swap(amount0Out, amount1Out, msg.sender);

        emit Swap(msg.sender, tokenIn,tokenOut, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(
        uint256 amountAIn,
        uint256 amountBIn
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(amountAIn > 0 && amountBIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        (uint reserveA, uint reserveB) = this.getReserves();
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountAIn, amountBIn);
        } else {
            uint amountBOptimal = quote(amountAIn, reserveA, reserveB);
            if (amountBOptimal <= amountBIn) {
                (amountA, amountB) = (amountAIn, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBIn, reserveB, reserveA);
                assert(amountAOptimal <= amountAIn);
                (amountA, amountB) = (amountAOptimal, amountBIn);
            }
        }
        IERC20(_tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), amountB);
        liquidity = mint(msg.sender);
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {
        require(liquidity > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");
        _spendAllowance(msg.sender, address(this), liquidity);
        _transfer(msg.sender, address(this), liquidity);

        address tokenA = _tokenA;
        address tokenB = _tokenB;
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));
        uint256 _totalSupply = totalSupply();
        (amountA, amountB) = (balanceA * liquidity / _totalSupply, balanceB * liquidity / _totalSupply);
        _burn(address(this), liquidity);
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        _update(balance0, balance1);
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    function getReserves() external view returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = _getReserves(_tokenA);
    }

    function getTokenA() external view returns (address tokenA) {
        tokenA = token0; 
    }

    function getTokenB() external view returns (address tokenB) {
        tokenB = token1;
    }

    function mint(address to) internal returns (uint liquidity) {
        (uint256 _reserve0, uint256 _reserve1) = (reserve0, reserve1);
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - _reserve0;
        uint amount1 = balance1 - _reserve1;

        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0*amount1);
        } else {
            liquidity = Math.min(amount0 * _totalSupply / _reserve0, amount1 * _totalSupply / _reserve1);
        }
        require(liquidity > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1);
    }

    function getAmountOut(address tokenIn, uint256 amountIn) internal view returns (uint256 amountOut) {
        (uint256 reserveIn, uint256 reserveout) = _getReserves(tokenIn);
        uint256 numerator = amountIn * reserveout;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    function _swap(uint256 amount0Out, uint256 amount1Out, address to) private {
        require(amount0Out > 0 || amount1Out > 0, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint256 _reserve0, uint256 _reserve1) = (reserve0, reserve1);
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "SimpleSwap: INSUFFICIENT_LIQUIDITY");

        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "SimpleSwap: INVALID_TO");
            if (amount0Out > 0) IERC20(_token0).transfer(to, amount0Out);
            if (amount1Out > 0) IERC20(_token1).transfer(to, amount1Out);
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        require(balance0*balance1 >= _reserve0*_reserve1, "SimpleSwap: K");
        
        _update(balance0, balance1);
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = balance0;
        reserve1 = balance1;
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "INSUFFICIENT_LIQUIDITY");
        amountB = (amountA*reserveB) / reserveA;
    }

    function _getReserves(address tokenA) private view returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
}

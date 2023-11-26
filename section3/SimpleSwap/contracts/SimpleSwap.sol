// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    // Implement core logic here
    address _tokenA;
    address _tokenB;
    uint256 _reserveA;
    uint256 _reserveB;

    // ERC20 constructor
    constructor(address tokenA, address tokenB) ERC20("LPToken", "LPT") {
        require(_isContract(tokenA), "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(_isContract(tokenB), "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(tokenA != tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");

        // sort the tokens
        (_tokenA, _tokenB) = (tokenA > tokenB) ? (tokenB, tokenA) : (tokenA, tokenB);
    }

    // ISimpleSwap functions
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == _tokenA || tokenIn == _tokenB, "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == _tokenA || tokenOut == _tokenB, "SimpleSwap: INVALID_TOKEN_OUT");
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(amountIn != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        if (tokenIn == _tokenA) {
            // Kbefore = _reserveA * _reserveB
            // Kafter = (_reserveA + amountIn) * (_reserveB - amountOut)
            // wrong, amountOut may more than expected, may induce Kafter < Kbefore
            // amountOut = _reserveB - (_reserveA * _reserveB / (_reserveA + amountIn)); 

            // correct, amountOut is always less than expected, Kafter > Kbefore
            amountOut = amountIn * _reserveB / (_reserveA + amountIn);
            _update(_reserveA + amountIn, _reserveB - amountOut);
        } else {
            // amountOut = _reserveA - (_reserveA * _reserveB / (_reserveB + amountIn));
             amountOut = amountIn * _reserveA / (_reserveB + amountIn);
            _update(_reserveA - amountIn, _reserveB + amountOut);
        }

        // transfer tokenIn from msg.sender to pool
        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // transfer tokenOut from pool to msg.sender
        ERC20(tokenOut).transfer(msg.sender, amountOut);

        // emit swap event
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
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
        require(amountAIn != 0 && amountBIn != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        // calculate amountA and amountB
        if (_reserveA == 0 && _reserveB == 0) {
            // first time to add liquidity
            (amountA, amountB) = (amountAIn, amountBIn);
        } else {
            amountA = amountAIn;
            amountB = amountA * _reserveB / _reserveA;
            if (amountBIn < amountB) {
                amountB = amountBIn;
                amountA = amountB * _reserveA / _reserveB;
            }
        }

        // liquidity = sqrt(amountA * amountB)
        liquidity = Math.sqrt(amountA * amountB);

        // transfer token A & token B from maker to pool
        ERC20(_tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(_tokenB).transferFrom(msg.sender, address(this), amountB);

        // mint LP token to maker
        _mint(msg.sender, liquidity);

        // update reserves
        _update(_reserveA + amountA, _reserveB + amountB);

        // emit AddLiquidity event
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {
        require(liquidity != 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");

        // calculate amountA and amountB
        amountA = liquidity * _reserveA / totalSupply();
        amountB = liquidity * _reserveB / totalSupply();

        // transfer LP token from maker to pool
        // this.transferFrom(msg.sender, address(this), liquidity);
        _transfer(msg.sender, address(this), liquidity);

        // burn LP tokens
        _burn(address(this), liquidity);

        // transfer token A & token B from pool to maker
        ERC20(_tokenA).transfer(msg.sender, amountA);
        ERC20(_tokenB).transfer(msg.sender, amountB);

        // update reserves
        _update(_reserveA - amountA, _reserveB - amountB);

        // emit RemoveLiquidity event
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB) {
        return (_reserveA, _reserveB);
    }

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view returns (address tokenA) {
        return _tokenA;
    }

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view returns (address tokenB) {
        return _tokenB;
    }


    // private functions
    function _isContract(address _addr) private view returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _update(uint256 amountA, uint256 amountB) private {
        _reserveA = amountA;
        _reserveB = amountB;
    }
}
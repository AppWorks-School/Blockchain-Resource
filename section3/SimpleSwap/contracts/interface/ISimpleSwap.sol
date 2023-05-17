// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISimpleSwapEvent {
    /// @param sender The address of the msg sender
    /// @param amountA The amount of tokenA to add liquidity
    /// @param amountB The amount of tokenB to add liquidity
    /// @param liquidity The amount of liquidity to mint
    event AddLiquidity(address indexed sender, uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @param sender The address of the msg sender
    /// @param amountA The amount of tokenA to remove liquidity
    /// @param amountB The amount of tokenB to remove liquidity
    /// @param liquidity The amount of liquidity to burn
    event RemoveLiquidity(address indexed sender, uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @param sender The address of the msg sender
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @param amountOut The amount of tokenOut to receive
    event Swap(
        address indexed sender,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
}

interface ISimpleSwap is ISimpleSwapEvent {
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut);

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(
        uint256 amountAIn,
        uint256 amountBIn
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB);

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB);

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view returns (address tokenA);

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view returns (address tokenB);
}

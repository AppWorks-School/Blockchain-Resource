pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IUniswapV2Callee} from "v2-core/interfaces/IUniswapV2Callee.sol";
import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {CErc20} from "compound-protocol/contracts/CErc20.sol";


contract FlashSwapLiquidate is IUniswapV2Callee {
  IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  CErc20 public cDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
  IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Factory public factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

  struct CallbackData {
    address borrower;
    address tokenIn;
    address tokenOut;
    uint256 amountIn; // repay amount
    uint256 amountOut; // borrow amount
  }

  
  function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
    // TODO
    require(sender == address(this), "Sender must be this contract");
    require(amount0 > 0 || amount1 > 0, "Amount must be greater than 0");

    // // 4. decode callback data
    CallbackData memory callbackData = abi.decode(data, (CallbackData));

    // // 5. call liquidation
    IERC20(callbackData.tokenOut).approve(address(cUSDC), callbackData.amountOut); // approve USDC to lending protocol cUSDC
    cUSDC.liquidateBorrow(callbackData.borrower, callbackData.amountOut, cDAI); // get cDai

    // 6. redeem cDai
    cDAI.redeem(cDAI.balanceOf(address(this)));

    // 7. repay cDai to uniswap pool
    DAI.transfer(msg.sender, callbackData.amountIn);

    // // check profit
    // require(address(this).balance >= _MINIMUM_PROFIT, "Profit must be greater than 0.01 ether");
  }

  function liquidate(address borrower, uint256 amountOut) external {
    // TODO

    // Call swap on pair to get USDC
    address[] memory path = new address[](2);
    path[0] = address(DAI);
    path[1] = address(USDC);

    // // 1. get uniswap pool address
    // address pair = IUniswapV2Factory(_UNISWAP_FACTORY).getPair(path[0], path[1]);
    address pair = factory.getPair(address(DAI), address(USDC));

    // // 2. calculate repay amount
    uint256[] memory amountsIn = router.getAmountsIn(amountOut, path);
    CallbackData memory callbackData = CallbackData(borrower, path[0], path[1], amountsIn[0], amountOut);
    // // 3. flash swap from the uniswap pool
    IUniswapV2Pair(pair).swap(0, amountOut, address(this), abi.encode(callbackData));
  }
}

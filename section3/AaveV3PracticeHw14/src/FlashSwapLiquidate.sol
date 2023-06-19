pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IUniswapV2Callee} from "v2-core/interfaces/IUniswapV2Callee.sol";
import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {CErc20} from "compound-protocol/contracts/CErc20.sol";
import "forge-std/console.sol";


contract FlashSwapLiquidate is IUniswapV2Callee {
  IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  // IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IERC20 public UNI = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
  // CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  // CErc20 public cDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
  CErc20 public cUSDC;
  CErc20 public cUNI;
  IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Factory public factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

  struct CallbackData {
        address borrower;
        // address tokenIn;
        // address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
    }

  // cTokenA = cUSDC, cTokenB = cUNI 
  constructor(address cTokenA, address cTokenB) {
    cUSDC = CErc20(cTokenA);
    cUNI = CErc20(cTokenB);
  }

  // 使用 Compound 清算 - Uniswap 會回 call uniswapV2Call
  function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
    require(sender == address(this), "Sender must be this contract");
    require(amount0 > 0 || amount1 > 0, "amount0 or amount1 must be greater than 0");

    // TODO
    // 清算地址, 清算金額
    // 是否拿到 40 萬 USDC
    console.log("after-address(this)'s usdc: ", USDC.balanceOf(address(this))); // 400_000_000000
    CallbackData memory callback = abi.decode(data, (CallbackData));
    console.log("callback.amountIn: ", callback.amountIn); // 400000000000
    USDC.approve(address(cUSDC), callback.amountIn);
    // 清算 400_000 USDC 然後得到 cUNI
    // callback.amountIn 應該是要代還款的錢，而不是得到的錢。
    cUSDC.liquidateBorrow(callback.borrower, callback.amountIn, cUNI);
    console.log("address(this)'s cUNI=liquidator: ", cUNI.balanceOf(address(this))); // 1885476076597875 - 代還款得到的 cUNI
    console.log("before-address(this)'s UNI=liquidator: ", UNI.balanceOf(address(this))); // 0
    uint balance = cUNI.balanceOf(address(this));
    cUNI.approve(address(cUNI), balance);
    // cUNI 贖回得到 UNI 加上利息
    cUNI.redeem(balance);
    console.log("after-address(this)'s UNI=liquidator: ", UNI.balanceOf(address(this))); // 419945994599459862407683 - 贖回得到多少 UNI
    console.log("callback.amountOut: ", callback.amountOut); // 416621219675789067365452
    console.log("before-msg.sender's UNI=pool: ", UNI.balanceOf(msg.sender)); // 10881616983896311824193436
    UNI.transfer(msg.sender, callback.amountOut); // 因為跟 pool(Uniswap) flashloan UNI 換 USDC 所以要還給 pool UNI 的錢
    // 3324774923670795042231 = 419945994599459862407683 - 416621219675789067365452 = 贖回的 UNI 扣除要還給 Uniswap UNI
    console.log("address(this)'s UNI=liquidator: ", UNI.balanceOf(address(this))); // 3324774923670795042231
    console.log("address(this)=liquidator: ", address(this)); // 0x2e234DAe75C793f67A35089C9d99245E1C58470b - liquidator(FlashSwapLiquidator)
    console.log("msg.sender=pool: ", address(msg.sender));  // 0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5 - pool(Pair)
    // 11298238203572100891558888 = 10881616983896311824193436 + 416621219675789067365452
    console.log("after-msg.sender's UNI=pool: ", UNI.balanceOf(msg.sender)); 
  }

  // 使用 Uniswap 借錢 - 參考 week10-13 - FlashSwapPractice (也就是 week12)
  function liquidate(address borrower, uint256 amountOut) external {
    // TODO
    address[] memory path = new address[](2);
    path[0] = address(UNI); // 地址比較小在前面
    path[1] = address(USDC);
    address pool = factory.getPair(path[0], path[1]);
    uint256 repayAmount = router.getAmountsIn(amountOut, path)[0]; // 400_000_000000 USDC 得到多少 UNI
    console.log("repayAmount: ", repayAmount); // 416621219675789067365452 - 可以得到多少 UNI
    CallbackData memory callbackdata; // 對 CALLBACK 來說
    callbackdata.borrower = borrower;
    // callbackdata.tokenIn = path[1]; // USDC
    // callbackdata.tokenOut = path[0]; // WETH
    callbackdata.amountIn = amountOut; // 我要借多少錢 USDC
    callbackdata.amountOut =  repayAmount;
    console.log("amountOut: ", amountOut); // 400_000_000000
    console.log("before-address(this)'s usdc=liquidator: ", USDC.balanceOf(address(this))); // 0
    console.log("pool-initial's UNI: ", UNI.balanceOf(pool)); // 10881616983896311824193436
    IUniswapV2Pair(pool).swap(0, amountOut, address(this), abi.encode(callbackdata)); // pool(weth,usdc)
    console.log("pool: ", address(pool)); // 0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5
  }
}

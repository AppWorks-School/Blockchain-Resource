pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {
  IFlashLoanSimpleReceiver,
  IPoolAddressesProvider,
  IPool
} from "aave-v3-core/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import { CErc20 } from "compound-protocol/contracts/CErc20.sol";
import "v3-periphery/interfaces/ISwapRouter.sol";
import "forge-std/console.sol";

// 1-1. 實現 IFlashLoanSimpleReceiver - 繼承
// TODO: Inherit IFlashLoanSimpleReceiver
contract AaveFlashLoan is IFlashLoanSimpleReceiver {
  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // 實現 FiatTokenProxy contract
  // Aave: Pool Address Provider V3
  address constant POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e; // 實現 PoolAddressesProvider contract
  address constant swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

  // 1-2. 實現 IFlashLoanSimpleReceiver - 實作
  // 3. Aave 會回 call 你的 executeOperation()
  // 4. 結束 executeOperation() 後 Aave 的 Pool 會透過 transferFrom() 把貸款 + 利息收回
  function executeOperation( // 若 execute() 呼叫 Aave 合約執行閃電貸成功， Aave 會 callback 自己寫的合約的 function - executeOperation()
    address asset,
    uint256 amount,
    uint256 premium,
    address initiator,
    bytes calldata params
  ) external returns (bool) {
    // Decode params - Borrower, cUSDC, cUNI, UNI
    (address borrower, address cTokenA, address cTokenB, address tokenB) = abi.decode(params, (address, address, address, address));

    // 幫 user1 還錢
    IERC20(USDC).approve(address(cTokenA), amount);
    // console.log("CErc20(address(cTokenA))'s UNI: ", IERC20(tokenB).balanceOf(address(CErc20(address(cTokenA)))));
    console.log("cUNI's UNI: ", IERC20(tokenB).balanceOf(cTokenB));
    console.log("user1's cUNI: ", IERC20(cTokenB).balanceOf(borrower));
    CErc20(address(cTokenA)).liquidateBorrow(borrower, amount, CErc20(address(cTokenB)));

    // 將 cUNI 贖回成 UNI
    CErc20(address(cTokenB)).redeem(CErc20(address(cTokenB)).balanceOf(address(this)));

    // Swap UNI to USDC
    _swap(address(tokenB), address(USDC), IERC20(address(tokenB)).balanceOf(address(this)));

    // 還 USDC 給 Flash Loan
    IERC20(USDC).approve(address(POOL()), amount + premium);
    return true;
  }  

  function execute(
      uint256 repayAmount, 
      bytes memory callbackdata
    ) external {
    // callbackdata 從上層實作

    // address receiverAddress - address(this): 借款後收錢的地址 (因為我門是用自己的合約去幫我們執行閃電貸，所以就是用自己的合約借款收錢)
    // address asset - USDC: 要借的資產
    // uint256 amount - amount: 要借的金額
    // bytes calldata params - "": 沒有要特別執行其他東西，則帶空白字串。
    // uint16 referralCode - 0: 推薦碼，尚未啟用，所以帶 0 。 
    // - flashLoanSimple() 來自 Pool contract(繼承 IPool interface)
    // - InitializableImmutableAdminUpgradeabilityProxy contract 利用 IPool interface 方式實現可使用 flashLoanSimple()
    // - Pool.flashLoanSimple() 會呼叫真正執行邏輯的地方 FlashLoanLogic contract - executeFlashLoanSimple()
    // - FlashLoanLogic contract - executeFlashLoanSimple(): 會去執行 receiver.executeOperation ，所以 receiver 需是自己寫的合約而不是 EOA 去做交易。
    POOL().flashLoanSimple(
      address(this), 
      USDC, 
      repayAmount, 
      callbackdata, 
      0
    ); 
    // Aave 會根據 approve 自己 transferFrom 把用戶的借款收回且會加上利息。
    console.log("address(this)'s USDC balance: ", IERC20(USDC).balanceOf(address(this)));
    console.log("msg.sender: ", address(msg.sender));
    IERC20(USDC).transfer(msg.sender, IERC20(USDC).balanceOf(address(this)));
  }

  function ADDRESSES_PROVIDER() public view returns (IPoolAddressesProvider) {
    return IPoolAddressesProvider(POOL_ADDRESSES_PROVIDER);
  }

  function POOL() public view returns (IPool) {
    // 利用 Aave: Pool Address Proveder V3 得到 Pool (Aave: Pool V3)
    // pool: https://etherscan.io/address/0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2#code
    // pool = 實現 InitializableImmutableAdminUpgradeabilityProxy contract
    return IPool(ADDRESSES_PROVIDER().getPool());
  }

  function _swap(address _tokenIn, address _tokenOut, uint256 _amountIn) internal returns (uint256) {
        // Approve token to swap router
        IERC20(_tokenIn).approve(swapRouter, IERC20(_tokenIn).balanceOf(address(this)));

        // Set up token swap params
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: 3000, // 0.3%
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // Swap token
        uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(swapParams);
        return amountOut;
    }
}

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Borrower} from "../src/Borrower.sol";
import {FlashSwapLiquidate} from "../src/FlashSwapLiquidate.sol";

contract FlashSwapLiquidateTest is Test {
  IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  FlashSwapLiquidate public liquidator;
  Borrower public borrower;

  function setUp() public {
    string memory rpc = vm.envString("MAINNET_RPC_URL");
    vm.createSelectFork(rpc);

    borrower = new Borrower();
    // The collateral factor will decrease after borrowing inside borrower.borrow(),
    // so that the borrower can be liquidated.
    // The borrower borrows USDC against DAI (Use DAI as collateral).
    borrower.borrow();
    
    liquidator = new FlashSwapLiquidate(); 

    vm.label(address(borrower), "Borrower");
    vm.label(address(liquidator), "Liquidator");
  }

  function testFlashSwapLiquidate() public {
    // Borrower borrowed 800k USDC
    // Close factor is 50%
    uint256 repayAmount = 400_000 * 10 ** 6;

    liquidator.liquidate(address(borrower), repayAmount);

    uint256 daiBalance = DAI.balanceOf(address(liquidator));
    assertGt(daiBalance, 0);
  }
}

pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract BalanceChecker {
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  bool public pass;

  function checkBalance() public {
    uint256 requiredBalance = 10_000_000 * 10 ** 6;
    pass = (IERC20(USDC).balanceOf(msg.sender) > requiredBalance);
  }
}

pragma solidity 0.8.20;

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
  constructor(uint256 supply, string memory name, string memory symbol) ERC20(name, symbol) {
    _mint(msg.sender, supply);
  }
}

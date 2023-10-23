// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract testERC20 is ERC20 {
  constructor() ERC20("Test erc20", "TEST20") {}

  function mint(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol
        ) ERC20(_name, _symbol) {}
}
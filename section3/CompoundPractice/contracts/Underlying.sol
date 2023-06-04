// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "solmate/tokens/ERC20.sol";

contract Underlying is ERC20 {

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
        ) ERC20(_name, _symbol, _decimals){
            // send 10000 tokens to msg.sender when create this contract
            _mint(msg.sender, 10000 * 10 ** _decimals);
        }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
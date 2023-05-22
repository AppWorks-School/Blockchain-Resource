// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";

// This is a fake lending protocol for testing
// when call liquidatePosition, user need to pay 80 USDC and get 1 ETH back
contract FakeLendingProtocol {
    address internal immutable _USDC;

    constructor(address usdc) payable {
        require(msg.value == 1 ether, "Initial value must be 1 ether");
        _USDC = usdc;
    }

    // Let's assume liquidate position can use 80 USDC to liquidate 1 ETH position
    // ETH origianl price is 100 USDC, discount 20%
    function liquidatePosition() external {
        bool success = IERC20(_USDC).transferFrom(msg.sender, address(this), 80 * 10 ** 6);
        require(success, "Transfer USDC failed");

        (bool success2, ) = msg.sender.call{ value: address(this).balance }("");
        require(success2, "Transfer ETH failed");
    }
}

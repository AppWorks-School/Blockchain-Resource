// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

contract Compound is Test {
    function setup() public {
        // Todo:
        // Deploy cERC20 tokenA
        // Deploy cERC20 tokenB
        // user1 = makeAddr("user1");
        // user2 = makeAddr("user2");

    }

    function testMintAndRedeem() public {
        // Give user
        // user 1 use 100 ERC20 tokens to mint 100 cERC20 tokens.
        // user 1 use 100 cERC20 tokens to redeem 100 ERC20 tokens.
    }

    function testBorrowAndRepay() public {

    }

    function testLiquidateByAdjustCollateralFactor() public {

    }

    function testLiquidateByAdjustTokenBPrice() public {
        
    }
}

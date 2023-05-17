// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import { Test } from "forge-std/Test.sol";
import { DSTest } from "ds-test/test.sol";
import { SimpleSwap } from "../../contracts/SimpleSwap.sol";
import { TestERC20 } from "../../contracts/test/TestERC20.sol";

contract SimpleSwapConstructorTest is DSTest, Test {
    TestERC20 tokenA;
    TestERC20 tokenB;
    address EOA = address(0x1234);
    SimpleSwap swap;

    function setUp() public {
        tokenA = new TestERC20("token A", "TKA");
        tokenB = new TestERC20("token B", "TKB");
    }

    function test_revert_constructor_tokenA_is_not_a_contract() public {
        vm.expectRevert("SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        swap = new SimpleSwap(EOA, address(tokenB));
    }

    function test_revert_constructor_tokenB_is_not_a_contract() public {
        vm.expectRevert("SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        swap = new SimpleSwap(address(tokenA), EOA);
    }

    function test_revert_constructor_tokenA_tokenB_identical() public {
        vm.expectRevert("SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        swap = new SimpleSwap(address(tokenA), address(tokenA));
    }

    function test_constructor_reserve_should_be_zero_after_initialize() public {
        swap = new SimpleSwap(address(tokenA), address(tokenB));
        uint256 reserve1;
        uint256 reserve2;

        (reserve1, reserve2) = swap.getReserves();
        assertEq(reserve1, 0);
        assertEq(reserve2, 0);
    }

    function test_constructor_tokenA_should_be_less_than_tokenB() public {
        swap = new SimpleSwap(address(tokenA), address(tokenB));
        address swapTokenA = swap.getTokenA();
        address swapTokenB = swap.getTokenB();
        assertLe(uint256(uint160(swapTokenA)), uint256(uint160(swapTokenB)));
    }
}

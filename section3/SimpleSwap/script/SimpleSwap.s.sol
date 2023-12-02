// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { SimpleSwap } from "../contracts/SimpleSwap.sol";
import { TestERC20 } from "../contracts/test/TestERC20.sol";

contract SimpleSwapScript is Script {
    function setUp() public {}

    function run() public {
        uint256 pkey = vm.envUint("P_KEY");
        vm.startBroadcast(pkey);

        TestERC20 tokenB = new TestERC20("token B", "TKB");
        TestERC20 tokenA = new TestERC20("token A", "TKA");
        

        SimpleSwap simpleSwap = new SimpleSwap(address(tokenA), address(tokenB));

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/challenge/Challenge.sol";
import "../src/Exploit.sol";

contract Solve is Test {
    Challenge public chall;

    AppworksToken public CUSD;
    AppworksToken public CStUSD;
    AppworksToken public CETH;
    AppworksToken public CWETH;

    CErc20Immutable public CCUSD;
    CErc20Immutable public CCStUSD;
    CErc20Immutable public CCETH;
    CErc20Immutable public CCWETH;

    Comptroller public comptroller;

    uint256 seed;
    address target;
    Deployer dd;

    function setUp() public {
        seed = 2023_12_18;
        target = address(uint160(seed));
        dd = new Deployer();

        chall = new Challenge();
        chall.init(seed, address(this), address(dd));

        CUSD = chall.CUSD();
        CStUSD = chall.CStUSD();
        CETH = chall.CETH();
        CWETH = chall.CWETH();

        CCUSD = chall.CCUSD();
        CCStUSD = chall.CCStUSD();
        CCETH = chall.CCETH();
        CCWETH = chall.CCWETH();

        comptroller = chall.comptroller();
    }

    function testSolve() public {
        /* Solve here */

        assertEq(chall.isSolved(), true);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
import "compound-protocol/contracts/PriceOracle.sol";
import "contracts/MyToken.sol";

contract CompoundLending is Test {
    // comptroller
    Comptroller public comptroller;

    // interest model
    InterestRateModel public interestRateModel;
    WhitePaperInterestRateModel public whitePaperInterestModel;

    // oracle
    SimplePriceOracle public simplePriceOracle;

    // tokenA & cTokenA
    ERC20 public tokenA;
    CErc20Delegate public cTokenDelegateA;
    CErc20Delegator public cTokenA;

    // tokenB & cTokenB
    ERC20 public tokenB;
    CErc20Delegator public cTokenB;
    CErc20Delegate public cTokenDelegateB;

    // user
    address user1;
    address user2;

    function setUp() public {
        // deploy comptroller
        Comptroller comptroller = new Comptroller();
        Unitroller unitroller = new Unitroller();
        uint errorCode = unitroller._setPendingImplementation(address(comptroller));
        require(errorCode == 0, "Set Implementation Failed");
        comptroller._become(unitroller);
        // oracle
        simplePriceOracle = new SimplePriceOracle();
        comptroller = Comptroller(address(unitroller));
        comptroller._setPriceOracle(PriceOracle(simplePriceOracle));
        whitePaperInterestModel = new WhitePaperInterestRateModel(0, 0);

        // becomeImplementationData
        bytes memory becomeImplementationData = new bytes(0x00);

        // Deploy cERC20 tokenA
        tokenA = new MyToken("tokenA", "tokenA");
        cTokenDelegateA = new CErc20Delegate();
        cTokenA = new CErc20Delegator(
            address(tokenA),
            comptroller,
            InterestRateModel(address(whitePaperInterestModel)),
            1 ether,
            tokenA.name(),
            tokenA.symbol(),
            18,
            payable(msg.sender),
            address(cTokenDelegateA),
            becomeImplementationData
        );
        comptroller._supportMarket(CToken(address(cTokenA)));

        // Deploy cERC20 tokenB
        tokenB = new MyToken("tokenB", "tokenB");
        cTokenDelegateB = new CErc20Delegate();
        cTokenB = new CErc20Delegator(
            address(tokenB),
            comptroller,
            InterestRateModel(address(whitePaperInterestModel)),
            1 ether,
            tokenB.name(),
            tokenB.symbol(),
            18,
            payable(msg.sender),
            address(cTokenDelegateB),
            becomeImplementationData
        );
        comptroller._supportMarket(CToken(address(cTokenB)));

        // users
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testMintAndRedeem() public {
        uint256 initalAmount = 300 * 10 ** tokenA.decimals();
        uint256 mintAmount = 100 * 10 ** tokenA.decimals();

        // Give user 1 token A initial amount
        deal(address(tokenA), user1, initalAmount);

        vm.startPrank(user1);
 
        // user 1 use 100 ERC20 tokens to mint 100 cERC20 tokens.
        ERC20(tokenA).approve(address(cTokenA), mintAmount);
        cTokenA.mint(mintAmount);

        assertEq(tokenA.balanceOf(user1), initalAmount - mintAmount);
        assertEq(cTokenA.balanceOf(user1), mintAmount);

        // user 1 use 100 cERC20 tokens to redeem 100 ERC20 tokens.
        cTokenA.redeem(mintAmount);

        assertEq(tokenA.balanceOf(user1), initalAmount);
        assertEq(cTokenA.balanceOf(user1), 0);

        vm.stopPrank();
    }

    function testBorrowAndRepay() public {

    }

    function testLiquidateByAdjustCollateralFactor() public {

    }

    function testLiquidateByAdjustTokenBPrice() public {

    }
}

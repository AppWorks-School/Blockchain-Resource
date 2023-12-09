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
    Unitroller public unitroller;
    Comptroller public comptroller;
    Comptroller public comptrollerProxy;

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
        comptroller = new Comptroller();
        unitroller = new Unitroller();
        comptrollerProxy = Comptroller(address(unitroller));
        uint errorCode = unitroller._setPendingImplementation(address(comptroller));
        require(errorCode == 0, "Set Implementation Failed");
        comptroller._become(unitroller);
        // oracle
        simplePriceOracle = new SimplePriceOracle();
        comptroller = Comptroller(address(unitroller));
        comptrollerProxy._setPriceOracle(PriceOracle(simplePriceOracle));
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
        comptrollerProxy._supportMarket(CToken(address(cTokenA)));

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
        comptrollerProxy._supportMarket(CToken(address(cTokenB)));

        // users
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // set oracle price
        // 在 token A $1, token B $100
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenA)), 1);
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 100);
        // set tokenB collateral factor 50%
        comptrollerProxy._setCollateralFactor(CToken(address(cTokenB)), 0.5 * 1e18);
        // set close factor 50%
        comptrollerProxy._setCloseFactor(0.5 * 1e18);
        // set Liquidation incentive
        comptrollerProxy._setLiquidationIncentive(1.05 * 1e18);
    }

    function testMintAndRedeem() public {
        uint256 initialAmount = 300 * 10 ** tokenA.decimals();
        uint256 mintAmount = 100 * 10 ** tokenA.decimals();

        // Give user 1 token A initial amount
        deal(address(tokenA), user1, initialAmount);

        vm.startPrank(user1);
 
        // user 1 use 100 ERC20 tokens to mint 100 cERC20 tokens.
        ERC20(tokenA).approve(address(cTokenA), mintAmount);
        cTokenA.mint(mintAmount);

        assertEq(tokenA.balanceOf(user1), initialAmount - mintAmount);
        assertEq(cTokenA.balanceOf(user1), mintAmount);

        // user 1 use 100 cERC20 tokens to redeem 100 ERC20 tokens.
        cTokenA.redeem(mintAmount);

        assertEq(tokenA.balanceOf(user1), initialAmount);
        assertEq(cTokenA.balanceOf(user1), 0);

        vm.stopPrank();
    }

    function testBorrowAndRepay() public {
        uint256 initialTokenAAmount = 100 * 10 ** tokenA.decimals();
        uint256 initialTokenBAmount = 100 * 10 ** tokenB.decimals();
        uint256 mintTokenBAmount = 1 * 10 ** tokenB.decimals();
        uint256 borrowTokenAAmmount = 50 * 10 ** tokenA.decimals();

        // Give user1 token A, token B initial amount
        deal(address(tokenA), user1, initialTokenAAmount);
        deal(address(tokenB), user1, initialTokenBAmount);

        // Give cTokenA enough tokenA to borrow
        deal(address(tokenA), address(cTokenA), 30000 * 10 ** tokenA.decimals());

        vm.startPrank(user1);

        // user 1 use 1 token B to mint cTokenB
        ERC20(tokenB).approve(address(cTokenB), mintTokenBAmount);
        cTokenB.mint(mintTokenBAmount);

        assertEq(tokenB.balanceOf(user1), initialTokenBAmount - mintTokenBAmount);
        assertEq(cTokenB.balanceOf(user1), mintTokenBAmount);

        // user 1 use tokenB as collateral for borrow 50 tokenA
        // enter cTokenB market
        address[] memory addr = new address[](1);
        addr[0] = address(cTokenB);
        comptrollerProxy.enterMarkets(addr);
        
        // borrow 50 tokenA
        cTokenA.borrow(borrowTokenAAmmount);

        assertEq(tokenA.balanceOf(user1), initialTokenAAmount + borrowTokenAAmmount);

        // user 1 approve and repay 50 tokenA
        tokenA.approve(address(cTokenA), borrowTokenAAmmount);
        cTokenA.repayBorrow(borrowTokenAAmmount);

        assertEq(tokenA.balanceOf(user1), initialTokenAAmount);

        vm.stopPrank();
    }

    function testLiquidateByAdjustCollateralFactor() public {
        // user1 mint cTokenB and use cToken as collateral for borrow TokenA
        uint256 initialTokenAAmount = 100 * 10 ** tokenA.decimals();
        uint256 initialTokenBAmount = 100 * 10 ** tokenB.decimals();
        uint256 mintTokenBAmount = 1 * 10 ** tokenB.decimals();
        uint256 borrowTokenAAmmount = 50 * 10 ** tokenA.decimals();

        // Give user1 token A, token B initial amount
        deal(address(tokenA), user1, initialTokenAAmount);
        deal(address(tokenB), user1, initialTokenBAmount);

        // Give cTokenA enough tokenA to borrow
        deal(address(tokenA), address(cTokenA), 30000 * 10 ** tokenA.decimals());

        vm.startPrank(user1);

        // user 1 use 1 token B to mint cTokenB
        ERC20(tokenB).approve(address(cTokenB), mintTokenBAmount);
        cTokenB.mint(mintTokenBAmount);

        assertEq(tokenB.balanceOf(user1), initialTokenBAmount - mintTokenBAmount);
        assertEq(cTokenB.balanceOf(user1), mintTokenBAmount);

        // user 1 use tokenB as collateral for borrow 50 tokenA
        // enter cTokenB market
        address[] memory addr = new address[](1);
        addr[0] = address(cTokenB);
        comptrollerProxy.enterMarkets(addr);
        
        // borrow 50 tokenA
        cTokenA.borrow(borrowTokenAAmmount);

        assertEq(tokenA.balanceOf(user1), initialTokenAAmount + borrowTokenAAmmount);

        vm.stopPrank();

        // Adjust collateral factor
        comptrollerProxy._setCollateralFactor(CToken(address(cTokenB)) , 0.4e18);

        vm.startPrank(user2);

        // check shortfall
        // The borrower must have shortfall in order to be liquidatable
        (, , uint shortfall) = comptrollerProxy.getAccountLiquidity(user1);
        require(shortfall > 0, "no shortfall, not liquidatable");

        // give user2 enough tokenA to liquidateBorrow
        deal(address(tokenA), user2, initialTokenAAmount);

        // approve cTokenA to use user2's tokenA to liquidate
        tokenA.approve(address(cTokenA),  25 * 10 ** tokenA.decimals());

        uint256 errCode = cTokenA.liquidateBorrow(user1, 25 * 10 ** tokenA.decimals(), cTokenB);

        require(errCode == 0, "liquidateBorrow failed");

        // As a liquidator, user2 can get user1's collateral cTokenB

        // user 2 use tokenA to repay
        assertEq(tokenA.balanceOf(user2), initialTokenAAmount - 25 * 10 ** tokenA.decimals(), "user2 balance A is incorrect");

        // user 2 get collateral cTokenB as reward
        assertGt(cTokenB.balanceOf(user2), 0, "user 2 cTokenB balance should greate than 0");

         console.log(cTokenB.balanceOf(user2));

        vm.stopPrank();
    }

    function testLiquidateByAdjustTokenBPrice() public {
        // user1 mint cTokenB and use cToken as collateral for borrow TokenA
        uint256 initialTokenAAmount = 100 * 10 ** tokenA.decimals();
        uint256 initialTokenBAmount = 100 * 10 ** tokenB.decimals();
        uint256 mintTokenBAmount = 1 * 10 ** tokenB.decimals();
        uint256 borrowTokenAAmmount = 50 * 10 ** tokenA.decimals();

        // Give user1 token A, token B initial amount
        deal(address(tokenA), user1, initialTokenAAmount);
        deal(address(tokenB), user1, initialTokenBAmount);

        // Give cTokenA enough tokenA to borrow
        deal(address(tokenA), address(cTokenA), 30000 * 10 ** tokenA.decimals());

        vm.startPrank(user1);

        // user 1 use 1 token B to mint cTokenB
        ERC20(tokenB).approve(address(cTokenB), mintTokenBAmount);
        cTokenB.mint(mintTokenBAmount);

        assertEq(tokenB.balanceOf(user1), initialTokenBAmount - mintTokenBAmount);
        assertEq(cTokenB.balanceOf(user1), mintTokenBAmount);

        // user 1 use tokenB as collateral for borrow 50 tokenA
        // enter cTokenB market
        address[] memory addr = new address[](1);
        addr[0] = address(cTokenB);
        comptrollerProxy.enterMarkets(addr);
        
        // borrow 50 tokenA
        cTokenA.borrow(borrowTokenAAmmount);

        assertEq(tokenA.balanceOf(user1), initialTokenAAmount + borrowTokenAAmmount);

        vm.stopPrank();

        // Adjust Token B price
        simplePriceOracle.setUnderlyingPrice(CToken(address(cTokenB)), 90);

        vm.startPrank(user2);

        // check shortfall
        // The borrower must have shortfall in order to be liquidatable
        (, , uint shortfall) = comptrollerProxy.getAccountLiquidity(user1);
        require(shortfall > 0, "no shortfall, not liquidatable");

        // give user2 enough tokenA to liquidateBorrow
        deal(address(tokenA), user2, initialTokenAAmount);

        // approve cTokenA to use user2's tokenA to liquidate
        tokenA.approve(address(cTokenA),  25 * 10 ** tokenA.decimals());

        uint256 errCode = cTokenA.liquidateBorrow(user1, 25 * 10 ** tokenA.decimals(), cTokenB);

        require(errCode == 0, "liquidateBorrow failed");

        // As a liquidator, user2 can get user1's collateral cTokenB

        // user 2 use tokenA to repay
        assertEq(tokenA.balanceOf(user2), initialTokenAAmount - 25 * 10 ** tokenA.decimals(), "user2 balance A is incorrect");

        // user 2 get collateral cTokenB as reward
        assertGt(cTokenB.balanceOf(user2), 0, "user 2 cTokenB balance should greate than 0");
        
        vm.stopPrank();
    }
}

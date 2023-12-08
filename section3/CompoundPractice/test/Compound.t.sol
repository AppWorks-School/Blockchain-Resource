// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "forge-std/Script.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
import "compound-protocol/contracts/PriceOracle.sol";
import "contracts/MyToken.sol";

contract Compound is Test {
    function deployDelegator(ERC20 token) public {
        underlying_ = address(token);
        // 2. Deploy Comptroller
            // 2.1 Deploy Comptroller Implementation contract (Comptroller)
            Comptroller comptroller = new Comptroller();
            // 2.2 Deploy Comptroller Proxy contract (Unitroller)
            Unitroller unitroller = new Unitroller();
            // 2.3 Set Implentation contract address
            uint errorCode = unitroller._setPendingImplementation(address(comptroller));
            require(errorCode == 0, "Set Implementation Failed");
            // 2.4 Change brain (Proxy address) for Comptroller using _become function
            comptroller._become(unitroller);
            // 2.5 Set Price Oracle
            SimplePriceOracle simplePriceOracle = new SimplePriceOracle();
            comptroller_ = Comptroller(address(unitroller));
            comptroller_._setPriceOracle(PriceOracle(simplePriceOracle));
        // 3. Deploy InterestRateModel -> WhitePaperInterestRateModel, rate = 0%
            WhitePaperInterestRateModel interestRateModel = new WhitePaperInterestRateModel(0, 0);
            interestRateModel_ = InterestRateModel(address(interestRateModel));
        // 4. initialExchangeRateMantissa_ -> 1e18
            initialExchangeRateMantissa_ = 1 ether;
        // 5. name_ -> ctoken name
            name_ = token.name ;
        // 6. symbol_ -> ctoken symbol
            symbol_ = token.symbol;
        // 7. decimals_ -> 18
            decimals_ = 18;
        // 8. admin_ -> address(this)
            admin_ = payable(address(this));
        // 9. implementation_ -> CErc20Delegate
            CErc20Delegate cErc20Delegate = new CErc20Delegate();
            implementation_ = address(cErc20Delegate);
        // 10. becomeImplementationData -> unused, 0x00
            becomeImplementationData = new bytes(0x00);

        cToken = new CErc20Delegator(
            underlying_,
            comptroller_,
            interestRateModel_,
            initialExchangeRateMantissa_,
            name_,
            symbol_,
            decimals_,
            admin_,
            implementation_,
            becomeImplementationData
        );
    }


    function setup() public {
        // Deploy cERC20 tokenA
        tokenA = new MyToken("tokenA", "tokenA");
        deployDelegator(tokenA);
        // Deploy cERC20 tokenB
        tokenB = new MyToken("tokenB", "tokenB");
        deployDelegator(tokenB);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testMintAndRedeem() public {
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

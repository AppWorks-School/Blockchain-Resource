// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/console.sol";
import { CErc20Delegator } from "../lib/compound-protocol/contracts/CErc20Delegator.sol";
import { CErc20Delegate } from "../lib/compound-protocol/contracts/CErc20Delegate.sol";
import { ComptrollerInterface } from "../lib/compound-protocol/contracts/ComptrollerInterface.sol";
import { Comptroller } from "../lib/compound-protocol/contracts/Comptroller.sol";
import { Unitroller } from "../lib/compound-protocol/contracts/Unitroller.sol";
import { WhitePaperInterestRateModel } from "../lib/compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { TestERC20 } from "../contracts/test/TestERC20.sol";
import "../lib/forge-std/src/Script.sol";

//撰寫一個 Foundry 的 Script，該 Script 要能夠部署一個 CErc20Delegator(CErc20Delegator.sol，以下簡稱 cERC20)，一個 Unitroller(Unitroller.sol) 以及他們的 Implementation 合約和合約初始化時相關必要合約。請遵循以下細節：
//cERC20 的 decimals 皆為 18
//自行部署一個 cERC20 的 underlying ERC20 token，decimals 為 18
//使用 SimplePriceOracle 作為 Oracle
//使用 WhitePaperInterestRateModel 作為利率模型，利率模型合約中的借貸利率設定為 0%
//初始 exchangeRate 為 1:1

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address admin = 0x1895dE8651A898E325856e7F7C011A4710Fc81ec;

        ComptrollerInterface comptroller = new Comptroller();
        TestERC20 tokenA = new TestERC20("token A", "TKA");
        bytes memory data;
        CErc20Delegate delegate = new CErc20Delegate();
        WhitePaperInterestRateModel interestRateModel = new WhitePaperInterestRateModel(1, 1); 
        CErc20Delegator cErc20 = new CErc20Delegator(address(tokenA), comptroller, interestRateModel, 18, "cTokenA", "cTokenA", 18, payable(admin), address(delegate), data);
        Unitroller unitroller = new Unitroller();

        vm.stopBroadcast();
    }
}
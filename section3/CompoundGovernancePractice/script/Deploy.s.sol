// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import { SimplePriceOracle } from "compound-protocol/contracts/SimplePriceOracle.sol";
import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";
import { UnitrollerAdminStorage } from "compound-protocol/contracts/ComptrollerStorage.sol";
import { GovernorBravoDelegator } from "compound-protocol/contracts/Governance/GovernorBravoDelegator.sol";
import { GovernorBravoDelegateStorageV2 } from "compound-protocol/contracts/Governance/GovernorBravoInterfaces.sol";
import { Comp } from "compound-protocol/contracts/Governance/Comp.sol";
import { GovernorBravoDelegate } from "src/GovernorBravoDelegate.sol";
import { Timelock } from "src/Timelock.sol";

import { TestERC20 } from "src/TestERC20.sol";

contract TimelockWithTransferOwnership is Timelock {
  constructor(address admin, uint256 delay) Timelock(admin, delay) {}

  function transferOwnership(address newAdmin) external {
    require(msg.sender == admin, "Only owner");

    admin = newAdmin;
  }
}

contract ComptrollerWithTransferOwnership is Comptroller {
  function transferOwnership(address newAdmin) external {
    require(msg.sender == admin, "Only owner");

    admin = newAdmin;
  }
}

contract Deploy is Script {
  function run() public {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);
    address payable sender = payable(vm.addr(privateKey));

    // Comptroller
    ComptrollerWithTransferOwnership comptroller = new ComptrollerWithTransferOwnership(); 
    Unitroller unitroller = new Unitroller();
    unitroller._setPendingImplementation(address(comptroller));
    comptroller._become(unitroller);

    // Oracle
    SimplePriceOracle oracle = new SimplePriceOracle();
    Comptroller(address(unitroller))._setPriceOracle(oracle);

    // Interest rate model
    WhitePaperInterestRateModel irModel = new WhitePaperInterestRateModel(0, 0);

    TestERC20 token = new TestERC20(1000000 * 1e18, "Test Token", "TOKEN"); 

    // CToken
    CErc20Delegate cERC20Delegate = new CErc20Delegate();
    CErc20Delegator cToken = new CErc20Delegator(
      address(token),
      Comptroller(address(unitroller)),
      irModel,
      1 * 10 ** 18,
      "Compound test token",
      "cToken0",
      18,
      sender,
      address(cERC20Delegate),
      ""
    );

    // Governance
    Comp comp = new Comp(sender);
    TimelockWithTransferOwnership timelock = new TimelockWithTransferOwnership(sender, 5 minutes); // Timelock delay measured in time
    GovernorBravoDelegate bravoImplementation = new GovernorBravoDelegate();
    GovernorBravoDelegator bravo = new GovernorBravoDelegator(
      address(timelock),
      address(comp),
      sender,
      address(bravoImplementation),
      100, // Voting period measured in blocks
      25, // Voting delay measured in blocks
      199 * 1e18
    );

    timelock.transferOwnership(address(bravo));
    ComptrollerWithTransferOwnership(address(unitroller)).transferOwnership(address(timelock));

    console2.log("Unitroller =", address(unitroller));
    console2.log("CToken =", address(cToken));
    console2.log("GovernorBravo =", address(bravo));
    console2.log("Timelock =", address(timelock));
    console2.log("Comp =", address(comp));

    vm.stopBroadcast();
  }
}

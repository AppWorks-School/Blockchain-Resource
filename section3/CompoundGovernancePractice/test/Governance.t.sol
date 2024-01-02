pragma solidity 0.8.20;

import "forge-std/Test.sol";
import { Unitroller } from "compound-protocol/contracts/Unitroller.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import { SimplePriceOracle } from "compound-protocol/contracts/SimplePriceOracle.sol";
import { WhitePaperInterestRateModel } from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import { CErc20Delegate } from "compound-protocol/contracts/CErc20Delegate.sol";
import { CErc20Delegator } from "compound-protocol/contracts/CErc20Delegator.sol";
import { UnitrollerAdminStorage } from "compound-protocol/contracts/ComptrollerStorage.sol";
import { GovernorBravoDelegator } from "compound-protocol/contracts/Governance/GovernorBravoDelegator.sol";
import { GovernorBravoDelegateStorageV2 } from "compound-protocol/contracts/Governance/GovernorBravoInterfaces.sol";
import { CToken } from "compound-protocol/contracts/CToken.sol";
import { Comp } from "compound-protocol/contracts/Governance/Comp.sol";
import { GovernorBravoDelegate } from "src/GovernorBravoDelegate.sol";
import { Timelock } from "src/Timelock.sol";

contract GovernanceTest is Test {
  Unitroller constant public unitroller = Unitroller(payable(0x63d005EA741704dDA3d74Cb54a5bf6F3b1Dc86DB));
  CErc20Delegator constant public cToken = CErc20Delegator(payable(0xdc25E4DDd051De774566ACC5a7442284e659FeeC));
  GovernorBravoDelegator constant public bravo = GovernorBravoDelegator(payable(0x561adf66bEf90969783d6E6D118e16Fd6856F862));
  Timelock constant public timelock = Timelock(payable(0x93C485BC5F028C36dFf0B9add0dCAfb080cb7dd7));
  Comp constant public comp = Comp(payable(0x8dCb0C9a616bEdcf70eB826BA8Cfc8a11b420EE7));

  function test_governance() public {
    address admin = 0x87176364A742aa3cd6a41De1A2E910602881AB7d;
    vm.startPrank(admin);

    comp.delegate(admin);
    vm.roll(block.number + 1);

    // Create a proposal
    address[] memory targets = new address[](1);
    targets[0] = address(unitroller);

    uint256[] memory values = new uint256[](1);
    values[0] = 0;

    string[] memory signatures = new string[](1);
    signatures[0];

    bytes[] memory calldatas = new bytes[](1);
    calldatas[0] = abi.encodeCall(Comptroller._supportMarket, (CToken(address(cToken))));

    string memory description = "Support Market";

    uint256 proposalId = GovernorBravoDelegate(address(bravo)).propose(targets, values, signatures, calldatas, description);
    
    // Vote for the proposal
    vm.roll(block.number + 25 + 1);
    GovernorBravoDelegate(address(bravo)).castVote(proposalId, 1);
    
    vm.roll(block.number + 25 + 1 + 100 + 1);
    GovernorBravoDelegate(address(bravo)).queue(proposalId);

    vm.warp(block.timestamp + 5 minutes + 1);
    GovernorBravoDelegate(address(bravo)).execute(proposalId);
  }
}

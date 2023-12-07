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
import { CToken } from "compound-protocol/contracts/CToken.sol";
import { Comp } from "compound-protocol/contracts/Governance/Comp.sol";
import { GovernorBravoDelegate } from "src/GovernorBravoDelegate.sol";
import { Timelock } from "src/Timelock.sol";

contract GovernanceScript is Script {
  Unitroller constant public unitroller = Unitroller(payable(0x63d005EA741704dDA3d74Cb54a5bf6F3b1Dc86DB));
  CErc20Delegator constant public cToken = CErc20Delegator(payable(0xdc25E4DDd051De774566ACC5a7442284e659FeeC));
  GovernorBravoDelegator constant public bravo = GovernorBravoDelegator(payable(0x561adf66bEf90969783d6E6D118e16Fd6856F862));
  Timelock constant public timelock = Timelock(payable(0x93C485BC5F028C36dFf0B9add0dCAfb080cb7dd7));
  Comp constant public comp = Comp(payable(0x8dCb0C9a616bEdcf70eB826BA8Cfc8a11b420EE7));

  function delegateVotingPower() public {
    // TODO: Distribute Comp into two addresses, delegate one address to yourself,
    // and delegate the other address to your team member.

  }

  function propose() public {
    // TODO: Submit a proposal, remember that your address requires 200 COMP of voting power.

  }

  function vote() public {
    // TODO: Vote for proposals that you prefer.

  }

  function queueProposal() public {
    // TODO: Send the approved proposal to the timelock.

  }

  function executeProposal() public {
    // TODO: Execute the proposal in the timelock.

  }
}

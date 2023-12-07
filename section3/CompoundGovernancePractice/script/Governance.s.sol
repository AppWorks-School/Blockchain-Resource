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

    address address1 = 0x123;
    address address2 = 0x456;
    address teammate = 0x789;

    uint256 key1 = vm.envUint("PRIVATE_KEY1");
    uint256 key2 = vm.envUint("PRIVATE_KEY2");

    vm.startBroadcast(key1);

    comp.transfer(address2, 100 * 10 ** 18);
    comp.delegate(address2);

    vm.stopBroadcast();

    vm.startBroadcast(key2);

    comp.delegate(teammate);

    vm.stopBroadcast();
  }

  function propose() public {
    // TODO: Submit a proposal, remember that your address requires 100 COMP of voting power.
    vm.startBroadcast(userBPK);
    address[] memory targets = new address[](1);
    uint[] memory values = new uint[](1);
    string[] memory sigs = new string[](1);
    bytes[] memory calldatas = new bytes[](1);

    targets[0] = address(unitroller);
    values[0] = 0;
    sigs[0] = "";
    bytes memory _calldata = abi.encodeWithSignature("_setCloseFactor(uint)", 0);
    calldatas[0] = _calldata;

    GovernorBravoDelegate(address(bravo)).propose(targets, values, sigs, calldatas, "GM");
    vm.stopBroadcast();
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

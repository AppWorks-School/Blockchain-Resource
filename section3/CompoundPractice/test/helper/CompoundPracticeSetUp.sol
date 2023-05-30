pragma solidity 0.8.19;

import "forge-std/Test.sol";

contract CompoundPracticeSetUp is Test {
  address borrowerAddress;

  function setUp() public virtual {
    string memory path = string(
      abi.encodePacked(vm.projectRoot(), "/test/helper/Borrower.json")
    );
    string memory json = vm.readFile(path);
    bytes memory creationCode = vm.parseBytes(abi.decode(vm.parseJson(json, ".bytecode"), (string)));

    address addr;
    assembly {
      addr := create(0, add(creationCode, 0x20), mload(creationCode))
    }
    require(addr != address(0), "Borrower deploy failed");

    borrowerAddress = addr;
  }
}

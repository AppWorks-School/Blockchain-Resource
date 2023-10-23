// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Ownable {
  bytes32 internal constant _OWNER_SLOT_ = 0xa7b53796fd2d99cb1f5ae019b54f9e024446c3d12b483f733ccc62ed04eb126b;

  function initializeOwnable(address _owner) internal {
    setOwner(_owner);
  }

  function getOwner() public view returns (address owner) {
    assembly {
      owner := sload(_OWNER_SLOT_)
    }
  }

  function setOwner(address _owner) internal {
    assembly {
      sstore(_OWNER_SLOT_, _owner)
    }
  }
  modifier onlyOwner() {
    require(msg.sender == getOwner(), "Ownable: caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    setOwner(newOwner);
  }
}
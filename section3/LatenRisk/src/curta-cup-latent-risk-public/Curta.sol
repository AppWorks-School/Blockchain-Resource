pragma solidity ^0.8.20;

import "./Challenge.sol";
import "../../lib/curta/src/interfaces/IPuzzle.sol";

contract Puzzle is IPuzzle {
    mapping(uint256 => Challenge) public factories;

    function name() external pure returns (string memory) {
        return "LatentRisk";
    }

    function generate(address solver) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(solver)));
    }

    function verify(uint256 seed, uint256) external view returns (bool) {
        return factories[seed].isSolved();
    }

    function deploy(address deployer) external {
        factories[generate(msg.sender)] = new Challenge();
        factories[generate(msg.sender)].init(generate(msg.sender), msg.sender, deployer);
    }
}

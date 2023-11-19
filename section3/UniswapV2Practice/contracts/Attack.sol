pragma solidity 0.8.17;

contract Attack {
    address public immutable bank;

    constructor(address _bank) {
        bank = _bank;
    }

    function attack() external {}
}

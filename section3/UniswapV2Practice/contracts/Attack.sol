pragma solidity 0.8.17;

contract Attack {
    address immutable public bank;

    constructor(address _bank) {
        bank = _bank;
    }

    function attack() external {
    }
}
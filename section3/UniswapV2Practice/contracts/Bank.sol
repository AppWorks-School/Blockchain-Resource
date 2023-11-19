pragma solidity 0.8.17;

contract Bank {
    mapping(address => uint256) public balances;

    // Reentrancy Guard
    //    uint256 private _unlock = 1;
    //    modifier lock() {
    //        require(_unlock == 1, "Locked");
    //        _unlock = 2;
    //        _;
    //        _unlock = 1;
    //    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        (bool success, ) = msg.sender.call{ value: balances[msg.sender] }("");
        require(success, "Withdraw Failed");

        balances[msg.sender] = 0;
    }
}

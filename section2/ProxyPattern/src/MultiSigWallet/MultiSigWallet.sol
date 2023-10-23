// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {

  address public adminOwner;
  address public owner1;
  address public owner2;
  address public owner3;

  uint256 constant public CONFIRMATION_REQUIRED = 2;

  struct Transaction {
    address to;
    uint value;
    bytes data;
    bool executed;
    uint numConfirmations;
  }

  mapping(uint => mapping(address => bool)) public isConfirmed;
  Transaction[] public transactions;

  event SubmitTransaction(uint indexed txIndex, address indexed to, uint value);
  event ExecuteTransaction(uint indexed txIndex);

  constructor(address[3] memory _owners) {
    adminOwner = msg.sender;
    owner1 = _owners[0];
    owner2 = _owners[1];
    owner3 = _owners[2];
  }

  modifier onlyOwner {
    require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == owner3, "not owner");
    _; 
  }

  modifier onlyAdmin {
    require(msg.sender == adminOwner, "not admin");
    _; 
  }

  function submitTransaction(address _to, uint256 _value, bytes calldata data) external onlyOwner {
    uint txIndex = transactions.length;

    transactions.push(Transaction({
      to: _to,
      value: _value,
      data: data,
      executed: false,
      numConfirmations: 0
    }));
    emit SubmitTransaction(txIndex, _to, _value);
  }

  function confirmTransaction() external onlyOwner {
    uint256 _txIndex = transactions.length - 1;
    Transaction storage transaction = transactions[_txIndex];
    transaction.numConfirmations += 1;
    isConfirmed[_txIndex][msg.sender] = true;
  }

  function executeTransaction() external onlyOwner {
    uint256 _txIndex = transactions.length - 1;
    Transaction storage transaction = transactions[_txIndex];
    require(!transaction.executed, "tx already executed");

    if (transaction.numConfirmations >= CONFIRMATION_REQUIRED) {
      transaction.executed = true;
      (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
      require(success, "tx failed");
      emit ExecuteTransaction(_txIndex);
    }
  }

  function updateOwner(address _newOwner1, address _newOwner2, address _newOwner3) external virtual {
      owner1 = _newOwner1;
      owner2 = _newOwner2;
      owner3 = _newOwner3;
  }

  function destroy() external onlyAdmin {
    selfdestruct(payable(adminOwner));
  }
}

# 合約使用優化

## 說明：

請學習在 EVM 中從 storage 讀取與寫入的 Gas Fee 是如何計算的，在理解後請解釋為什麼有些合約不使用 boolean 而是使用 uint 0, 1 進行判斷? 又為何有些使用場景不使用 0, 1 而是使用 1, 2 來取代 boolean？


## 參考資料
- [Solidity Bytecode and Opcode Basics](https://medium.com/@blockchain101/solidity-bytecode-and-opcode-basics-672e9b1a88c2)

- [Ethereum VM (EVM) Opcodes and Instruction Reference](https://github.com/crytic/evm-opcodes)

- [How to reduce Gas cost in Smart contract?](https://vishwasbanand.medium.com/how-to-reduce-gas-cost-in-smart-contract-9563a573be00)

- [EIP-2929: Gas cost increases for state access opcodes](https://eips.ethereum.org/EIPS/eip-2929)

- [OpenZeppelin ReentrancyGuard](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)


---
[回階段二](./README.md)

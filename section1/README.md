# 階段一：區塊鏈基礎知識

## 說明：
這裡整理幾個較完整的線上學習資源：

- [Ethereum and Solidity: The Complete Developer's Guide](https://www.udemy.com/course/ethereum-and-solidity-the-complete-developers-guide/)
- [零基礎邁向區塊鏈工程師：Solidity 智能合約](https://hahow.in/courses/5b3cdd6ed03140001eebeadc)
- [CryptoZombies](https://cryptozombies.io/)
  
####  備註：
- 區塊鏈技術演進快速，線上資源大概率會有過時的內容，但基礎概念基本上不會變，在實作細節上要特別注意。

<br/>

## What you'll learn
上述資源完成後，應該要能夠清楚的回答以下問題：
1. 什麼是合約（Smart Contract）？
2. 什麼是 PoW（Proof-of-Work）？
3. 比特幣和以太坊挖礦的流程為何？
4. 以太坊交易的流程為何？
5. 公鑰＆私鑰的基本加密以及簽名原理？
6. 冷錢包和熱錢包的差異？
7. 為何發起一筆交易需要礦工費（Gas Fee）？
8. 如何使用 Solidity 線上 IDE：[Remix](https://remix.ethereum.org/)？
9. 如何在以太坊上部署一個合約？
10. Solidity 語法的基礎？
11. 如何在 Etherscan 上看到自己部署的合約？

## Next steps

1. ### 學習使用 Hardhat 框架
  
    Remix 是相當適合初學者使用的 IDE，但對於撰寫自動化測試、複雜的合約應用，或是要引入 library 進行開發，便顯得過於簡陋。為了進行後續的實作練習，需要在本機架構自己的開發環境。
  
    請參閱並學習使用 [Hardhat](https://hardhat.org/) 框架，以利後續的學習進行。特別注意如何使用 Hardhat 進行 mainnet fork / testnet fork 的功能。

2. ### 在 local 執行 [Ethernaut](https://github.com/OpenZeppelin/ethernaut)
  
    原有的 Rinkeby, Kovan 等 testnet 將不會被過渡到 Proof of Stake 升級，預計在 Q2/Q3 2023 前會陸續關停（[Ropsten, Rinkeby & Kiln Deprecation Announcement](https://blog.ethereum.org/2022/06/21/testnet-deprecation/)）。

    為了避免在測試網上的 Ethernaut 不穩定，因此要學習如何在本地的測試鏈部署 Ethernaut 來練習。


---
[下一階段](../section2/README.md)・[回主頁](../README.md)

# 階段一：區塊鏈基礎知識

## 說明：
這裡整理幾個較完整的線上學習資源：

- [Ethereum and Solidity: The Complete Developer's Guide](https://www.udemy.com/course/ethereum-and-solidity-the-complete-developers-guide/)
- [零基礎邁向區塊鏈工程師：Solidity 智能合約](https://hahow.in/courses/5b3cdd6ed03140001eebeadc)
- [CryptoZombies](https://cryptozombies.io/)
  
####  備註：
- 區塊鏈技術演進快速，線上資源大概率會有過時的內容，但基礎概念不會變，在實作細節上要特別注意。

<br/>

## What you'll learn
上述資源完成後，應該要能夠清楚的回答以下問題：
1. 什麼是合約（smart contract）？
2. 什麼是 POW（proof of work）？
3. 挖礦的流程為何？
4. 交易的流程為何？
5. 公鑰＆私鑰的基本加密原理？
6. 冷錢包和熱錢包的差異？
7. 為何發起一筆交易需要 gas fee？
8. 如何使用 Solidity 線上 IDE：[Remix](https://remix.ethereum.org/)？
9. 如何部署一個合約？
10. Solidity 語法的基礎？
11. 如何在 Etherscan 上看到自己部署的合約？

## Next steps

1. ### 學習 Hardhat Fork 功能
  
    Remix 是相當適合初學者使用的 IDE，但對於複雜的合約應用，或是要引入 library 進行開發，便顯得過於簡陋。為了進行後續的實作練習，需要在本機架構自己的開發環境。
  
    請參閱並學習使用 [Hardhat](https://hardhat.org/) 框架，以利後續的學習進行。特別注意如何使用 Hardhat 進行 mainnet fork / testnet fork 的功能。

2. ### 在 local 執行 [Ethernaut](https://github.com/OpenZeppelin/ethernaut)
  
    在 2022 Q2, Q3 時會有一個 Ethereum 升級（[gray glacier](https://blog.ethereum.org/2022/06/16/gray-glacier-announcement/)），原有的 Rinkeby, Kovan 等 testnet 將不會被 Ethereum foundation 的開發團隊持續維護（未來也許是靠社群力量維護）。原本依靠 Rinkeby testnet 的 Ethernaut 可能會無法使用，因此要學習如何在 local 跑 Ethernaut 來練習。


---
[下一階段](../section2/README.md)・[回主頁](../README.md)
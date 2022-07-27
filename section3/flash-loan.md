# 借貸協議與閃電貸（Flash Loan）

## 目的：理解區塊鏈的借貸協議怎麼做，以及閃電貸怎麼使用
請賞析 [Compound](https://compound.finance/docs) 的合約，並依序實作以下
1. 在本地部署 Comptroller 跟兩個 CToken，並且具有基本借貸功能（可提供 X 代幣作為抵押品並借出 Y 代幣）
2. 藉由改變 SimplePriceOracle 合約的報價，讓 A 用戶清算 B 用戶
3. 不改變 SimplePriceOracle 的報價，而是用借貸的利息讓 A 用戶可以清算 B 用戶
3. 使用 AAVE 的 Flash loan，讓 A 用戶在本身沒有資金的情況下清算 B 用戶

進階題: 
- 使用一套治理框架（例如 Governor Bravo 加上 Timelock）完成 Comptroller 中的設置
- 賞析 [UniswapAnchoredView](https://etherscan.io/address/0x65c816077c29b557bee980ae3cc2dce80204a0c5#code) 合約並使用其作為 Comptroller 中設置的 oracle 來實現清算
- 設計一個能透過 flash loan 清算多種代幣類型的智能合約
- 研究 [Aave](https://aave.com/) 協議，比較這些借貸協議在功能上與合約開發上的差異

## 參考資料


---
[回階段三](./README.md)

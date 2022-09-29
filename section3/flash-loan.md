# 借貸協議與閃電貸（Flash Loan）

## 目的：理解區塊鏈的借貸協議怎麼做，以及閃電貸怎麼使用
請賞析 [Compound](https://compound.finance/docs) 的合約，並依序實作以下
1. 部署一個 CEther 跟一個以 USDC 為底的 CErc20，以及一個 Comptroller，Comptroller 需要的參數以及 oracle 等等合約可以隨便設，跑得起來就好
2. 用 user1 mint/redeem CEther, user2 mint/redeem CUsdc
3. 讓 user1 可以借出 CUsdc，並分別在兩種情況下進行清算
4. 調整 ETH 的 collateral factor，讓 user 1 遭到清算
5. 調整 oracle 的 ETH 價格，讓 user1 遭到清算
6. 使用 AAVE 的 Flash loan，讓 user 1 遭到清算

進階題: 
- 使用一套治理框架（例如 Governor Bravo 加上 Timelock）完成 Comptroller 中的設置
- 賞析 [UniswapAnchoredView](https://etherscan.io/address/0x65c816077c29b557bee980ae3cc2dce80204a0c5#code) 合約並使用其作為 Comptroller 中設置的 oracle 來實現清算
- 設計一個能透過 flash loan 清算多種代幣類型的智能合約
- 研究 [Aave](https://aave.com/) 協議，比較這些借貸協議在功能上與合約開發上的差異

## 參考資料


---
[回階段三](./README.md)

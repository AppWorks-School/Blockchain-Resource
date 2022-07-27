# 聚合器（Aggregator）

## 目的：理解聚合器(Aggregator)的原理與實作

## 請欣賞 [Yearn](https://docs.yearn.finance/) 的合約，並實作一個 vault 跟一個 strategy，需要達到以下功能
1. vault 可以接受 deposit，並發行對應的 yToken，例如 USDC => yUSDC
2. vault 可以接受 withdraw，收回 yToken 返回對應資產
3. vault 有個 price 可以反應 token => yToken 的價值
3. vault 可以把資產交給 strategy，也可以從 strategy 取回資產
4. strategy 要可以賺取收益，可以先用自己轉錢進去的方式假裝有在賺錢
3. 當 strategy 有收益或虧損， vault 要可以正確反應資產價值


## 參考資料
- [What is yearn.finance? (YFI)](https://www.kraken.com/learn/what-is-yearn-finance-yfi)


---
[回階段三](./README.md)

# 借貸協議與閃電貸（Flash Loan）

## 目的：理解區塊鏈的借貸協議怎麼做，以及閃電貸怎麼使用
請欣賞 [Compound](https://compound.finance/docs) 的合約，並依序實作以下
1. 部署 Comptroller 跟兩個 CToken，並且要可以借貸
2. 藉由改變 oracle 的方式，讓 A 用戶清算 B 用戶
3. 不改變 oracle，而是用利息讓 A 用戶可以清算 B 用戶
3. 使用 AAVE 的 Flashloan，讓 A 用戶在本身沒有資金的情況下清算 B 用戶

進階題: 看 [AAVE](https://aave.com/)，看看這些借貸協議有什麼差別

---
[回階段三](./README.md)
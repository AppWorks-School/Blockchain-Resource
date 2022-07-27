# ERC20 - Transfer approval

## 說明：
請詳讀 ERC20 的合約，自己實作一次 ERC20 並完成：
1. 透過 `transfer` 從交易發起者的地址轉出代幣
2. 透過 `transferFrom` 從非交易發起者的地址將代幣轉入交易發起者的地址

接著回答：
- 請問為何要先 `approve` 才能使用 `transferFrom`？
- 有沒有其他作法能夠達到 `approve` 的效果，又可以不用把 `approve` 跟 `transferFrom` 分成兩筆交易，只要一筆交易就能達成目的？

## 參考資料

- [ERC-20 TOKEN STANDARD](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)

- [ERC-777 TOKEN STANDARD](https://ethereum.org/zh-tw/developers/docs/standards/tokens/erc-777/)

- [EIP-2612: permit – 712-signed approvals](https://eips.ethereum.org/EIPS/eip-2612)

---
[回階段二](./README.md)


# 階段二：區塊鏈基礎實作及問題探討

## 說明：
接觸一些基礎的區塊鏈知識及操作後，應該對區塊鏈有一定的認識了，接下來便會需要進行大量的上手實作，以及更深入的問題研究。
這個階段的問題解答，在網路上都很容易查到，但為了最大化學習效果，請先自己先實作過後，再來查詢答案確定自己的理解是否正確。

1. 實作 A,B 兩個合約，並回答以下狀況的 msg.sender 跟 tx.origin 分別是誰? 1. User 呼叫 A 合約 2. User 呼叫 A 合約，A 合約呼叫 B 合約 3. User 呼叫 A 合約，A 合約呼叫 B 合約，B 合約呼叫 B 合約

2. 實作 ERC20 的合約，並回答為何要先 approve 才能 transfer? 有沒有什麼新作法能夠達到 approve 的效果又可以不用把 approve 跟 transfer 分成兩筆交易，只要一筆交易就能達成目的？(空的 ERC20 template 待補)

3. 請研究為什麼 ERC20 的代幣需要自己加入 MetaMask 才看得到餘額? 又為什麼 Etherscan 不用自己加入 ERC20 就看得到餘額?

4. 實作 ERC721 的合約，並回答為何 ERC721 需要 ERC721TokenReceiver？(空的 ERC721 template 待補)

5. 實作一個白名單系統，只有在白名單內的地址可以呼叫特定函數，如果白名單數量很小例如五個，或是白名單數量很大例如一千個，分別要怎麼做比較好? 請使用 merkle tree 做一個函數判斷 msg.sender 是否在白名單內

6. 理解 View, Internal, External, Public, Private 的作用，並回答如果以下函數如果有或沒有 View ，在鏈上合約互動跟鏈下由 web3.js 或 ethers.js 呼叫會有什麼差別

```
getAccountBalance(address _account) public returns (uint256) {
  return balance[_account];
}
```

7. 實作 EIP-712，讓你的 MetaMask 可以正確顯示要使用者簽名的資訊，而不是一串 hex code

8. 請研究什麼是 oracle， 並研究怎麼使用 Chainlink 的 oracle，並回答使用 Chainlink 跟使用 AMM 的報價有什麼不一樣?

9. 請研究什麼是 function signature，如果合約找不到這個 function 對應的 signature 會發生什麼事?

10. 請研究什麼是 internal transaction? 如何查詢 internal transaction 的資料?

11. 請研究什麼是 web3.js 或 ethers.js 的 static call，他們有什麼用處?

12. 實作一個可以產生亂數的合約，實作完後回答區塊鏈產生亂數為何很困難，確認自己的做法產生的亂數是否可以被預測，以及產生亂數的最佳實踐為何?

13. 實作一個運算用的合約，可以處理 uint256 的加減乘除並且在溢位時要 revert，實作完再查詢最佳實踐為何? 實作 Ethernaut - 05 Token

14. 了解什麼是 Proxy 以及用 Proxy 更新合約有什麼限制，並且把一個合約加上 Proxy ，以及實作 Ethernaut - 06 Delegation

15. 請解釋重入攻擊（Reentrancy Attack），並實作 Ethernaut - 10 Re-entrancy

16. 請解釋為何有些合約不使用 boolean 而是使用 0,1 進行判斷? 又為何有些合約不使用 0,1 而是使用 1,2 來取代 boolean?


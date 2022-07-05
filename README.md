# Blockchain-Resource
這是一份 Solidity 區塊鏈開發的自學教材，希望透過做中學的方式讓大家能夠自學區塊鏈，並且統整線上的學習資源讓大家在入門時比較有頭緒

主要分成三個部分
1. 區塊鏈基礎知識 => 先從線上已有的學習資源學會基礎
2. 簡單的實作以及問題思考 => 實作簡單的小程式建立自信，並多了解一些技術細節
3. 對經典 DeFi 機制的賞析以及較複雜的實作 => 了解經典的 DeFi 基礎建設並能夠複製/整合/加以改進



### 區塊鏈基礎知識
以下兩堂課請任選一堂並徹底上完，先對區塊鏈有個大概的了解，雖然有些內容(特別是實作)可能過時了但基礎的概念是不變的

英文: Udemy 上的 [ethereum-and-solidity-the-complete-developers-guide](https://www.udemy.com/course/ethereum-and-solidity-the-complete-developers-guide/)

中文: Hahow 上的 [零基礎邁向區塊鏈工程師：Solidity 智能合約](https://hahow.in/courses/5b3cdd6ed03140001eebeadc)

上完線上課程後請做完 [CryptoZombies](https://cryptozombies.io/)

CryptoZombies 也做完後可以算是對 Solidity 有基本的了解以及實作能力了

但接下來有些開發可能不好仰賴 Remix 了，需要在本機架構自己的開發環境，所以請學習使用 [Hardhat](https://hardhat.org/)，接下來的作業都請盡量使用 Hardhat 不要再用 Remix

學習 Hardhat Fork 功能
學習怎麼在 local 跑 [Ethernut](https://github.com/OpenZeppelin/ethernaut)




### 簡單的實作以及問題思考

這個階段的問題解答應該網路上都很容易查到，但請先自己先實作過後再查詢答案確定自己的理解是否正確

實作 A,B 兩個合約，並回答以下狀況的 msg.sender 跟 tx.origin 分別是誰? 1. User 呼叫 A 合約 2. User 呼叫 A 合約，A 合約呼叫 B 合約 3. User 呼叫 A 合約，A 合約呼叫 B 合約，B 合約呼叫 B 合約

實作 ERC20 的合約，並回答為何要先 approve 才能 transfer? 有沒有什麼新作法能夠達到 approve 的效果又可以不用把 approve 跟 transfer 分成兩筆交易，只要一筆交易就能達成目的？(空的 ERC20 template 待補)

實作 ERC721 的合約，並回答為何 ERC721 需要 ERC721TokenReceiver？(空的 ERC721 template 待補)

實作一個白名單系統，只有在白名單內的地址可以呼叫特定函數，如果白名單數量很小例如五個，或是白名單數量很大例如一千個，分別要怎麼做比較好? 請使用 merkle tree 做一個函數判斷 msg.sender 是否在白名單內

理解 View, Internal, External, Public, Private 的作用，並回答如果以下函數如果有或沒有 View ，在鏈上合約互動跟鏈下由 web3.js 或 ethers.js 呼叫會有什麼差別

```
getAccountBalance(address _account) public returns (uint256) {
  return balance[_account];
}
```

實作一個可以產生亂數的合約，實作完後回答區塊鏈產生亂數為何很困難，確認自己的做法產生的亂數是否可以被預測，以及產生亂數的最佳實踐為何?

實作一個運算用的合約，可以處理 uint256 的加減乘除並且在溢位時要 revert，實作完再查詢最佳實踐為何? 實作 Ethernaut - 05 Token

了解什麼是 Proxy 以及用 Proxy 更新合約有什麼限制，並且把一個合約加上 Proxy ，以及實作 Ethernaut - 06 Delegation

請解釋重入攻擊（Reentrancy Attack），並實作 Ethernaut - 10 Re-entrancy

請解釋為何有些合約不使用 boolean 而是使用 0,1 進行判斷? 又為何有些合約不使用 0,1 而是使用 1,2 來取代 boolean?



### 對經典 DeFi 機制的賞析以及較複雜的實作

請盡量寫完 [Ethernaut](https://ethernaut.openzeppelin.com/)，至少比較簡單的約 15-20 題左右

##### 理解區塊鏈的借貸協議怎麼做，以及閃電貸怎麼使用
請欣賞 [Compound](https://compound.finance/docs) 的合約，並依序實作以下
1. 部署 Comptroller 跟兩個 CToken，並且要可以借貸
2. 藉由改變 oracle 的方式，讓 A 用戶清算 B 用戶
3. 不改變 oracle，而是用利息讓 A 用戶可以清算 B 用戶
3. 使用 AAVE 的 Flashloan，讓 A 用戶在本身沒有資金的情況下清算 B 用戶

進階題: 看 [AAVE](https://aave.com/)，看看這些借貸協議有什麼差別

##### 理解基本的 AMM 怎麼的原理實作
請先理解什麼是 AMM([Uniswap V2](https://docs.uniswap.org/protocol/V2/introduction))，並實作一個簡單的 AMM 可以做到以下三件事，不需要收 fee
1. 增加流動性
2. 移除流動性
3. 換幣

進階題:
1. 看 [Uniswap V3](https://docs.uniswap.org/protocol/introduction)，[這篇](https://liaoph.com/uniswap-v3-1/)中文講解很神
2. 看 [Curve](https://curve.readthedocs.io/)


##### 理解聚合器(Aggregator)的原理與實作
請欣賞 [Yearn](https://docs.yearn.finance/)的合約，並實作一個 vault 跟一個 strategy，需要達到以下功能
1. vault 可以接受 deposit，並發行對應的 yToken，例如 USDC => yUSDC
2. vault 可以接受 withdraw，收回 yToken 返回對應資產
3. vault 有個 price 可以反應 token => yToken 的價值
3. vault 可以把資產交給 strategy，也可以從 strategy 取回資產
4. strategy 要可以賺取收益，可以先用自己轉錢進去的方式假裝有在賺錢
3. 當 strategy 有收益或虧損， vault 要可以正確反應資產價值

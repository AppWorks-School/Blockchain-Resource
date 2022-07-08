# 練習六：view / pure function 及 function visibility

## 說明：
理解 View, Pure, Internal, External, Public, Private 的作用，並回答如果以下函數如果有或沒有 View ，在鏈上合約互動跟鏈下由 web3.js 或 ethers.js 呼叫會有什麼差別

```
getAccountBalance(address _account) public returns (uint256) {
  return balance[_account];
}
```

## 先備知識

## 參考資料
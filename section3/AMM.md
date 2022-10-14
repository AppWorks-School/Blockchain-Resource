# 自動化做市商（Automated Market Maker, AMM）


請先理解什麼是 AMM（[Uniswap V2](https://docs.uniswap.org/protocol/V2/introduction)），並依照下面順序實作一個簡單的 AMM 
1. 實作一個 AMM 合約，繼承 ERC20 並實作一個 `init(uint256 _amount)`，會收取用戶 _amount 這麼多金額的 USDC 和 USDT，並發給用戶 1e18 數量的 ERC20 token(Liquidity Provider Token, LP token)

2. 實作一個 `swap(address _tokenIn, address _tokenOut, uint256 _amount)` 把 USDC/USDT 互換，互換比例(價格)隨意

3. 實作一個 `provideLiquidity(addrerss _tokenIn, uint256 _amount)` 可以把 USDC 或 USDT 存進去

4. 實作一個 `_calculateSwapOutAmount(address _tokenIn, address _tokenOut, uint256 _amountIn) returns (uint256 amountOut)`，並把他使用在 swap 內，並滿足兩個條件 
(1) _amountIn 越高， amountOut 越高，但 _amountIn / amountOut 比值(價格)要越高，例如 10 USDC 可以換 10 USDT，但 20 USDC 只能換 18 USDT
(2) 合約內 _tokenIn / _tokenOut 比值越高，_amountIn / amountOut 比值(價格)越高

5. 把 provideLiquidity 改成同時提供兩個幣種，`provideLiquidity(addrerss _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB)` 且合約只會拿走比值跟合約內 token 比例一樣的數字，例如合約內有 100 USDC + 200 USDT， _tokenA = USDC, _tokenB = USDT, _amountA = 100, _amountB = 100，則合約只應該拿走 50 USDC + 100 USDT

6. 讓 provideLiquidity 會發送 ERC20 LP token 給用戶，且 `發送的數量 / LP total supply` = `提供流動性的數量 / 合約內的 token 數量`，例如以第五題的例子，原本 LP total supply = 1e18，那應該發給用戶 5e17

7. 實作 `removeLiquidity(uint256 _amount)` 讓合約收回 LP token，並按比例把 USDC/USDT 還給用戶

進階題:
- 在實作的 AMM 中加上手續費的機制，對於每一筆換幣交易收取 0.3% 的手續費（使用 X 代幣購買 Y 代幣時收取 0.3% 的 X 代幣），
  並確保該交易對中的流動性提供者可以根據提供流動性的比例均分手續費

- 學習 [Uniswap V3](https://docs.uniswap.org/protocol/introduction)

- 學習 [Curve](https://curve.readthedocs.io/)

## 參考資料
- [What Is an Automated Market Maker?](https://www.coindesk.com/learn/2021/08/20/what-is-an-automated-market-maker/)

- [Uniswap v2 實作 : 從創建交易對到Ether 換 Dai 投入 Compound](https://medium.com/taipei-ethereum-meetup/uniswap-v2-implementation-and-combination-with-compound-262ff338efa)

- [淺談無常損失 (Impermanent Loss) 及其避險方式](https://medium.com/@cic.ethan/%E6%B7%BA%E8%AB%87%E7%84%A1%E5%B8%B8%E6%90%8D%E5%A4%B1-impermanent-loss-%E5%8F%8A%E5%85%B6%E9%81%BF%E9%9A%AA%E6%96%B9%E5%BC%8F-2ec23978b767)

- [Uniswap v3 详解](https://liaoph.com/uniswap-v3-1/)


---
[回階段三](./README.md)

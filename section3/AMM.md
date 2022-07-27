# 自動化做市商（Automated Market Maker, AMM）


請先理解什麼是 AMM（[Uniswap V2](https://docs.uniswap.org/protocol/V2/introduction)），並實作一個簡單的 AMM 並且在不考慮手續費的情況下可以做到以下三件事：
1. 添加交易對流動性
2. 移除交易對流動性
3. 換幣（Swap）

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

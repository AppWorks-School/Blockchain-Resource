# 借貸協議與閃電貸（Flash Loan）

## 目的：理解區塊鏈的借貸協議怎麼做，以及閃電貸怎麼使用
請賞析 [Compound](https://docs.compound.finance/v2/) 的合約，並依序實作以下
1. 撰寫一個 Foundry 的 Script，該 Script 要能夠部署一個 CErc20Delegator(`CErc20Delegator.sol`，以下簡稱 cERC20)，一個 Unitroller(`Unitroller.sol`) 以及他們的 Implementation 合約和合約初始化時相關必要合約。請遵循以下細節：
    * cERC20 的 decimals 皆為 18
    * 自行部署一個 cERC20 的 underlying ERC20 token，decimals 為 18
    * 使用 `SimplePriceOracle` 作為 Oracle
    * 使用 `WhitePaperInterestRateModel` 作為利率模型，利率模型合約中的借貸利率設定為 0%
    * 初始 exchangeRate 為 1:1

2. 讓 User1 mint/redeem cERC20，請透過 Foundry test case (你可以繼承上題的 script 或是用其他方式實現部署) 實現以下場景：
    * User1 使用 100 顆（100 * 10^18） ERC20 去 mint 出 100 cERC20 token，再用 100 cERC20 token redeem 回 100 顆 ERC20 

3. 讓 User1 borrow/repay
    * 部署第二份 cERC20 合約，以下稱它們的 underlying tokens 為 token A 與 token B。
    * 在 Oracle 中設定一顆 token A 的價格為 $1，一顆 token B 的價格為 $100
    * Token B 的 collateral factor 為 50%
    * User1 使用 1 顆 token B 來 mint cToken
    * User1 使用 token B 作為抵押品來借出 50 顆 token A

4. 延續 (3.) 的借貸場景，調整 token B 的 collateral factor，讓 User1 被 User2 清算

5. 延續 (3.) 的借貸場景，調整 oracle 中 token B 的價格，讓 User1 被 User2 清算

6. 請使用 Foundry 的 fork testing 模式撰寫測試，並使用 AAVE v3 的 [Flash loan](https://docs.aave.com/developers/guides/flash-loans) 來清算 User1，請遵循以下細節：
    * Fork Ethereum mainnet at block  17465000([Reference](https://book.getfoundry.sh/forge/fork-testing#examples))
    * cERC20 的 decimals 皆為 18，初始 exchangeRate 為 1:1
    * Close factor 設定為 50%
    * Liquidation incentive 設為 8% (1.08 * 1e18)
    * 使用 USDC 以及 UNI 代幣來作為 token A 以及 Token B
    * 在 Oracle 中設定 USDC 的價格為 $1，UNI 的價格為 $5
    * 設定 UNI 的 collateral factor 為 50%
    * User1 使用 1000 顆 UNI 作為抵押品借出 2500 顆 USDC
    * 將 UNI 價格改為 $4 使 User1 產生 Shortfall，並讓 User2 透過 AAVE 的 Flash loan 來借錢清算 User1
    * 可以自行檢查清算 50% 後是不是大約可以賺 63 USDC
    * 在合約中如需將 UNI 換成 USDC 可以使用以下程式碼片段：
    ```javascript
    // https://docs.uniswap.org/protocol/guides/swaps/single-swaps

    ISwapRouter.ExactInputSingleParams memory swapParams =
      ISwapRouter.ExactInputSingleParams({
        tokenIn: UNI_ADDRESS,
        tokenOut: USDC_ADDRESS,
        fee: 3000, // 0.3%
        recipient: address(this),
        deadline: block.timestamp,
        amountIn: uniAmount,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
      });

    // The call to `exactInputSingle` executes the swap.
    // swap Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564
    uint256 amountOut = swapRouter.exactInputSingle(swapParams);
    ```

進階題: 
1. 使用一套治理框架（例如 Governor Bravo 加上 Timelock）完成 Comptroller 中的設置
2. 賞析 [UniswapAnchoredView](https://etherscan.io/address/0x50ce56A3239671Ab62f185704Caedf626352741e#code) 合約並使用其作為 Comptroller 中設置的 oracle 來實現清算
3. 設計一個能透過 Flash loan 清算多種代幣類型的智能合約
4. 研究 [Aave](https://aave.com/) 協議，比較這些借貸協議在功能上與合約開發上的差異

## 參考資料

---
[回階段三](./README.md)

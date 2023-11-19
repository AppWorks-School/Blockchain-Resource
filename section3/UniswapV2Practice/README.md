# UniswapV2Practice
In `UniswapV2Practice.t.sol`, we have four practices and two discussions. Please follow the instructions provided in the comments to successfully pass the tests.

# Reentrancy Practice
Please exploit the bank contract in `Bank.t.sol`

## Reference:
- UniswapV2-core: https://github.com/Uniswap/v2-core
- UniswapV2-periphery: https://github.com/Uniswap/v2-periphery

## Environment
- Add `MAINNET_RPC_ENDPOINT` to `foundry.toml`

## Local Development
Clone this repository, install Node.js dependencies, and build the source code:

```bash
git clone git@github.com:AppWorks-School/Blockchain-Resource.git
cd Blockchain-Resource/section3/UniswapV2Practice
forge install
forge build
forge test
```

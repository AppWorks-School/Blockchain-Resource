# SimpleSwap
Implement a simple AMM swap (0% fee ratio) contract in `contracts/SimpleSwap.sol`. You must override all the external functions of `ISimpleSwap.sol`, and pass all the tests in `test/SimpleSwap.spec.ts`.

Suggest reading the `natSpec` of `ISimpleSwap.sol` first and then implementing the contract. If you are not sure what the function is about, feel free to discuss it in the Discord channel.

Reference:
- UniswapV2-core: https://github.com/Uniswap/v2-core
- UniswapV2-periphery: https://github.com/Uniswap/v2-periphery


## Local Development
You need Node.js 16+ to build. Use [nvm](https://github.com/nvm-sh/nvm) to install it.

Clone this repository, install Node.js dependencies, and build the source code:

```bash
git clone git@github.com:AppWorks-School/Blockchain-Resource.git
cd Blockchain-Resource/section3/SimpleSwap
npm install
npm run build
npm run test
```


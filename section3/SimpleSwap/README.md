# SimpleSwap
Implement a **Simple AMM Swap** contract with a **0% fee** ratio in `contracts/SimpleSwap.sol`. Ensure that you **override all the external functions defined in `ISimpleSwap.sol`**, and that the implementation passes all the tests.

It is recommended to first read the NatSpec documentation in `ISimpleSwap.sol` before implementing the contract. If there are any uncertainties regarding the function's purpose or implementation, feel free to discuss them in the Discord channel.

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
npm run test:hardhat
npm run test:foundry
```


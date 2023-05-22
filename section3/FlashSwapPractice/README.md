# Flash Swap Practice
This is a UniswapV2 flash swap practice, our goal is to pass the test.

### Practice 1: `Liquidator.sol`
`liquidate()` will call `FakeLendingProtocol.liquidatePosition()` to liquidate the position of the user.
Follow the instructions in `contracts/Liquidator.sol` to complete the practice.
(Do not change any other files)

### Practice 2: `Arbitrage.sol`
`arbitrage()` will do the arbitrage between the given two pools (must be the same pair).
Follow the instructions in `contracts/Arbitrage.sol` to complete the practice.
For convenience, we will only practice method 1, and fix the borrowed amount to 5 WETH

If you are interested in the flash swap arbitrage, you can read more in this [repository](https://github.com/paco0x/amm-arbitrageur)

## Local Development
Clone this repository, install Node.js dependencies, and build the source code:

```bash
git clone git@github.com:AppWorks-School/Blockchain-Resource.git
cd Blockchain-Resource/section3/FlashSwapPractice
npm install
forge install
forge build
forge test
```


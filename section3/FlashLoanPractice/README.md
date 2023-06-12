# Flash Loan Practice

Welcome to the Flash Loan Practice repository! The main purpose of this repository is to provide a platform for everyone to practice using flash loan and gain familiarity with its operational principles.

## Exercise 1

In this exercise, you will practice how to use flash loans in Aave v3. You need to implement `src/AaveFlashLoan.sol` to pass the tests in `test/AaveFlashLoan.t.sol`. In order to pass the test, you need to borrow enough USDC in the contract, and call the `checkBalance` function in the `BalanceChecker` contract.

## Exercise 2
In this exercise, you will learn how to use flash swaps in Uniswap v2 to liquidate positions in Compound v2. You need to implement `src/FlashSwapLiquidate.sol` to pass the tests in `test/FlashSwapLiquidate.t.sol`. In order to pass the test, you need to borrow money through Uniswap v2, liquidate a specified address's USDC lending position in Compound v2, and realize a profit in Dai tokens (the balance of Dai should finally be greater than 0).

## Environment Setup

To get started with the Compound Practice repository, follow the steps below:

1. Clone the repository:

   ```shell
   git clone git@github.com:AppWorks-School/Blockchain-Resource.git
   ```

2. Navigate to the Compound Practice directory:

   ```shell
   cd Blockchain-Resource/section3/FlashLoanPractice
   ```

3. Install the necessary dependencies:

   ```shell
   forge install
   ```

4. Build the project:

   ```shell
   forge build
   ```

5. Run the tests:

   ```shell
   forge test
   ```

Feel free to explore the code and dive into the exercises provided to enhance your understanding of flash loan. Happy practicing!

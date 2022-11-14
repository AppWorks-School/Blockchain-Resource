import { ethers } from "hardhat"
import { SimpleSwap, SimpleSwap__factory, TestERC20, TestERC20__factory } from "../typechain-types"
export interface SimpleSwapFixture {
    simpleSwap: SimpleSwap
    tokenA: TestERC20
    tokenB: TestERC20
}

export async function deploySimpleSwapFixture(): Promise<SimpleSwapFixture> {
    // Deploy tokenA, tokenB
    const ERC20Factory = (await ethers.getContractFactory("TestERC20")) as TestERC20__factory

    const tokenA = (await ERC20Factory.deploy("TokenA", "TokenA")) as TestERC20
    await tokenA.deployed()

    const tokenB = (await ERC20Factory.deploy("TokenB", "TokenB")) as TestERC20
    await tokenB.deployed()

    // Deploy SimpleSwap
    const SimpleSwapFactory = (await ethers.getContractFactory("SimpleSwap")) as SimpleSwap__factory
    const simpleSwap = (await SimpleSwapFactory.deploy(tokenA.address, tokenB.address)) as SimpleSwap
    await simpleSwap.deployed()

    return {
        simpleSwap,
        tokenA,
        tokenB,
    }
}

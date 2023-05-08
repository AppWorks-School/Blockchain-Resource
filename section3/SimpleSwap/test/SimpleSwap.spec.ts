import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { expect } from "chai"
import { BigNumber } from "ethers"
import { parseUnits } from "ethers/lib/utils"
import { ethers } from "hardhat"
import { SimpleSwap, SimpleSwap__factory, TestERC20 } from "../typechain-types"
import { deploySimpleSwapFixture, SimpleSwapFixture } from "./fixtures"
import { sqrt } from "./utils"

describe("SimpleSwap Spec", () => {
    let taker: SignerWithAddress
    let maker: SignerWithAddress
    let fixture: SimpleSwapFixture
    let simpleSwap: SimpleSwap
    let tokenA: TestERC20
    let tokenB: TestERC20
    let tokenADecimals: number
    let tokenBDecimals: number
    let slpDecimals: number

    beforeEach(async () => {
        // maker = liquidity provider
        // trader = taker
        ;[, taker, maker] = await ethers.getSigners()

        fixture = await loadFixture(deploySimpleSwapFixture)
        simpleSwap = fixture.simpleSwap
        tokenA = fixture.tokenA
        tokenB = fixture.tokenB

        tokenADecimals = await tokenA.decimals()
        tokenBDecimals = await tokenB.decimals()
        slpDecimals = await simpleSwap.decimals()

        // Mint tokenA to trader, maker
        await tokenA.mint(taker.address, parseUnits("1000", tokenADecimals))
        await tokenA.mint(maker.address, parseUnits("1000", tokenADecimals))

        // Mint tokenB to trader, maker
        await tokenB.mint(taker.address, parseUnits("1000", tokenBDecimals))
        await tokenB.mint(maker.address, parseUnits("1000", tokenBDecimals))

        // Approve tokenA to simpleSwap
        await tokenA.connect(taker).approve(simpleSwap.address, parseUnits("1000", tokenADecimals))
        await tokenA.connect(maker).approve(simpleSwap.address, parseUnits("1000", tokenADecimals))
        await tokenB.connect(taker).approve(simpleSwap.address, parseUnits("1000", tokenBDecimals))
        await tokenB.connect(maker).approve(simpleSwap.address, parseUnits("1000", tokenBDecimals))
    })

    describe("# constructor", () => {
        let simpleSwapFactory: SimpleSwap__factory

        beforeEach(async () => {
            simpleSwapFactory = await ethers.getContractFactory("SimpleSwap")
        })

        it("forces error, when tokenA is not a contract", async () => {
            await expect(simpleSwapFactory.deploy(ethers.constants.AddressZero, tokenB.address)).to.be.revertedWith(
                "SimpleSwap: TOKENA_IS_NOT_CONTRACT",
            )
        })

        it("forces error, when tokenB is not a contract", async () => {
            await expect(simpleSwapFactory.deploy(tokenA.address, ethers.constants.AddressZero)).to.be.revertedWith(
                "SimpleSwap: TOKENB_IS_NOT_CONTRACT",
            )
        })

        it("forces error, when tokenA is the same as tokenB", async () => {
            await expect(simpleSwapFactory.deploy(tokenA.address, tokenA.address)).to.be.revertedWith(
                "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS",
            )
        })

        it("reserves should be zero after contract initialized", async () => {
            const [reserve0, reserve1] = await simpleSwap.getReserves()

            expect(reserve0).to.be.eq(0)
            expect(reserve1).to.be.eq(0)
        })

        it("tokenA's address should be less than tokenB's address", async () => {
            const tokenA = (await simpleSwap.getTokenA()).toLowerCase()
            const tokenB = (await simpleSwap.getTokenB()).toLowerCase()

            expect(tokenA < tokenB).to.be.eq(true)
        })
    })

    describe("# addLiquidity", () => {
        describe("first time to add liquidity", () => {
            it("forces error, when tokenA amount is zero", async () => {
                const amountA = parseUnits("0", tokenADecimals)
                const amountB = parseUnits("42", tokenBDecimals)

                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB)).to.revertedWith(
                    "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT",
                )
            })

            it("forces error, when tokenB amount is zero", async () => {
                const amountA = parseUnits("42", tokenADecimals)
                const amountB = parseUnits("0", tokenBDecimals)

                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB)).to.revertedWith(
                    "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT",
                )
            })

            it("should be able to add liquidity", async () => {
                const amountA = parseUnits("42", tokenADecimals)
                const amountB = parseUnits("420", tokenBDecimals)
                const liquidity = sqrt(amountA.mul(amountB))

                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                    .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA.mul(-1), amountA])
                    .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB.mul(-1), amountB])
                    .to.emit(simpleSwap, "AddLiquidity")
                    .withArgs(maker.address, amountA, amountB, liquidity)

                const [reserveA, reserveB] = await simpleSwap.getReserves()

                expect(reserveA).to.be.eq(amountA)
                expect(reserveB).to.be.eq(amountB)
            })
        })

        describe("not first time to add liquidity", () => {
            let reserveAAfterFirstAddLiquidity: BigNumber
            let reserveBAfterFirstAddLiquidity: BigNumber

            beforeEach(async () => {
                // after beforeEach
                // SLP total supply is sqrt(45 * 20) = 30
                // SimpleSwap reserveA is 45
                // SimpleSwap reserveB is 20

                const amountA = parseUnits("45", tokenADecimals)
                const amountB = parseUnits("20", tokenBDecimals)
                await simpleSwap.connect(maker).addLiquidity(amountA, amountB)
                ;[reserveAAfterFirstAddLiquidity, reserveBAfterFirstAddLiquidity] = await simpleSwap.getReserves()
            })

            it("forces error, when tokenA amount is zero", async () => {
                const amountA = parseUnits("0", tokenADecimals)
                const amountB = parseUnits("42", tokenBDecimals)

                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB)).to.revertedWith(
                    "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT",
                )
            })

            it("forces error, when tokenB amount is zero", async () => {
                const amountA = parseUnits("42", tokenADecimals)
                const amountB = parseUnits("0", tokenBDecimals)

                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB)).to.revertedWith(
                    "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT",
                )
            })

            it("should be able to add liquidity when tokenA's proportion is the same as tokenB's proportion", async () => {
                const amountA = parseUnits("90", tokenADecimals)
                const amountB = parseUnits("40", tokenBDecimals) // amountA / reserveA * reserveB = 90 / 45 * 20 = 40
                const liquidity = sqrt(amountA.mul(amountB))

                // check event and balanceChanged
                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                    .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA.mul(-1), amountA])
                    .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB.mul(-1), amountB])
                    .to.emit(simpleSwap, "AddLiquidity")
                    .withArgs(maker.address, amountA, amountB, liquidity)

                const [reserveA, reserveB] = await simpleSwap.getReserves()

                // check reserve after addLiquidity
                expect(reserveA).to.be.eq(reserveAAfterFirstAddLiquidity.add(amountA))
                expect(reserveB).to.be.eq(reserveBAfterFirstAddLiquidity.add(amountB))
            })

            it("should be able to add liquidity when tokenA's proportion is greater than tokenB's proportion", async () => {
                const amountA = parseUnits("90", tokenADecimals)
                const amountB = parseUnits("50", tokenBDecimals) // 50 > amountA / reserveA * reserveB = 90 / 45 * 20 = 40
                const actualAmountB = amountA.mul(reserveBAfterFirstAddLiquidity).div(reserveAAfterFirstAddLiquidity)
                const liquidity = sqrt(amountA.mul(actualAmountB))

                // check event and balanceChanged
                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                    .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA.mul(-1), amountA])
                    .to.changeTokenBalances(tokenB, [maker, simpleSwap], [actualAmountB.mul(-1), actualAmountB])
                    .to.emit(simpleSwap, "AddLiquidity")
                    .withArgs(maker.address, amountA, actualAmountB, liquidity)

                const [reserveA, reserveB] = await simpleSwap.getReserves()

                // check reserve after addLiquidity
                expect(reserveA).to.be.eq(reserveAAfterFirstAddLiquidity.add(amountA))
                expect(reserveB).to.be.eq(reserveBAfterFirstAddLiquidity.add(actualAmountB))
            })

            it("should be able to add liquidity when tokenA's proportion is less than tokenB's proportion", async () => {
                const amountA = parseUnits("100", tokenADecimals) // 100 > amountB * reserveA / reserveB = 40 * 45 / 20 = 90
                const amountB = parseUnits("40", tokenBDecimals)
                const actualAmountA = amountB.mul(reserveAAfterFirstAddLiquidity).div(reserveBAfterFirstAddLiquidity)
                const liquidity = sqrt(actualAmountA.mul(amountB))

                // check event and balanceChanged
                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                    .to.changeTokenBalances(tokenA, [maker, simpleSwap], [actualAmountA.mul(-1), actualAmountA])
                    .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB.mul(-1), amountB])
                    .to.emit(simpleSwap, "AddLiquidity")
                    .withArgs(maker.address, actualAmountA, amountB, liquidity)

                const [reserveA, reserveB] = await simpleSwap.getReserves()

                // check reserve after addLiquidity
                expect(reserveA).to.be.eq(reserveAAfterFirstAddLiquidity.add(actualAmountA))
                expect(reserveB).to.be.eq(reserveBAfterFirstAddLiquidity.add(amountB))
            })

            it("should be able to add liquidity after swap", async () => {
                const tokenIn = tokenA.address
                const tokenOut = tokenB.address
                const amountIn = parseUnits("45", tokenADecimals)

                await simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)

                const [reserveAAfterSwap, reserveBAfterSwap] = await simpleSwap.getReserves()

                const amountA = parseUnits("18", tokenADecimals)
                const amountB = parseUnits("2", tokenBDecimals) // amountB = amountA / reserveA * reserveB = 18 / 90 * 10 = 2
                const totalSupply = await simpleSwap.totalSupply() // 30

                const liquidityA = amountA.mul(totalSupply).div(reserveAAfterSwap) // 18 * 30 / 90 = 6
                const liquidityB = amountB.mul(totalSupply).div(reserveBAfterSwap) // 2 * 30 / 10 = 6
                const liquidity = liquidityA.lt(liquidityB) ? liquidityA : liquidityB // 6
                // check event and balanceChanged
                await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                    .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA.mul(-1), amountA])
                    .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB.mul(-1), amountB])
                    .to.changeTokenBalance(simpleSwap, maker, liquidity)
                    .to.emit(simpleSwap, "AddLiquidity")
                    .withArgs(maker.address, amountA, amountB, liquidity)

                const [reserveA, reserveB] = await simpleSwap.getReserves()

                // check reserve after addLiquidity
                expect(reserveA).to.be.eq(reserveAAfterSwap.add(amountA))
                expect(reserveB).to.be.eq(reserveBAfterSwap.add(amountB))
            })
        })
    })

    describe("# swap", () => {
        beforeEach("maker add liquidity", async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)
        })

        it("forces error, when tokenIn is not tokenA or tokenB", async () => {
            const tokenIn = ethers.constants.AddressZero
            const tokenOut = tokenB.address
            const amountIn = parseUnits("10", tokenADecimals)

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)).to.revertedWith(
                "SimpleSwap: INVALID_TOKEN_IN",
            )
        })

        it("forces error, when tokenOut is not tokenA or tokenB", async () => {
            const tokenIn = tokenA.address
            const tokenOut = ethers.constants.AddressZero
            const amountIn = parseUnits("10", tokenADecimals)

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)).to.revertedWith(
                "SimpleSwap: INVALID_TOKEN_OUT",
            )
        })

        it("forces error, when tokenIn is the same as tokenOut", async () => {
            const tokenIn = tokenA.address
            const tokenOut = tokenA.address
            const amountIn = parseUnits("10", tokenADecimals)

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)).to.revertedWith(
                "SimpleSwap: IDENTICAL_ADDRESS",
            )
        })

        it("forces error, when amountIn is zero", async () => {
            const tokenIn = tokenA.address
            const tokenOut = tokenB.address
            const amountIn = parseUnits("0", tokenADecimals)

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)).to.revertedWith(
                "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT",
            )
        })

        it("forces error, when amountOut is zero", async () => {
            const tokenIn = tokenA.address
            const tokenOut = tokenB.address
            const amountIn = 1

            // Amount can not be zero
            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)).to.revertedWith(
                "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT",
            )
        })

        it("should be able to swap from tokenA to tokenB", async () => {
            const tokenIn = tokenA.address
            const tokenOut = tokenB.address
            const amountIn = parseUnits("100", tokenADecimals)
            const amountOut = parseUnits("50", tokenBDecimals) // 100 * 100 / (100 + 100) = 50

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn))
                .to.changeTokenBalances(tokenA, [taker, simpleSwap], [amountIn.mul(-1), amountIn])
                .to.changeTokenBalances(tokenB, [taker, simpleSwap], [amountOut, amountOut.mul(-1)])
                .emit(simpleSwap, "Swap")
                .withArgs(taker.address, tokenIn, tokenOut, amountIn, amountOut)

            const [reserveA, reserveB] = await simpleSwap.getReserves()
            expect(reserveA).to.equal(parseUnits("200", tokenADecimals));
            expect(reserveB).to.equal(parseUnits("50", tokenBDecimals));
        })

        it("should be able to swap from tokenB to tokenA", async () => {
            const tokenIn = tokenB.address
            const tokenOut = tokenA.address
            const amountIn = parseUnits("100", tokenADecimals)
            const amountOut = parseUnits("50", tokenBDecimals) // 100 * 100 / (100 + 100) = 50

            await expect(simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn))
                .to.changeTokenBalances(tokenA, [taker, simpleSwap], [amountOut, amountOut.mul(-1)])
                .to.changeTokenBalances(tokenB, [taker, simpleSwap], [amountIn.mul(-1), amountIn])
                .emit(simpleSwap, "Swap")
                .withArgs(taker.address, tokenIn, tokenOut, amountIn, amountOut)

            const [reserveA, reserveB] = await simpleSwap.getReserves()
            expect(reserveA).to.equal(parseUnits("50", tokenADecimals));
            expect(reserveB).to.equal(parseUnits("200", tokenBDecimals));
        })
    })

    describe("# removeLiquidity", () => {
        beforeEach("maker add liquidity", async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)

            await simpleSwap.connect(maker).approve(simpleSwap.address, ethers.constants.MaxUint256)
        })

        it("forces error, when lp token amount is zero", async () => {
            await expect(simpleSwap.connect(maker).removeLiquidity(parseUnits("0", slpDecimals))).to.revertedWith(
                "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED",
            )
        })

        // skip this, because ERC20 will handle this error
        it.skip("forces error, when lp token amount is greater than maker balance")

        it("should be able to remove liquidity when lp token amount greater than zero", async () => {
            const lpTokenAmount = parseUnits("10", slpDecimals)
            const [reserveA, reserveB] = await simpleSwap.getReserves()
            const totalSupply = await simpleSwap.totalSupply()
            const amountA = lpTokenAmount.mul(reserveA).div(totalSupply)
            const amountB = lpTokenAmount.mul(reserveB).div(totalSupply)

            await expect(simpleSwap.connect(maker).removeLiquidity(lpTokenAmount))
                .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA, amountA.mul(-1)])
                .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB, amountB.mul(-1)])
                .to.emit(simpleSwap, "RemoveLiquidity")
                .withArgs(maker.address, amountA, amountB, lpTokenAmount)
        })

        it("should be able to remove liquidity after swap", async () => {
            // taker swap 10 tokenA to tokenB
            await simpleSwap.connect(taker).swap(tokenA.address, tokenB.address, parseUnits("10", tokenADecimals))

            // maker remove liquidity
            const lpTokenAmount = parseUnits("10", slpDecimals)
            const [reserveA, reserveB] = await simpleSwap.getReserves()
            const totalSupply = await simpleSwap.totalSupply()
            const amountA = lpTokenAmount.mul(reserveA).div(totalSupply)
            const amountB = lpTokenAmount.mul(reserveB).div(totalSupply)
            await expect(simpleSwap.connect(maker).removeLiquidity(lpTokenAmount))
                .to.changeTokenBalances(tokenA, [maker, simpleSwap], [amountA, amountA.mul(-1)])
                .to.changeTokenBalances(tokenB, [maker, simpleSwap], [amountB, amountB.mul(-1)])
                .to.emit(simpleSwap, "RemoveLiquidity")
                .withArgs(maker.address, amountA, amountB, lpTokenAmount)
        })
    })

    describe("# getReserves", () => {
        it("should be able to get reserves", async () => {
            const [reserveA, reserveB] = await simpleSwap.getReserves()
            expect(reserveA).to.eq(0)
            expect(reserveB).to.eq(0)
        })

        it("should update reserves after add liquidity", async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)

            const [reserveA, reserveB] = await simpleSwap.getReserves()
            expect(reserveA).to.eq(amountA)
            expect(reserveB).to.eq(amountB)
        })

        describe("when there is already some liquidity", async () => {
          beforeEach(async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)
          });

          it("should update reserves after remove liquidity", async () => {
              await simpleSwap.connect(maker).approve(simpleSwap.address, parseUnits("100", slpDecimals))
              await simpleSwap.connect(maker).removeLiquidity(parseUnits("100", slpDecimals))

              const [reserveA, reserveB] = await simpleSwap.getReserves()
              expect(reserveA).to.eq(0)
              expect(reserveB).to.eq(0)
          })
          
        });

    })

    describe("# getTokenA", () => {
        it("should be able to get tokenA", async () => {
            const tokenAAddress = await simpleSwap.getTokenA()
            expect(tokenAAddress).to.eq(tokenA.address)
        })
    })

    describe("# getTokenB", () => {
        it("should be able to get tokenB", async () => {
            const tokenBAddress = await simpleSwap.getTokenB()
            expect(tokenBAddress).to.eq(tokenB.address)
        })
    })

    describe("lp token", () => {
        beforeEach("maker add liquidity", async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)

            await simpleSwap.connect(maker).approve(simpleSwap.address, ethers.constants.MaxUint256)
        })

        it("should be able to get lp token after adding liquidity", async () => {
            const amountA = parseUnits("100", tokenADecimals)
            const amountB = parseUnits("100", tokenBDecimals)
            const liquidity = sqrt(amountA.mul(amountB))

            await expect(simpleSwap.connect(maker).addLiquidity(amountA, amountB))
                .to.changeTokenBalances(simpleSwap, [maker], [liquidity])
                .to.emit(simpleSwap, "Transfer")
                .withArgs(ethers.constants.AddressZero, maker.address, liquidity)
        })

        it("should be able to repay lp token after removing liquidity", async () => {
            const lpTokenAmount = parseUnits("10", slpDecimals)

            await expect(simpleSwap.connect(maker).removeLiquidity(lpTokenAmount))
                .to.changeTokenBalances(simpleSwap, [maker], [lpTokenAmount.mul(-1)])
                .to.emit(simpleSwap, "Transfer")
                .withArgs(simpleSwap.address, ethers.constants.AddressZero, lpTokenAmount)
        })

        it("should be able to transfer lp token", async () => {
            const lpTokenAmount = parseUnits("42", slpDecimals)

            await expect(simpleSwap.connect(maker).transfer(taker.address, lpTokenAmount))
                .to.changeTokenBalances(simpleSwap, [maker, taker], [lpTokenAmount.mul(-1), lpTokenAmount])
                .to.emit(simpleSwap, "Transfer")
                .withArgs(maker.address, taker.address, lpTokenAmount)
        })

        it("should be able to approve lp token", async () => {
            const lpTokenAmount = parseUnits("42", slpDecimals)

            await expect(simpleSwap.connect(maker).approve(taker.address, lpTokenAmount))
                .to.emit(simpleSwap, "Approval")
                .withArgs(maker.address, taker.address, lpTokenAmount)
        })
    })

    describe("K value checking", () => {
        let K: BigNumber

        beforeEach("maker add liquidity", async () => {
            const amountA = parseUnits("30", tokenADecimals)
            const amountB = parseUnits("300", tokenBDecimals)
            await simpleSwap.connect(maker).addLiquidity(amountA, amountB)

            K = amountA.mul(amountB)
        })

        it("k value should be greater than equal the same after swap", async () => {
            const tokenIn = tokenA.address
            const tokenOut = tokenB.address
            const amountIn = parseUnits("70", tokenADecimals)

            await simpleSwap.connect(taker).swap(tokenIn, tokenOut, amountIn)

            const [reserveA, reserveB] = await simpleSwap.getReserves()

            expect(reserveA.mul(reserveB)).to.be.gte(K)
        })
    })
})

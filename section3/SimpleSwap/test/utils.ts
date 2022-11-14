import bn from "bignumber.js"
import { BigNumber } from "ethers"

export function sqrt(value: BigNumber): BigNumber {
    return BigNumber.from(new bn(value.toString()).sqrt().toFixed().split(".")[0])
}

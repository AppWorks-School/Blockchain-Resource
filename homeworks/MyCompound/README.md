## MyCompound

## Sepolia testnet deployment contract address

| Contract Name | Address |
| --- | --- |
| Unitroller | 0xC21e7eC69e539d4026188F29a0199E91c3A53465 |
| Comptroller | 0x5358508C08441a11316c776a690505A7c04BFf91 |
| SimplePriceOracle | 0xaF61d5EA93a25a727b971D248CAD4961DBA9e843 |
| MyERC20 | 0x1A4D4E655f49e711Ca02a8639483621EC3eaE437 |
| CErc20Delegate | 0x93fe443bDf651810B1cb15a2c7FF2fC3b4B66376 |
| WhitePaperInterestRateModel | 0x2D23ebd386157d02368440B78C40DEC79aeee523 |
| CErc20Delegator | 0x7DCE5d55d5c95928D9cd5301280E227Aa9A71D5a |


## Usage

### Install

```shell
$ forge install
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

* Create `.env` in the project and set following variable

```
# your private key
P_KEY = 0x0123....
# CErc20Delegator contract admin address
ADMIN = 0x9876....
```

* Update foundry.toml to replace SEPOLIA_RPC_URL & ETHERSCAN_API_KEY to your information

* run the following command to deploy MyCompound contract

```shell
$ forge script script/MyCompound.s.sol:MyCompoundScript --rpc-url "${RPC_URL}" --broadcast --verify
````
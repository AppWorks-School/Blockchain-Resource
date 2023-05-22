// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { IUniswapV2Factory } from "v2-core/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router01 } from "v2-periphery/interfaces/IUniswapV2Router01.sol";
import { TestWETH9 } from "../../contracts/test/TestWETH9.sol";
import { TestERC20 } from "../../contracts/test/TestERC20.sol";

contract FlashSwapSetUp is Test {
    TestWETH9 public weth;
    TestERC20 public usdc;
    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Factory public sushiSwapV2Factory;
    IUniswapV2Router01 public uniswapV2Router;
    IUniswapV2Router01 public sushiSwapV2Router;
    IUniswapV2Pair public wethUsdcPool;
    IUniswapV2Pair public wethUsdcSushiPool;

    function setUp() public virtual {
        usdc = _create_erc20("USD Coin", "USDC", 6);
        weth = _create_weth9();
        uniswapV2Factory = _create_uniswap_v2_factory();
        sushiSwapV2Factory = _create_uniswap_v2_factory();
        uniswapV2Router = _create_uniswap_v2_router(address(uniswapV2Factory), address(weth));
        sushiSwapV2Router = _create_uniswap_v2_router(address(sushiSwapV2Factory), address(weth));
        wethUsdcPool = _create_pool(address(uniswapV2Factory), address(weth), address(usdc));
        wethUsdcSushiPool = _create_pool(address(sushiSwapV2Factory), address(weth), address(usdc));

        vm.label(address(uniswapV2Factory), "UniswapV2Factory");
        vm.label(address(sushiSwapV2Factory), "SushiSwapV2Factory");
        vm.label(address(uniswapV2Router), "UniswapV2Router");
        vm.label(address(sushiSwapV2Router), "SushiSwapV2Router");
        vm.label(address(wethUsdcPool), "WethUsdcPool");
        vm.label(address(wethUsdcSushiPool), "WethUsdcSushiPool");
        vm.label(address(weth), "WETH9");
        vm.label(address(usdc), "USDC");
    }

    function _create_weth9() public returns (TestWETH9) {
        weth = new TestWETH9();
        return weth;
    }

    function _create_erc20(string memory name, string memory symbol, uint8 decimals) public returns (TestERC20) {
        usdc = new TestERC20(name, symbol, decimals);
        return usdc;
    }

    function _create_pool(address factory, address tokenA, address tokenB) public returns (IUniswapV2Pair) {
        address pool = IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        return IUniswapV2Pair(pool);
    }

    function _create_uniswap_v2_factory() internal returns (IUniswapV2Factory) {
        string memory path = string(
            abi.encodePacked(vm.projectRoot(), "/node_modules/@uniswap/v2-core/build/UniswapV2Factory.json")
        );
        string memory artifact = vm.readFile(path);
        bytes memory creationCode = vm.parseBytes(abi.decode(vm.parseJson(artifact, ".bytecode"), (string)));
        creationCode = abi.encodePacked(creationCode, abi.encode(address(0)));
        address anotherAddress;

        assembly {
            anotherAddress := create(0, add(creationCode, 0x20), mload(creationCode))
        }

        return IUniswapV2Factory(anotherAddress);
    }

    function _create_uniswap_v2_router(address factory, address weth9) internal returns (IUniswapV2Router01) {
        string memory path = string(
            abi.encodePacked(vm.projectRoot(), "/node_modules/@uniswap/v2-periphery/build/UniswapV2Router01.json")
        );
        string memory artifact = vm.readFile(path);
        bytes memory creationCode = vm.parseBytes(abi.decode(vm.parseJson(artifact, ".bytecode"), (string)));

        creationCode = abi.encodePacked(creationCode, abi.encode(factory), abi.encode(weth9));
        address anotherAddress;

        assembly {
            anotherAddress := create(0, add(creationCode, 0x20), mload(creationCode))
        }

        return IUniswapV2Router01(anotherAddress);
    }
}

pragma solidity 0.8.19;

import { CErc20 } from "compound-protocol/contracts/CErc20.sol";
import { EIP20Interface } from "compound-protocol/contracts/EIP20Interface.sol";
import { Comptroller } from "compound-protocol/contracts/Comptroller.sol";
import "forge-std/Test.sol";

contract Borrower is Test {
  EIP20Interface public USDC = EIP20Interface(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  CErc20 public cDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
  Comptroller public comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
  address public admin = 0x6d903f6003cca6255D85CcA4D3B5E5146dC33925;

  function borrow() public {
    uint256 mintAmount = 1_000_000 * 10 ** 18;
    uint256 borrowAmount = 800_000 * 10 ** 6;

    deal(DAI, address(this), mintAmount);
    (bool success, ) = DAI.call(abi.encodeWithSignature("approve(address,uint256)", address(cDAI), mintAmount));
    require(success, "Approve failed");

    cDAI.mint(mintAmount);
    address[] memory addrs = new address[](1);
    addrs[0] = address(cDAI);
    comptroller.enterMarkets(addrs);
    
    cUSDC.borrow(borrowAmount);
    
    vm.prank(admin);
    uint256 err = comptroller._setCollateralFactor(cDAI, 0.7 * 1e18);
    require(err == 0, "Set collateral factor failed");
  }
}

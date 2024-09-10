// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketPlus} from "../src/NFTMarketPlus.sol";

contract NFTMarketPlusScript is Script {
    NFTMarketPlus public market;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        market = new NFTMarketPlus(0x5FbDB2315678afecb367f032d93F642f64180aa3);

        vm.stopBroadcast();
    }
}

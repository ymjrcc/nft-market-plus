// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketPlus} from "../src/NFTMarketPlus.sol";

contract NFTMarketPlusScript is Script {
    NFTMarketPlus public market;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        market = new NFTMarketPlus(0x3f0be47e94f78620496c4017FD8044772C676655);

        vm.stopBroadcast();
    }
}

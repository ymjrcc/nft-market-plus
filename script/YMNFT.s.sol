// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {YMNFT} from "../src/YMNFT.sol";

contract YMNFTScript is Script {
    YMNFT public nft;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nft = new YMNFT(msg.sender);

        vm.stopBroadcast();
    }
}

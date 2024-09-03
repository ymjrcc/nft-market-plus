// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {YMToken} from "../src/YMToken.sol";

contract YMTokenScript is Script {
    YMToken public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new YMToken(msg.sender);

        vm.stopBroadcast();
    }
}

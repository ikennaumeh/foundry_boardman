// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {Boardman} from "../src/Boardman.sol";

contract DeployBoardman is Script {
    function run() external returns(Boardman){
        vm.startBroadcast();
        Boardman boardman = new Boardman();
        vm.stopBroadcast();
        return boardman;
    }
}
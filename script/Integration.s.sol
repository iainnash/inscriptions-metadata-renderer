// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {InscriptionsStoredRenderer} from "../src/InscriptionsStoredRenderer.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        address target = vm.envAddress("TARGET");
        InscriptionsStoredRenderer renderer = InscriptionsStoredRenderer(vm.envAddress("RENDERER"));
        vm.startPrank(target);
        console2.log(renderer.contractURI());
        unchecked {
            for (uint256 i = 0 ; i < 780; i++) {
                console2.log(i+1);
                console2.log(renderer.tokenURI(i + 1));
            }
        }
    }
}

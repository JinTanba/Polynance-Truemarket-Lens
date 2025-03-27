// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PolynanceTruemarketLens.sol";

contract DeployPolynanceHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        PolynanceTruemarketLens helper = new PolynanceTruemarketLens();
        address[] memory list = helper.getAllActiveMarketsAddress();
        console.log(list[0]);
        PolynanceTruemarketLens.MarketDetail memory md = helper.getMarketdetail(list[0]);
        console.log(md.question);
        console.log("PolynanceTruemarketLens deployed at: ------>", address(helper));
        vm.stopBroadcast();
    }
}
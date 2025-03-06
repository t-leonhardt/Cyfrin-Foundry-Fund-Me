pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external returns (FundMe){
        
        HelperConfig helperConfig = new HelperConfig();
        // Declared/called befiore broadcast because anything before 
        // a broadcast is not a real transaction
        // meaning, it wont get sent to alchemy or real chain
        // and therefore wont cost any money 

        // before broadcast: not a real transaction 
        // after broadcast: real transaction 
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
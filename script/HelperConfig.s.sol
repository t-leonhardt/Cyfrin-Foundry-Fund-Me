// OBJECTIVES
//      1. Deploy mocks when using local anvil chain 
//      2. Keep track of contract addresses across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetwrokCOnfig{
        address priceFeed;
    }
    // necessary if either function needs to return more than 
    // just priceFeed address 

    NetwrokCOnfig public activeNetworkConfig;

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        else{
            activeNetworkConfig = getAnvilEthConfig();
        }
    }
    
    function getSepoliaEthConfig() public pure returns(NetwrokCOnfig memory) {
        NetwrokCOnfig memory sepoliaConfig = NetwrokCOnfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        // {priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306} is not necessary
        // it would also work with only the address; however, it is 
        // good practice to do it this way for better readibility 
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetwrokCOnfig memory) {
        NetwrokCOnfig memory ethMainnetConfig = NetwrokCOnfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethMainnetConfig;
    }

    function getAnvilEthConfig() public returns(NetwrokCOnfig memory){
        // since local networks/nodes do not have priceFeeds/contracts
        // they need to be developed for local use/testing
        
        if (activeNetworkConfig.priceFeed != address(0)){
            // address(0) is the default value/address 
            return activeNetworkConfig;
        }
        // if no anvil netowrk has been deployed, deploy one; 
        // otherwise (if one has already been created), use that one

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        // first number describes the decimals and ETH/USD has 8 decimals 
        // 2000 is the initial price chosen for local network 
        // e8 is necessary since it is 8 decimals 
        vm.stopBroadcast();

        NetwrokCOnfig memory anvilConfig = NetwrokCOnfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTets is Test{
    FundMe fundMe; 
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public{
        // test fails because fundMe is not initialzed by the user but 
        // by FundMeTest while msg.sender is user 

        console.log(fundMe.i_owner()); // FundMeTest
        console.log(msg.sender); // user address 
        //assertEq(fundMe.i_owner(), msg.sender);


        // assertEq(fundMe.i_owner(), address(this));

        assertEq(fundMe.i_owner(), msg.sender);
        // due to factorizing, user us caller again 
        
    }

    function testPriceFeedVersion() public {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }       
}
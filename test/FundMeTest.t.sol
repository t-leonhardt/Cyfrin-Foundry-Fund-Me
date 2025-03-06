pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTets is Test{
    FundMe fundMe; 

    address USER = makeAddr("User");
    // possible to create "fake" user to make testing easier 

    uint256 constant SEND_VALUE = 0.1 ether;

    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(USER, STARTING_BALANCE);
        // cheatcode to equip user with resources 
        // ususally only used for testing
        // needed for testFundUpdatesFundedDataStructure since user does not 
        // have any resource initially 
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

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        // this line tells the porgam that the next line will fail; meaning,
        // if the next line would not fail, e.g. uint8 number = 2; 
        // vm.expectRevert() makes it fail 
        // if the line would be failing the test, vm.expectRevert() makes it pass 

        // trial
        fundMe.fund(); 
        // should fail because we send no arguments, but function needs
        // arguments and function needs the amount to be at least
        // 5 USD
    }

    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER); 
        // tells the test that the next call/transaction will be sent by user 

        fundMe.fund{value: SEND_VALUE}();


        uint256 amoountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amoountFunded, SEND_VALUE);
    }
}
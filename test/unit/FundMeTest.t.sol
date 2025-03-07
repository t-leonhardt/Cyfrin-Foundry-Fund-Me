pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTets is Test{
    FundMe fundMe; 

    address USER = makeAddr("User");
    // possible to create "fake" user to make testing easier 

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

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

        // console.log(fundMe.i_owner()); // FundMeTest
        // console.log(msg.sender); // user address 
        //assertEq(fundMe.i_owner(), msg.sender);


        // assertEq(fundMe.i_owner(), address(this));

        assertEq(fundMe.getI_Owner(), msg.sender);
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

    function testFundUpdatesFundedDataStructure() public funded{
        uint256 amoountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amoountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayofFunders() public funded{
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithDrawWithASingleFunder() public funded{
        // Arrange (arrange/setup the test)
        uint256 startingOwnerBalance = fundMe.getI_Owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (do the action that is supposed to be tested)
        uint256 gasStart = gasleft();
        // build in function that tells how much gas is left in the transaction call
        vm.txGasPrice(GAS_PRICE);
        // simulate gas price on networks 
        vm.prank(fundMe.getI_Owner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //tx.gasprice is a build in function that tells the current price of gas 
        console.log(gasUsed);

        // Assert (assert the test)
        uint256 endingOwnerBalance = fundMe.getI_Owner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithDrawWithMultipleFunders() public funded{
        // ARRANGE 

        uint160 numberOfFunders = 10;
        // uint160 necessary to cast to an address 
        // since it has the same number of bytes

        uint160 startingFunderIndex = 2;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // hoax does the same as vm.prank and vm.deal combined
            hoax(address(i), SEND_VALUE);  
            fundMe.fund{value: SEND_VALUE}();  
        }

        uint256 startingOwnerBalance = fundMe.getI_Owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // ACT
        
        vm.startPrank(fundMe.getI_Owner());
        fundMe.withdraw();
        vm.stopPrank();
        // same as vm.prank() with the difference that it is not only
        // the next line but all lines in between the startng and 
        // closing statement
        // similar to startBroadcast and stopBroadcast 


        // ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getI_Owner().balance);
    }

    function testWithDrawWithMultipleFundersCheaper() public funded{
        // ARRANGE 

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);  
            fundMe.fund{value: SEND_VALUE}();  
        }

        uint256 startingOwnerBalance = fundMe.getI_Owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // ACT
        
        vm.startPrank(fundMe.getI_Owner());
        fundMe.cheaperWithDraw();
        vm.stopPrank();


        // ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getI_Owner().balance);
    }
}
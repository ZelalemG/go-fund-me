//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/*
@title Go Fund Me (with Best practice)
@license GNU GPLv3
@author Zelalem Gebrekirstos
@notice A crowd funding contract to create funding campaigns with specific goal
    and able to withdraw when closed. 
    This project demonestrates best practices to achive high security and low gas fees.
*/

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GoFundMe is PullPayment {
    string campainName;
    address owner;
    uint minimumDonation;
    uint targetFund;
    bool campainIsActive;
    uint totalFund;
    
    address[] donators;
    mapping (address => uint) donations;

    // using EnumerableMap for EnumerableMap.AddressToUintMap;
    // EnumerableMap.AddressToUintMap public donators;

    function init(string memory _campaignName, uint _minDonation, uint _targetFund) external {
        owner = msg.sender;
        campainName = _campaignName;
        minimumDonation = _minDonation;
        targetFund = _targetFund;
    }

    modifier onlyOwner {
        if(msg.sender == owner){
            _;
        }
    }

    function makeDonation() external payable {
        uint _amount = msg.value;
        require(campainIsActive, "Campaign not currently active");        
        require(_amount >= minimumDonation, string(abi.encodePacked("Minimum donation is ", minimumDonation)));
        donations[msg.sender] = _amount;
        donators.push(msg.sender);        

        //close campain if target is reached\\
        if(address(this).balance >= targetFund){
            campainIsActive = false;            
        }
    }

    function withdraw () public onlyOwner {
        require(!campainIsActive, "Campaign not closed yet");
        
        //using the asyncTransfer func from openzeppelin PullPayment
        //contract is safer as its stored in an intermediate Escrow contract
        _asyncTransfer(owner, totalFund);
        console.log("Funds delivered to owner. Amount = %s", totalFund);
        console.log("Funds delivered to owner. Amount = %s", totalFund);

    }

    //TODO: Just addred to experiment security bypass
    // remove it once done... :)
    function tester(string memory name) public view  {
        
        console.log("Executed...", name);
    }

    function closeCampaign () external onlyOwner (){
        campainIsActive = false;
        console.log("Campaign cancelled by owner!");
    }



}
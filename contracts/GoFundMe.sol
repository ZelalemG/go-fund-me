//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/*
@title Go Fund Me (with Best practice)
@license GNU GPLv3
@author Zelalem Gebrekirstos
@notice A crowd funding contract to create funding campaigns with specific goal 
(target fund) and able to withdraw when the campaign is closed. 
This project demonestrates best practices to achive high security and low gas fees.

@Notice You may read a detailed explanation of my blog at http://zillo.one/blog-go-fund-me
or reach me out via info@zillo.one
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
    mapping(address => uint) donations;

    /*  you can also alteratively use enumerable maps from openzeppelin 
        to manage donators such as get No. of donators...like below

        using EnumerableMap for EnumerableMap.AddressToUintMap;
        EnumerableMap.AddressToUintMap public donators;
    */

    function init(
        string memory _campaignName,
        uint _minDonation,
        uint _targetFund
    ) external {
        owner = msg.sender;
        campainName = _campaignName;
        minimumDonation = _minDonation;
        targetFund = _targetFund;
    }

    modifier onlyOwner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function makeDonation() external payable {
        uint _amount = msg.value;
        require(campainIsActive, "Campaign not currently active");
        require(
            _amount >= minimumDonation,
            string(abi.encodePacked("Minimum donation is ", minimumDonation))
        );
        donations[msg.sender] = _amount;
        totalFund += _amount;
        donators.push(msg.sender);

        //close campain if target is reached\\
        if (address(this).balance >= targetFund) {
            campainIsActive = false;
        }
    }

    function withdraw() public onlyOwner {
        require(!campainIsActive, "Campaign not closed yet");
        require(
            address(this).balance > minimumDonation,
            "insufficient balance"
        );

        //using the asyncTransfer func from openzeppelin PullPayment
        //contract is safer as its stored in an intermediate Escrow contract
        _asyncTransfer(owner, totalFund);
        console.log("Funds delivered to owner. Amount = %s", totalFund);
        console.log("Funds delivered to owner. Amount = %s", totalFund);
    }

    function closeCampaign() external onlyOwner {
        campainIsActive = false;
        console.log("Campaign cancelled by owner!");
    }

    function checkCampaignStatus()
        public
        view
        onlyOwner
        returns (string memory _status)
    {
        if (campainIsActive) {
            _status = "Active";
        }
        return _status = "Closed";
    }
}

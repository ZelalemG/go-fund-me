//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './CloneFactory.sol';
import './GoFundMe.sol';

contract Factory is CloneFactory {
     GoFundMe[] public campaigns;
     address parentAddress;

     constructor(address _parentAddress){
         parentAddress = _parentAddress;
     }

     function createcampaign(string memory campaignName, uint _minDonation, uint _targetFund) external{
        GoFundMe campaign = GoFundMe(createClone(parentAddress));
        campaign.init(campaignName, _minDonation, _targetFund);
        campaigns.push(campaign);
     }

     function getcampaigns() external view returns(GoFundMe[] memory){
         return campaigns;
     }
}
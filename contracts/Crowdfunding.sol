// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract Crowdfunding {
    
    struct Campaign {
        string name;                 // The name of the campaign
        string description;          // Brief description of the campaign
        address payable benefactor;  // The campaign creator who will receive the funds
        uint256 goal;                // The funding goal for the campaign(wei)
        uint256 deadline;            // The deadline for the campaign in UNIX timestamp
        uint256 amountCollected;     // The total amount of funds collected
        bool fundsTransferred;       // Whether the funds have been transferred to the benefactor
    }
    
    
    uint256 public campaignCount = 0;

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event CampaignCreated(string name, string description, uint256 campaignId, address benefactor, uint256 goal, uint256 deadline);
    event DonationReceived(uint256 campaignId, address donor, uint256 amount);
    event FundsTransferred(uint256 campaignId, address benefactor, uint256 amount);

    // Modifier to ensure the campaign is still active
    modifier isCampaignActive(uint256 _campaignId) {
        require(block.timestamp < campaigns[_campaignId].deadline, "Campaign has ended.");
        _;
    }

    // Modifier to ensure the campaign has ended
    modifier isCampaignEnded(uint256 _campaignId) {
        require(block.timestamp >= campaigns[_campaignId].deadline, "Campaign is still active.");
        _;
    }

    // Function to create a new campaign
    function createCampaign(string memory _name, string memory _description, uint256 _goal, uint256 _durationInSeconds) public {
        require(_goal > 0, "Goal must be greater than zero.");
        
        campaignCount += 1;
        // uint256 deadline = _durationInSeconds;
        
        campaigns[campaignCount] = Campaign({
            name: _name,
            description: _description,
            benefactor: payable(msg.sender),
            goal: _goal,
            deadline: _durationInSeconds,
            amountCollected: 0,
            fundsTransferred: false
        });

        emit CampaignCreated(_name, _description, campaignCount, msg.sender, _goal, _durationInSeconds);
    }

    // Function to contribute to an active campaign
    function contribute(uint256 _campaignId) public payable isCampaignEnded(_campaignId) {
        require(msg.value > 0, "Contribution amount must be greater than zero.");

        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountCollected += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;
         //(bool sent, ) = address(this).call{value: msg.value}("");
        //require(sent, "Failed to send Ether");
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to automatically transfer funds to the benefactor after the campaign ends
    function transferFunds(uint256 _campaignId) public isCampaignEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.fundsTransferred, "Funds have already been transferred.");
        require(block.timestamp >= campaign.deadline, "Deadline not yet reached");

        uint256 amount = campaign.amountCollected;
        campaign.fundsTransferred = true;
        (bool sent, ) = campaign.benefactor.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit FundsTransferred(_campaignId, campaign.benefactor, amount);
    }

    // Function to check the details of a campaign
    function getCampaignDetails(uint256 _campaignId) public view returns (
        address benefactor, 
        uint256 goal, 
        uint256 deadline, 
        uint256 amountCollected, 
        bool fundsTransferred
    ) {
        Campaign memory campaign = campaigns[_campaignId];
        return (
            campaign.benefactor, 
            campaign.goal, 
            campaign.deadline, 
            campaign.amountCollected, 
            campaign.fundsTransferred
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";


contract DonationTracker {
    address public immutable owner;

    struct Donation{
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Donation) public donations;

    //un evento per ogni funzione (non obbligatorio ma rende tutto molto efficente)
    event DonationReceived(address indexed donor, uint256 amount);
    event OwnerWithdrawed(address indexed by, uint256 amount);
    event DonorWithdrawed(address indexed donor, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function donate() external payable {
        require(msg.value > 0, "you must donate something");
        donations[msg.sender].amount += msg.value;
        donations[msg.sender].timestamp = block.timestamp;

        emit DonationReceived(msg.sender, msg.value);
    }

    function ownerWithdraw(uint256 amount) external {

        require(msg.sender == owner, "only the owner can withdraw");
        require(address(this).balance >= amount); //controlla se i soldi che ci sono nel contratto sono uguali o superiori a quello che si vuole prelevare
        payable(owner).transfer(amount);

        emit OwnerWithdrawed(msg.sender, amount);
    }   

    function donorWithdraw() external  {
        Donation storage donation = donations[msg.sender];
        require(donation.amount > 0, "you can only withdraw the funds you donated!");
        require(block.timestamp >= donation.timestamp + 30 days, "the funds can only be withdrawn after 30 days");

        uint256 amount = donation.amount;
        donation.amount = 0;
        payable(msg.sender).transfer(amount);
        emit DonorWithdrawed(msg.sender, amount);
    }

    function getMoneyInTheContract() public view returns (uint256) {
        require(msg.sender == owner);
        return address(this).balance;
    }
}


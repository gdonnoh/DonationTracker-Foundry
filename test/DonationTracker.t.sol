// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/DonationTracker.sol";

contract DonationTrackerTest is Test {

    DonationTracker public tracker;

    address owner = address(0x123);     // msg.sender nel costruttore
    address donor1 = address(0x1);
    address donor2 = address(0x2);

    function setUp() public {
        vm.prank(owner);        // simula msg.sender = owner   
        tracker = new DonationTracker();
    }

    function testDonateAndTrack() public {
    uint256 donationAmount = 1 ether;

    vm.deal(donor1, 2 ether);                      // assegna 2 ETH a donor1
    vm.prank(donor1);                              // simula msg.sender = donor1
    tracker.donate{value: donationAmount}();       // invia 1 ETH

    (uint256 amount, uint256 timestamp) = tracker.donations(donor1);
    assertEq(amount, donationAmount);              // controllo che siano registrati 1 ETH
    assertTrue(timestamp > 0);                     // controllo che il timestamp sia stato salvato
}


    function testOwnerWithdraw() public {
        uint256 donationAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;

        // Donor1 dona
        vm.deal(donor1, 1 ether);
        vm.prank(donor1);
        tracker.donate{value: donationAmount}();

        uint256 balanceBefore = owner.balance;  // Owner prima del prelievo cioè 0

        // Owner preleva
        vm.prank(owner);
        tracker.ownerWithdraw(withdrawAmount);

        uint256 balanceAfter = owner.balance;  // Owner dopo il prelievo cioè 0.5 ether
        assertEq(balanceAfter - balanceBefore, withdrawAmount); //
    }

    function testDonorWithdrawAfter30Days() public {
        uint256 donationAmount = 1 ether;

        vm.deal(donor2, 2 ether);
        vm.prank(donor2);
        tracker.donate{value: donationAmount}();

        // Avanza il tempo di 30 giorni
        vm.warp(block.timestamp + 30 days);

        uint256 balanceBefore = donor2.balance;

        vm.prank(donor2);
        tracker.donorWithdraw();

        uint256 balanceAfter = donor2.balance;
        assertEq(balanceAfter - balanceBefore, donationAmount);
    }

    function testDonorWithdrawTooEarlyFails() public {
        uint256 donationAmount = 1 ether;

        vm.deal(donor1, 2 ether);
        vm.prank(donor1);
        tracker.donate{value: donationAmount}();

        // Non aspettiamo 30 giorni
        vm.prank(donor1);
        vm.expectRevert("the funds can only be withdrawn after 30 days");
        tracker.donorWithdraw();
    }

    function testOnlyOwnerCanWithdraw() public {
        uint256 donationAmount = 1 ether;

        vm.deal(donor1, 1 ether);
        vm.prank(donor1);
        tracker.donate{value: donationAmount}();

        // Donor1 prova a prelevare come owner
        vm.prank(donor1);
        vm.expectRevert("only the owner can withdraw");
        tracker.ownerWithdraw(0.5 ether);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {TechCrushBank} from "../src/TechCrushBank.sol";

contract TestTechCrushBank is Test {
    address Emmanuel = makeAddr("Emmanuel");
    address John = makeAddr("John");

    TechCrushBank public bank;

    function setUp() public {
        vm.prank(Emmanuel);
        bank = new TechCrushBank(Emmanuel);
    }

    //  CREATE ACCOUNT

    function testCreateAccount() public {
        vm.deal(Emmanuel, 1 ether);

        vm.prank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");

        (string memory name,, address addr, bool active) = bank.accounts(Emmanuel);

        assertEq(name, "Emma");
        assertEq(addr, Emmanuel);
        assertTrue(active);
    }

    function testCreateAccountFailLowFee() public {
        vm.deal(Emmanuel, 1 ether);

        vm.prank(Emmanuel);
        vm.expectRevert();
        bank.createAccount{value: 1}("Low");
    }

    function testOnlyOwnerCanCreate() public {
        vm.deal(John, 1 ether);

        vm.prank(John);
        vm.expectRevert();
        bank.createAccount{value: 1e16}("John");
    }

    //  DEPOSIT

    function testDeposit() public {
        vm.deal(Emmanuel, 2 ether);

        vm.startPrank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");
        bank.userDeposit{value: 1 ether}();

        (, uint256 bal,,) = bank.accounts(Emmanuel);
        assertEq(bal, 1 ether);
    }

    //  WITHDRAW

    function testWithdraw() public {
        vm.deal(Emmanuel, 2 ether);

        vm.startPrank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");
        bank.userDeposit{value: 1 ether}();

        bank.userWithdraw(0.5 ether);

        (, uint256 bal,,) = bank.accounts(Emmanuel);
        assertEq(bal, 0.5 ether);
    }

    // TRANSFER

    function testTransfer() public {
        vm.deal(Emmanuel, 2 ether);

        vm.startPrank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");
        bank.userDeposit{value: 1 ether}();

        // self transfer (since only owner has account)
        bank.transferToUsers(Emmanuel, 0.5 ether);

        (, uint256 bal,,) = bank.accounts(Emmanuel);
        assertEq(bal, 1 ether);
    }

    //  CLOSE ACCOUNT

    function testCloseAccount() public {
        vm.deal(Emmanuel, 2 ether);

        vm.startPrank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");
        bank.userDeposit{value: 1 ether}();

        bank.closeAccount();

        (, uint256 bal,, bool active) = bank.accounts(Emmanuel);

        assertEq(bal, 0);
        assertFalse(active);
    }

    //  TOTAL FEE

    function testTotalFee() public {
        vm.deal(Emmanuel, 1 ether);

        vm.prank(Emmanuel);
        bank.createAccount{value: 1e16}("Emma");

        assertEq(bank.totalFee(), 1e16);
    }
}

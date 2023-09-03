// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("Alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(
            initialAllowance - transferAmount,
            ourToken.allowance(bob, alice)
        );
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    // Additional tests by claude

    function testTransfer() public {
        uint initialBalance = ourToken.balanceOf(bob);

        vm.prank(bob);

        ourToken.transfer(address(0x1), 100);

        assertEq(ourToken.balanceOf(bob), initialBalance - 100);

        assertEq(ourToken.balanceOf(address(0x1)), 100);
    }

    function testTransferFrom() public {
        vm.prank(bob);

        ourToken.approve(alice, 100);

        uint initialBalance = ourToken.balanceOf(bob);

        vm.prank(alice);

        ourToken.transferFrom(bob, address(0x1), 100);

        assertEq(ourToken.balanceOf(bob), initialBalance - 100);

        assertEq(ourToken.balanceOf(address(0x1)), 100);
    }

    function testAllowance() public {
        ourToken.approve(address(0x1), 100);

        assertEq(ourToken.allowance(address(this), address(0x1)), 100);
    }

    /*  _burn internal function
    function testBurn() public {
        uint initialBalance = ourToken.balanceOf(bob);
        uint initialSupply = ourToken.totalSupply();
        vm.prank(bob);
        ourToken._burn(bob, 100);

        assertEq(ourToken.balanceOf(bob), initialBalance - 100);
        assertEq(ourToken.totalSupply(), initialSupply - 100);
    }
    */

    // Additional coverage by claude

    function testFailTransferInsufficientBalance() public {
        ourToken.transfer(address(0x1), 100000);
    }

    function testFailTransferFromInsufficientAllowance() public {
        ourToken.approve(address(this), 10);

        ourToken.transferFrom(address(this), address(0x1), 100);
    }

    function testFailTransferToZeroAddress() public {
        ourToken.transfer(address(0), 100);
    }
}

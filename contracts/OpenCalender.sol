// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract OpenCalender {
    address payable public author;

    constructor() public {
        author = msg.sender;
    }

    // user information holder
    struct User {
        string name;
        string description;
        uint256 totalMeetingCount;
        uint256 activeMeetingCount;
        mapping(uint256 => bytes32) meetings;
    }
}

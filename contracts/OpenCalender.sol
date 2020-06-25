// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract OpenCalender {
    address payable public author;

    constructor() public {
        author = msg.sender;
    }

    // holds information regarding available timeslot(s) a user is
    // offering, when meetings can be scheduled
    struct MeetingSlot {
        uint256 from;
        uint256 to;
    }

    enum MeetingStatus {Pending, Active, Cancelled, Rescheduled, Done}

    // holds information related to meetings
    struct Meeting {
        string topic;
        address requestor;
        address requestee;
        MeetingSlot slot;
        MeetingStatus status;
    }

    // user information holder
    struct User {
        string name;
        bool active;
        uint256 slotCount;
        mapping(uint256 => MeetingSlot) slots;
        uint256 meetingCount;
        mapping(uint256 => bytes32) meetings;
    }

    uint256 userCount;
    mapping(address => User) users;

    uint256 meetingCount;
    mapping(bytes32 => Meeting) meetings;

    modifier onlyAuthor() {
        require(author == msg.sender, "You're not author !");
        _;
    }

    modifier registeredUser(address _addr) {
        require(users[_addr].active, "You're not registered !");
        _;
    }

    // gets number of users registered on dApp,
    // though only author can check this
    function getUserCount() public view onlyAuthor returns (uint256) {
        return userCount;
    }

    // returns number of meetings ever scheduled in dApp
    // only owner can look this up
    function getMeetingCount() public view onlyAuthor returns (uint256) {
        return meetingCount;
    }

    // returns address of author of this smart contract
    function getAuthor() public view returns (address) {
        return author;
    }

    // given address of user account, checks whether user is registered on system or not
    function isUserRegistered(address _addr)
        public
        view
        registeredUser(msg.sender)
        returns (bool)
    {
        return users[_addr].active;
    }

    // user name from address of account, given
    // msg.sender is already registered in dApp
    function userNameByAddress(address _addr)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (string memory)
    {
        return users[_addr].name;
    }
}

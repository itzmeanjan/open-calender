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

    enum MeetingStatus {Pending, Confirmed}

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
        uint256 meetingCount;
        mapping(uint256 => bytes32) meetings;
    }

    uint256 userCount;
    mapping(address => User) users;

    uint256 meetingCount;
    mapping(bytes32 => Meeting) meetings;

    event NewUser(address user, string name, uint256 timeStamp);

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

    // given address of user account, checks whether user is registered on system or not
    function isUserRegistered(address _addr)
        public
        view
        registeredUser(msg.sender)
        returns (bool)
    {
        return users[_addr].active;
    }

    // returns number of meetings for msg.sender account
    function myMeetingCount()
        public
        view
        registeredUser(msg.sender)
        returns (uint256)
    {
        return users[msg.sender].meetingCount;
    }

    // returns unique meeting id by index of meeting ( index for msg.sender account )
    // msg.sender must be registered in dApp
    function myMeetingIdByIndex(uint256 _index)
        public
        view
        registeredUser(msg.sender)
        returns (bytes32)
    {
        require(
            _index >= 0 && _index < users[msg.sender].meetingCount,
            "Invalid meeting index !"
        );

        return users[msg.sender].meetings[_index];
    }

    // register msg.sender in dApp, given that person isn't registered
    // throws an event, can be helpful in keeping track of created new user accounts, + {timestamp included}
    function registerMe(string memory _name) public {
        require(!users[msg.sender].active, "You're already registered !");

        users[msg.sender].name = _name;
        users[msg.sender].active = true;

        emit NewUser(msg.sender, _name, now);
    }
}

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
        bool active;
        uint256 totalMeetingCount;
        uint256 activeMeetingCount;
        mapping(uint256 => bytes32) meetings;
    }

    uint256 userCount;
    mapping(address => User) users;

    // holds information related to meetings
    struct Meeting {
        bytes32 id;
        address requestee;
        address requestor;
        uint256 scheduledFrom;
        uint256 scheduledTo;
        bool active;
    }

    uint256 meetingCount;
    mapping(bytes32 => Meeting) meetings;
    mapping(bytes32 => address) meetingToUser;

    modifier onlyAuthor() {
        require(author == msg.sender, "You're not author !");
        _;
    }

    modifier registeredUser(address _addr) {
        require(users[_addr].active, "You're not registered !");
        _;
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

    // checks whether msg.sender is registered on dApp or not
    function amIRegistered() public view returns (bool) {
        return users[msg.sender].active;
    }

    // gets number of users registered on dApp,
    // though only author can check this
    function getUserCount() public view onlyAuthor returns (uint256) {
        return userCount;
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

    // returns user name of msg.sender
    function myNameByAddress()
        public
        view
        registeredUser(msg.sender)
        returns (string memory)
    {
        return users[msg.sender].name;
    }

    // user description from address of account, given
    // msg.sender is already registered in dApp
    function userDescriptionByAddress(address _addr)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (string memory)
    {
        return users[_addr].description;
    }

    // returns user description of msg.sender
    function myDescriptionByAddress()
        public
        view
        registeredUser(msg.sender)
        returns (string memory)
    {
        return users[msg.sender].description;
    }

    // #-of meetings user has attended, given
    // msg.sender is already registered in dApp
    function userTotalMeetingCountByAddress(address _addr)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (uint256)
    {
        return users[_addr].totalMeetingCount;
    }

    // returns total #-of meetings attended by user,
    // given msg.sender is already registered on dApp
    function myTotalMeetingCountByAddress()
        public
        view
        registeredUser(msg.sender)
        returns (uint256)
    {
        return users[msg.sender].totalMeetingCount;
    }

    // #-of active meetings user is having, given
    // msg.sender is already registered in dApp
    function userActiveMeetingCountByAddress(address _addr)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (uint256)
    {
        return users[_addr].activeMeetingCount;
    }

    // returns #-of active meetings user is having,
    // given msg.sender is already registered on dApp
    function myActiveMeetingCountByAddress()
        public
        view
        registeredUser(msg.sender)
        returns (uint256)
    {
        return users[msg.sender].activeMeetingCount;
    }

    // given user address & meeting
    // index ( >=0 && < total_number_of_user_attended_meetings ),
    // it looks up unique meeting id
    function userMeetingByAddressAndIndex(address _addr, uint256 _index)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (bytes32)
    {
        require(
            _index >= 0 && _index < users[_addr].totalMeetingCount,
            "Invalid meeting index !"
        );

        return users[_addr].meetings[_index];
    }

    // given meeting index ( >=0 && < total_number_of_user_attended_meetings ),
    // it looks up unique meeting id, for account of msg.sender
    function myMeetingByAddressAndIndex(uint256 _index)
        public
        view
        registeredUser(msg.sender)
        returns (bytes32)
    {
        require(
            _index >= 0 && _index < users[msg.sender].totalMeetingCount,
            "Invalid meeting index !"
        );

        return users[msg.sender].meetings[_index];
    }

    // checks whether given meetingId is having a non-zero owner or not
    // if no, then meeting doesn't actually exist !
    modifier meetingExists(bytes32 _meetingId) {
        require(
            meetingToUser[_meetingId] != address(0),
            "Meeting doesn't exist !"
        );
        _;
    }

    // get meeting creator's acount from given meeting Id
    function getCreatorByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (address)
    {
        return meetingToUser[_meetingId];
    }

    // given meetingId, returns meeting requestee's address
    function getMeetingRequesteeByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (address)
    {
        return meetings[_meetingId].requestee;
    }

    // given meetingId, returns meeting requestor's address
    function getMeetingRequestorByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (address)
    {
        return meetings[_meetingId].requestor;
    }
}

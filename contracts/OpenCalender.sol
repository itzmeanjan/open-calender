// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract OpenCalender {
    address payable public author;

    constructor() public {
        author = msg.sender;
    }

    // holds information regarding meeting time i.e. start time or end time
    struct MeetingTime {
        uint8 day;
        uint8 month;
        uint8 year;
        uint8 hour;
        uint8 minute;
    }

    // holds information regarding available timeslot(s) a user is
    // offering, when meetings can be scheduled
    struct MeetingSlot {
        MeetingTime from;
        MeetingTime to;
    }

    // user information holder
    struct User {
        string name;
        string description;
        bool active;
        uint256 totalMeetingCount;
        uint256 activeMeetingCount;
        mapping(uint256 => bytes32) meetings;
        uint256 meetingSlotCount;
        mapping(uint256 => MeetingSlot) meetingSlots;
    }

    uint256 userCount;
    mapping(address => User) users;

    enum MeetingStatus {Active, Cancelled, Rescheduled, Done}

    // holds information related to meetings
    struct Meeting {
        bytes32 id;
        address requestee;
        address requestor;
        uint256 scheduledFrom;
        uint256 scheduledTo;
        MeetingStatus status;
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

    // #-of meeting slots a user is having, given
    // msg.sender & _addr is already registered in dApp
    function userMeetingSlotCountByAddress(address _addr)
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (uint256)
    {
        return users[_addr].meetingSlotCount;
    }

    // returns #-of meeting slots user ( i.e. msg.sender) is having
    function myMeetingSlotCountByAddress()
        public
        view
        registeredUser(msg.sender)
        returns (uint256)
    {
        return users[msg.sender].meetingSlotCount;
    }

    // given user account address & index of meeting slot,
    // returns start time as a tuple of (day, month, year, hour, minute) items
    function userMeetingSlotStartTimeByAddressAndIndex(
        address _addr,
        uint256 _index
    )
        public
        view
        registeredUser(msg.sender)
        registeredUser(_addr)
        returns (
            uint8,
            uint8,
            uint8,
            uint8,
            uint8
        )
    {
        require(
            _index >= 0 && _index < users[_addr].meetingSlotCount,
            "Invalid meeting slot index !"
        );

        MeetingTime memory from = users[_addr].meetingSlots[_index].from;

        return (from.day, from.month, from.year, from.hour, from.minute);
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

    // given meetingId, returns meeting's scheduled from timestamp
    function getScheduledFromByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (uint256)
    {
        return meetings[_meetingId].scheduledFrom;
    }

    // given meetingId, returns meeting's scheduled to timestamp
    function getScheduledToByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (uint256)
    {
        return meetings[_meetingId].scheduledTo;
    }

    // returns whether this meeting is active
    function isMeetingActiveByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (bool)
    {
        return meetings[_meetingId].status == MeetingStatus.Active;
    }

    // returns whether this meeting is cancelled
    function isMeetingCancelledByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (bool)
    {
        return meetings[_meetingId].status == MeetingStatus.Cancelled;
    }

    // returns whether this meeting is rescheduled
    function isMeetingRescheduledByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (bool)
    {
        return meetings[_meetingId].status == MeetingStatus.Rescheduled;
    }

    // returns whether this meeting is done
    function isMeetingCompletedByMeetingId(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        meetingExists(_meetingId)
        returns (bool)
    {
        return meetings[_meetingId].status == MeetingStatus.Done;
    }
}

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

    enum MeetingStatus {Pending, Confirmed, Cancelled}

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
        uint256 meetingCountAsRequestor;
        uint256 meetingCountAsRequestee;
        mapping(uint256 => bytes32) meetings;
    }

    uint256 userCount;
    mapping(address => User) users;

    uint256 meetingCount;
    mapping(bytes32 => Meeting) meetings;

    event NewUser(address user, string name, uint256 timeStamp);
    event RequestMeeting(
        address indexed requestor,
        address indexed requestee,
        bytes32 meetingId,
        uint256 timeStamp
    );
    event ConfirmMeeting(
        address indexed requestor,
        address indexed requestee,
        bytes32 meetingId,
        uint256 timeStamp
    );
    event CancelMeeting(
        address indexed requestor,
        address indexed requestee,
        bytes32 meetingId,
        uint256 timeStamp
    );

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

    // returns total number of meetings for msg.sender account
    function myMeetingCount()
        public
        view
        registeredUser(msg.sender)
        returns (uint256)
    {
        return
            users[msg.sender].meetingCountAsRequestor +
            users[msg.sender].meetingCountAsRequestee;
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
            _index >= 0 &&
                _index <
                (users[msg.sender].meetingCountAsRequestor +
                    users[msg.sender].meetingCountAsRequestee),
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

    // checks whether _requestee of meeting is valid or not
    // _requestee can't be zero address
    // you can't request a meeting with yourself !!!
    modifier validRequestee(address _requestee) {
        require(
            _requestee != address(0) && _requestee != msg.sender,
            "Invalid requestee !"
        );
        _;
    }

    // meeting can be scheduled in future only i.e. _from & _to needs to be greater than
    // current timestamp
    //
    // _from needs to be lesser than _to
    modifier validMeetingSlot(uint256 _from, uint256 _to) {
        require(
            _from > now && _to > now && _from < _to,
            "Invalid meeting slot !"
        );
        _;
    }

    // lets msg.sender request a meeting on specified topic
    // at given timeslot
    //
    // Make sure you don't try to schedule a meeting with yourself
    // Check meeting slot time ( _from < _to )
    // Meeting is in pending state by default
    // emits event RequestMeeting
    function requestMeeting(
        string memory _topic,
        address _requestee,
        uint256 _from,
        uint256 _to
    )
        public
        registeredUser(msg.sender)
        registeredUser(_requestee)
        validRequestee(_requestee)
        validMeetingSlot(_from, _to)
    {
        bytes32 meetingId = keccak256(
            abi.encodePacked(msg.sender, _requestee, _topic, meetingCount)
        );

        Meeting memory meeting = Meeting(
            _topic,
            msg.sender,
            _requestee,
            MeetingSlot(_from, _to),
            MeetingStatus.Pending
        );

        meetings[meetingId] = meeting;
        meetingCount++;

        users[msg.sender].meetings[myMeetingCount()] = meetingId;
        users[msg.sender].meetingCountAsRequestor++;

        users[_requestee].meetings[(users[_requestee].meetingCountAsRequestor +
            users[_requestee].meetingCountAsRequestee)] = meetingId;
        users[_requestee].meetingCountAsRequestee++;

        emit RequestMeeting(msg.sender, _requestee, meetingId, now);
    }

    // checkpoint, which allows to only pass through,
    // if and only if msg.sender is requestee of this meetingId
    // i.e. only requestee can confirm a meeting
    modifier onlyMeetingRequestee(bytes32 _meetingId) {
        require(
            meetings[_meetingId].requestee == msg.sender,
            "You're not meeting requestee !"
        );
        _;
    }

    // checks whether meeting is in pending state or not
    // already {confirmed, cancelled} meeting can't be confirmed again
    modifier meetingPending(bytes32 _meetingId) {
        require(
            meetings[_meetingId].status == MeetingStatus.Pending,
            "Meeting not pending !"
        );
        _;
    }

    // given meetingId, msg.sender confirms meeting
    //
    // only meeting requestee for this meeting gets to successfully execute this function
    // meeting needs to be in pending state, only then it can be confirmed
    function confirmMeeting(bytes32 _meetingId)
        public
        registeredUser(msg.sender)
        onlyMeetingRequestee(_meetingId)
        meetingPending(_meetingId)
    {
        meetings[_meetingId].status = MeetingStatus.Confirmed;

        emit ConfirmMeeting(
            meetings[_meetingId].requestor,
            msg.sender,
            _meetingId,
            now
        );
    }

    // checks whether meeting is in any of these {pending, confirmed} state
    modifier meetingPendingOrConfirmed(bytes32 _meetingId) {
        require(
            meetings[_meetingId].status == MeetingStatus.Pending ||
                meetings[_meetingId].status == MeetingStatus.Confirmed,
            "Meeting neither pending or confirmed !"
        );
        _;
    }

    // sets a pending meeting cancelled, given the meetingId
    //
    // only meeting requestee for this meeting can successfully execute this function
    // meeting needs to be either in pending or confirmed state, only then it can be cancelled
    //
    // once cancelled, it can't be confirmed again ( yeah, then it's pretty immutable )
    function cancelMeeting(bytes32 _meetingId)
        public
        registeredUser(msg.sender)
        onlyMeetingRequestee(_meetingId)
        meetingPendingOrConfirmed(_meetingId)
    {
        meetings[_meetingId].status = MeetingStatus.Cancelled;

        emit CancelMeeting(
            meetings[_meetingId].requestor,
            msg.sender,
            _meetingId,
            now
        );
    }

    // checkpoint only allows to pass if invoker is either requestor or requestee
    modifier onlyRequestorOrRequestee(bytes32 _meetingId) {
        require(
            meetings[_meetingId].requestor == msg.sender ||
                meetings[_meetingId].requestee == msg.sender,
            "You're neither requestor nor requestee !"
        );
        _;
    }

    // meeting participants can look up, meeting topic
    function meetingTopic(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        onlyRequestorOrRequestee(_meetingId)
        returns (string memory)
    {
        return meetings[_meetingId].topic;
    }

    // given meetingId, when invoked by one participant,
    // returns address of another participant ( i.e. peer )
    function meetingPeer(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        onlyRequestorOrRequestee(_meetingId)
        returns (address)
    {
        if (meetings[_meetingId].requestor == msg.sender) {
            return meetings[_meetingId].requestee;
        } else {
            return meetings[_meetingId].requestor;
        }
    }

    // returns start and end time of meeting, when enquired by one of meeting participants
    function meetingTimeSlot(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        onlyRequestorOrRequestee(_meetingId)
        returns (uint256, uint256)
    {
        return (meetings[_meetingId].slot.from, meetings[_meetingId].slot.to);
    }

    // returns meeting status, when enquired by one of meeting participants
    function meetingStatus(bytes32 _meetingId)
        public
        view
        registeredUser(msg.sender)
        onlyRequestorOrRequestee(_meetingId)
        returns (MeetingStatus)
    {
        return meetings[_meetingId].status;
    }
}

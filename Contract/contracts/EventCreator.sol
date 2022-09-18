// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Ownable.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol"; // this contracts help us create roles
import "./Event.sol";

error EventCreator__EventAlreadyExists();
error EventCreator__EndDateMustBeGreaterThanStartDate();
error EventCreator__EventDateMustBeGreaterThanNow();
error EventCreator__EventDateMustBeGreaterThanPurchaseEndDate();
error EventCreator__YouDontOwnThisEvent();

contract EventCreator is PermissionsEnumerable, Ownable {
    struct EventInfo {
        string eventName;
        address eventOwner;
        uint256 eventDate;
        uint256 purchaseStartDate;
        uint256 purchaseEndDate;
        uint256 ticketPrice;
        address eventContract;
    }

    mapping(uint256 => EventInfo) private s_events;

    uint256 public s_eventId; // An id for the event
    address private s_priceFeedAddress;
    address private s_service;

    event EventCreated(
        address indexed eventAddress,
        address indexed eventOwner,
        uint256 indexed eventId
    );

    modifier NotCreated() {
        if (s_events[s_eventId].eventOwner != address(0)) {
            revert EventCreator__EventAlreadyExists();
        }
        _;
    }

    constructor(address priceFeedAddress, address service) {
        s_priceFeedAddress = priceFeedAddress;
        s_service = service;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createEvent(
        string memory _eventName,
        uint256 _eventDate,
        uint256 _purchaseStartDate,
        uint256 _ticketPrice,
        uint256 _purchaseEndDate,
        string memory _tokenUri
    ) public NotCreated {
        if (_eventDate < block.timestamp) {
            revert EventCreator__EventDateMustBeGreaterThanNow();
        }
        if (_purchaseStartDate > _purchaseEndDate) {
            revert EventCreator__EndDateMustBeGreaterThanStartDate();
        }
        if (_purchaseEndDate > _eventDate) {
            revert EventCreator__EventDateMustBeGreaterThanPurchaseEndDate();
        }

        s_eventId++;
        Event newEvent = new Event(
            _eventDate,
            _purchaseStartDate,
            _purchaseEndDate,
            _ticketPrice,
            payable(msg.sender),
            payable(s_service),
            s_priceFeedAddress,
            _eventName,
            _tokenUri
        );

        s_events[s_eventId] = EventInfo(
            _eventName,
            msg.sender,
            _eventDate,
            _purchaseStartDate,
            _purchaseEndDate,
            _ticketPrice,
            address(newEvent)
        );

        emit EventCreated(
            address(newEvent),
            msg.sender,
            s_eventId // tokenId of the nft
        );
    }

    function getEventInfo(uint256 _eventId)
        public
        view
        returns (EventInfo memory)
    {
        return s_events[_eventId];
    }

    function getEventId() public view returns (uint256) {
        return s_eventId;
    }

    function getPriceFeedAddress() public view returns (address) {
        return s_priceFeedAddress;
    }

    function getService() public view returns (address) {
        return s_service;
    }

    function setEventId(uint256 eventId) public onlyOwner {
        s_eventId = eventId;
    }

    function setPriceFeedAddress(address priceFeedAddress) public onlyOwner {
        s_priceFeedAddress = priceFeedAddress;
    }

    function setService(address service) public onlyOwner {
        s_service = service;
    }

    function _canSetOwner()
        internal
        view
        virtual
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return true;
    }
}

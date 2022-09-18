// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// we already have the ownable extension in this contract
import "@thirdweb-dev/contracts/base/ERC721Base.sol"; // this contract inherits ownable.sol already
import "./PriceConverter.sol";

error Event__PurchaseDatePassed();
error Event__PurchaseDateNotStarted();
error Event__NotEnoughCryptoSent();

contract Event is ERC721Base {
    using PriceConverter for uint256;

    uint256 private s_eventDate;
    uint256 private s_purchaseStartDate;
    uint256 private s_purchaseEndDate;

    uint256 private s_ticketPrice;
    bool public s_paused;

    address private immutable i_eventCreator;
    address private immutable i_service; // our wallet for service charge
    string private s_eventName;
    // details can get long, I think it's better to store somewhere else or contract will be expensive
    // string private s_eventDetails;
    string private s_baseUri;
    AggregatorV3Interface private s_priceFeed;

    modifier paused() {
        require(!s_paused, "Contract Paused: Try again later");
        _;
    }

    modifier eventCreatorOnly() {
        require(
            msg.sender == i_eventCreator,
            "Function can only be called by Event Creator"
        );
        _;
    }

    event TicketPurchase(address indexed winner, uint256 indexed tokenId); // not sure about this, need revision

    constructor(
        uint256 eventDate,
        uint256 purchaseStartDate,
        uint256 purchaseEndDate,
        uint256 ticketPrice,
        address eventCreator,
        address service,
        address priceFeedAddress,
        string memory eventName,
        // string memory eventDetails,
        string memory _baseUri
    )
        // string memory _name,
        // string memory _symbol,
        // address _royaltyRecipient,
        // uint128 _royaltyBps
        ERC721Base(eventName, "EVENT", msg.sender, 500)
    {
        s_eventDate = eventDate;
        s_purchaseStartDate = purchaseStartDate;
        s_purchaseEndDate = purchaseEndDate;
        s_ticketPrice = ticketPrice; // remember this has to be *1e18 to get the correct digit
        i_eventCreator = eventCreator;
        i_service = service; // we can either use constructor to designate from event creator contract or hard code here
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
        s_eventName = eventName;
        // s_eventDetails = eventDetails;
        s_baseUri = _baseUri; // calculate this in frontend
    }

    function purchaseTicket() public payable paused {
        // we can return vip or non vip state
        if (msg.value.getConversionRate(s_priceFeed) < s_ticketPrice) {
            revert Event__NotEnoughCryptoSent();
        }
        // warning due to possible time manipulation of few second by miners, you guys can decide if you want to change it
        if (block.timestamp > s_purchaseEndDate) {
            revert Event__PurchaseDatePassed();
        }
        if (block.timestamp < s_purchaseStartDate) {
            revert Event__PurchaseDateNotStarted();
        }

        // nft minting
        uint256 tokenId = nextTokenIdToMint(); // tokenId assigned to the next new NFT to be minted
        super.mintTo(msg.sender, s_baseUri); // minting in thirdweb function
        //.....

        emit TicketPurchase(
            msg.sender,
            tokenId // tokenId of the nft minted
        );
    }

    // event deployer should be able to call this method not the owner of contract
    function withdraw() public eventCreatorOnly {
        uint256 balance = address(this).balance;
        uint256 service_fee = balance / 100; // 1%

        (bool callSuccessservice, ) = i_service.call{value: service_fee}("");
        require(callSuccessservice, "callfailed");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // contract has to pay gas fees also? so we take service first then leftover is theirs
        require(callSuccess, "callfailed");
    }

    // update functions
    function updateEventDate(uint256 newDate) public eventCreatorOnly {
        require(newDate > s_purchaseEndDate, "must be after purchaseEndDate");
        s_eventDate = newDate;
    }

    function updatePurchaseStartDate(uint256 newStartDate)
        public
        eventCreatorOnly
    {
        require(
            newStartDate < s_purchaseEndDate,
            "must be before purchaseEndDate"
        );
        s_purchaseStartDate = newStartDate;
    }

    function updatePurchaseEndDate(uint256 newEndDate) public eventCreatorOnly {
        require(
            newEndDate > s_purchaseStartDate && newEndDate < s_eventDate,
            "must be between the 2 dates"
        );
        s_purchaseEndDate = newEndDate;
    }

    function updateTicketPrice(uint256 newTicketPrice) public eventCreatorOnly {
        s_ticketPrice = newTicketPrice;
    }

    function updateEventName(string memory newEventName)
        public
        eventCreatorOnly
    {
        require(bytes(newEventName).length != 0, "cannot be empty string");
        s_eventName = newEventName;
    }

    // function updateEventDetails(string memory newEventDetails) public eventCreatorOnly{
    //   require(bytes(newEventDetails).length != 0, "cannot be empty string");
    //   s_eventDetails = newEventDetails;
    // }

    function _baseURI() internal view override returns (string memory) {
        return s_baseUri;
    }

    function tokenURI(uint256 /* tokenId */)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return baseURI;
    }

    function setPause(bool val) public onlyOwner {
        s_paused = val;
    }

    // view / pure functions
    function getEventDate() public view returns (uint256) {
        return s_eventDate;
    }

    function getPurchaseStartDate() public view returns (uint256) {
        return s_purchaseStartDate;
    }

    function getPurchaseEndDate() public view returns (uint256) {
        return s_purchaseEndDate;
    }

    function getTicketPurchased() public view returns (uint256) {
        return (nextTokenIdToMint()-1);
    }

    function getTicketPrice() public view returns (uint256) {
        return s_ticketPrice;
    }

    // not sure if we need the view function for eventcreator and service
    function getEventCreator() public view returns (address) {
        return i_eventCreator;
    }

    function getService() public view returns (address) {
        return i_service;
    }

    function getServiceCharge() public view returns (uint256) {
        uint256 charge = address(this).balance / 100; // 1%
        return charge;
    }

    function getEventName() public view returns (string memory) {
        return s_eventName;
    }

    // function getEventDetails() public view returns (string memory) {
    //   return s_eventDetails;
    // }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

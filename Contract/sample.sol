// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./PriceConverter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// we can perhaps use the Roles instead so we can claim our service by ourselves
// without waiting for them to claim first then do the split
// of course this will need to do some rework.

error Event__PurchaseDatePassed();
error Event__PurchaseDateNotStarted();
error Event__NotEnoughCryptoSent();

contract Event is Ownable, ERC721 {
  using PriceConverter for uint256;

  struct Ticket {
    TicketType ticketType;
  }

  enum EventState {
    OPEN,
    ONGOING,
    END
  }

  enum TicketType {
    VIP,
    NONVIP
  }

  uint256 private s_eventDate;
  uint256 private s_purchaseStartDate;
  uint256 private s_purchaseEndDate;

  uint256 private s_ticketPurchased; // on mint, increase this number
  // uint256 private s_ticketPrice;
  uint256 private s_vipTicketPrice;
  uint256 private s_nonVipTicketPrice;
  TicketType public s_ticketType;
  EventState private s_eventState; // not sure what this is for, saw it on docs
  bool public s_paused;

  address private immutable i_eventCreator;
  address private immutable i_service; // our wallet for service charge
  string private s_eventName;
  // details can get long, I think it's better to store somewhere else or contract will be expensive
  // string private s_eventDetails;
  string private s_baseUri;
  mapping(uint256 => Ticket) public tokenIdToTicketType; // storing vip or non vip data
  AggregatorV3Interface private s_priceFeed;

  modifier paused {
    require(!s_paused, "Contract Paused: Try again later");
    _;
  }

  modifier eventCreatorOnly {
    require(msg.sender == i_eventCreator, "Function can only be called by Event Creator");
    _;
  }

  event TicketPurchase(
    address indexed winner,
    uint256 indexed tokenId,
    TicketType indexed ticketType
  ); // not sure about this, need revision

  constructor(
    uint256 eventDate,
    uint256 purchaseStartDate,
    uint256 purchaseEndDate,
    uint256 nonVipTicketPrice,
    uint256 vipTicketPrice,
    address eventCreator,
    address service,
    address priceFeedAddress,
    string memory eventName,
    // string memory eventDetails,
    string memory _baseUri
  ) ERC721(eventName, "EVENT") {
    s_eventDate = eventDate;
    s_purchaseStartDate = purchaseStartDate;
    s_purchaseEndDate = purchaseEndDate;
    s_nonVipTicketPrice = nonVipTicketPrice;
    s_vipTicketPrice = vipTicketPrice; // remember this has to be *1e18 to get the correct digit
    s_ticketPurchased = 0; // we can either use constructor to designate from event creator contract or hard code here
    s_eventState = EventState.OPEN;
    i_eventCreator = eventCreator;
    i_service = service; // we can either use constructor to designate from event creator contract or hard code here
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    s_eventName = eventName;
    // s_eventDetails = eventDetails;
    s_baseUri = _baseUri; // calculate this in frontend
  }

  function purchaseTicket() public payable paused{
    // we can return vip or non vip state
    if (msg.value.getConversionRate(s_priceFeed) < s_nonVipTicketPrice) {
      revert Event__NotEnoughCryptoSent();
    }
    // warning due to possible time manipulation of few second by miners, you guys can decide if you want to change it
    if (block.timestamp > s_purchaseEndDate) {
      revert Event__PurchaseDatePassed();
    }
    if (block.timestamp < s_purchaseStartDate) {
      revert Event__PurchaseDateNotStarted();
    }

    s_ticketType = TicketType.NONVIP;

    if (msg.value.getConversionRate(s_priceFeed) >= s_vipTicketPrice) {
      s_ticketType = TicketType.VIP;
    }
    // nft minting
    Ticket memory ticketStatus = Ticket(s_ticketType); // assigned to my struct here
    tokenIdToTicketType[s_ticketPurchased] = ticketStatus;
    _safeMint(msg.sender, s_ticketPurchased);
    s_ticketPurchased++;
    //.....

    emit TicketPurchase(
      msg.sender,
      s_ticketPurchased, // tokenId of the nft
      s_ticketType
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

  function updatePurchaseStartDate(uint256 newStartDate) public eventCreatorOnly {
    require(newStartDate < s_purchaseEndDate, "must be before purchaseEndDate");
    s_purchaseStartDate = newStartDate;
  }

  function updatePurchaseEndDate(uint256 newEndDate) public eventCreatorOnly {
    require(
      newEndDate > s_purchaseStartDate && newEndDate < s_eventDate,
      "must be between the 2 dates"
    );
    s_purchaseEndDate = newEndDate;
  }

  function updateTicketPrice(
    uint256 newNonVipTicketPrice,
    uint256 newVipTicketPrice
  ) public eventCreatorOnly {
    s_nonVipTicketPrice = newNonVipTicketPrice;
    s_vipTicketPrice = newVipTicketPrice;
  }

  function updateEventName(string memory newEventName) public eventCreatorOnly {
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

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    string memory returnUri = "";
    string memory baseURI = _baseURI();

    if (tokenIdToTicketType[tokenId].ticketType == TicketType.VIP) {
      returnUri = "0"; // baseURI/0.json for vip
    } else {
      returnUri = "1"; // baseURI/1.json for nonvip
    }
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, returnUri, ".json"))
        : "";
  }

  function setPause(bool val) public onlyOwner{
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
    return s_ticketPurchased;
  }

  function getTicketPrice() public view returns (uint256, uint256) {
    return (s_nonVipTicketPrice, s_vipTicketPrice);
  }

  function getEventState() public view returns (EventState) {
    return s_eventState;
  }

  // not sure if we need the view function for eventcreator and service
  function getEventCreator() public view returns (address) {
    return i_eventCreator;
  }

  function getService() public view returns (address) {
    return i_service;
  }

  function getServiceCharge() public view returns (uint256){
    uint256 charge = address(this).balance/100; // 1%
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

  function getTicketType(uint256 tokenId) public view returns(TicketType){
    return tokenIdToTicketType[tokenId].ticketType;
  }
}

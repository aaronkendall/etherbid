pragma solidity 0.4.24;

contract EtherBid {
  address public contractOwner; // owner of the contract
  uint256 public prize; // amount of gwei on offer to winner
  uint256 public highestBid; // highest bid in wei
  address public currentHighestBidder; // address of current highest bidder
  mapping(address => uint256) public addressToHighestBid; // track current highest bids sent by addresses
  uint256 public startTime; // start time recorded when `startAuction` function is called
  uint256 public endTime; // end time calculated by duration in days passed to `startAuction` call
  bool public isActive; // bool toggle here to make sure we don't get stuck in an endless auction ending scenario - it must run only once!

  constructor() {
    contractOwner = msg.sender;
  }

  modifier auctionIsActive() {
    require(isActive);

    if (now > endTime) {
      endAuction();
      revert();
    }
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  function getHighestBidForAddress(address queryAddress) external constant returns (uint256) {
    return addressToHighestBid[queryAddress];
  }

  function placeBid() external payable auctionIsActive() {
    address bidder = msg.sender;
    uint256 bid = msg.value;

    addressToHighestBid[bidder] = bid;

    if (bid > highestBid) {
      currentHighestBidder = bidder;
      highestBid = bid;
    }
  }

  function checkIfAuctionHasEnded() external returns (bool) {
    if (now > endTime) {
      endAuction();
      return true;
    }

    return false;
  }

  function startAuction(uint256 durationInDays) external payable onlyOwner() {
    prize = msg.value;
    startTime = now;
    endTime = startTime + (durationInDays * 24 * 60 * 60);
    isActive = true;
  }

  function endAuction() private {
    isActive = false;
    currentHighestBidder.transfer(prize);
  }
}

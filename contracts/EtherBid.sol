pragma solidity 0.4.24;

contract EtherBid {
  address public contractOwner; // owner of the contract
  uint256 public prize; // amount of wei on offer to winner
  uint256 public highestBid; // highest bid in wei
  address public currentHighestBidder; // address of current highest bidder
  mapping(address => string) public addressToHighestBidName; // track current highest bids sent by addresses
  uint256 public startTime; // start time recorded when `startAuction` function is called
  uint256 public endTime; // end time calculated by duration in days passed to `startAuction` call
  bool public isActive; // bool toggle here to make sure we don't get stuck in an endless auction ending scenario - it must run only once!
  bool public isWithdrawable; // bool to toggle whether or not owner can withdraw from contract

  constructor() {
    contractOwner = msg.sender;
  }

  modifier auctionIsActive() {
    require(isActive);
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  modifier withdrawable() {
    require(isWithdrawable);
    _;
  }

  function getAuctionInfo() external constant returns
  (uint256 _highestBid, string _highestBidder, uint256 _endTime, uint256 _prize) {
    string memory highestBidder = addressToHighestBidName[currentHighestBidder];

    return (
      highestBid,
      highestBidder,
      endTime,
      prize
    );
  }

  function isAuctionTimeUp() view returns (bool) {
    return now > endTime;
  }

  function placeBid(string bidderName) external payable auctionIsActive() {
    if (isAuctionTimeUp()) {
      endAuction();
      revert();
    }

    address bidderAddress = msg.sender;
    uint256 bid = msg.value;

    if (bid > highestBid) {
      currentHighestBidder = bidderAddress;
      highestBid = bid;
      addressToHighestBidName[bidderAddress] = bidderName;
    }
  }

  function checkIfAuctionHasEnded() external returns (bool) {
    if (isAuctionTimeUp()) {
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
    isWithdrawable = false;
    currentHighestBidder = 0x0;
    addressToHighestBidName[currentHighestBidder] = '';
  }

  function endAuction() private {
    isActive = false;
    isWithdrawable = true;
    currentHighestBidder.transfer(prize);
  }

  function withdraw(address recipient) external onlyOwner() withdrawable() {
    address etherBidContract = address(this);
    recipient.transfer(etherBidContract.balance);
  }
}

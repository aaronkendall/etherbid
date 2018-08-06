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

  function getHighestBidForAddress(address queryAddress) external constant returns (uint256) {
    return addressToHighestBid[queryAddress];
  }

  function auctionTimeUp() view returns (bool) {
    return now > endTime;
  }

  function placeBid() external payable auctionIsActive() {
    if (auctionTimeUp()) {
      endAuction();
      revert();
    }

    address bidder = msg.sender;
    uint256 bid = msg.value;

    addressToHighestBid[bidder] = bid;

    if (bid > highestBid) {
      currentHighestBidder = bidder;
      highestBid = bid;
    }
  }

  function checkIfAuctionHasEnded() external returns (bool) {
    if (auctionTimeUp()) {
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

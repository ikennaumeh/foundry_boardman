// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.21;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// At the start of a gameweek, users should be able to 
/// contribute a certain amount to the contract
/// at the end out it, only users that contribute should receive payout from
/// the smart contracts
/// users that didnt pay to the pot should be kicked out

/// in future, we would let a dao decide the amount to contribute and pay back winning
/// users

contract Boardman is ReentrancyGuard {

     ////Errors///
     error Boardman__NotOwner();
     error Boardman__HasNotStaked();
     error Boardman__NotEnoughEth();
     error Boardman__NeedsMoreThanZero();


    ////State variables///
    uint256 private constant MINIMUM_AMOUNT = 5;
    uint256 private constant FIRST_PLACE_PERCENT = 40;
    uint256 private constant SECOND_PLACE_PERCENT = 30;
    uint256 private constant THIRD_PLACE_PERCENT = 20;
    uint256 private constant TOTAL_PERCENT = 100;
    address private immutable i_owner;
    uint256 private s_totalStaked;
    mapping (address => bool) s_hasStaked;
    address[] private s_bettingPool;

    ////Events ///
    event JoinedPot(address indexed user);
    event StakedEvent(address indexed user, uint256 indexed amount);
    event Winners(address indexed first, address indexed second, address indexed third, uint256  firstPrize, uint256 secondPrize, uint256 thirdPrice);

    ////Modifiers///
    modifier onlyOwner {
        if(i_owner != msg.sender){
            revert Boardman__NotOwner();
        }
        _;
    }

    modifier staked {
        if(!s_hasStaked[msg.sender]){
            revert Boardman__HasNotStaked();
        }
        _;
    }

    modifier aboveMinimumAmount(uint _amount){
        if(_amount < MINIMUM_AMOUNT){
            revert Boardman__NotEnoughEth();
        }
        _;
    }

    constructor(){
        i_owner = msg.sender;
    }


    ////Public functions///
    function restart() public onlyOwner {
        s_bettingPool = new address[](0);
    }
    function joinPot() public {
        s_bettingPool.push(msg.sender);    
        emit JoinedPot(msg.sender);   
        
    }

    function addToPot() public payable aboveMinimumAmount(msg.value) {
        // only users in put can contribute
        s_totalStaked += msg.value;
        s_hasStaked[msg.sender] = true;
        emit StakedEvent(msg.sender, msg.value);

    }

  
    function payWinners(address _firstPlace, address _secondPlace, address _thirdPlace) public nonReentrant onlyOwner staked  {

        uint256 totalPrize = address(this).balance;

        uint256 firstPrize = (totalPrize * FIRST_PLACE_PERCENT) / TOTAL_PERCENT;
        uint256 secondPrize = (totalPrize * FIRST_PLACE_PERCENT) / TOTAL_PERCENT;
        uint256 thirdPrice = (totalPrize * FIRST_PLACE_PERCENT) / TOTAL_PERCENT;

        (bool successFirst,) = payable(_firstPlace).call{value: firstPrize}("");
        require(successFirst, "First place call failed");

        (bool successSecond,) = payable(_secondPlace).call{value: secondPrize}("");
        require(successSecond, "Second place call failed");

        (bool successThird,) = payable(_thirdPlace).call{value: thirdPrice}("");
        require(successThird, "Third place call failed");

        emit Winners(_firstPlace, _secondPlace, _thirdPlace, firstPrize, secondPrize, thirdPrice);
    }

    ////view & pure functions///
    function getOwner() external view returns (address){
        return i_owner;
    }

    function getBettingPool() external view returns (address[] memory){
        return s_bettingPool;
    }

    
   
}

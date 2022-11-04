// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConvertor.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConvertor for uint256;
    uint256 constant MINIMUM_USD = 50;
    address[] public funders;
    mapping(address => uint256) public addressToAmount;
    address public immutable i_owner;
    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        // console.log(ethUsdPriceFeedAddress);
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didn't enough money"
        ); // here 2nd arg is revert functions
        //here require acts like a checker for send money,
        // msg is a global obj
        funders.push(msg.sender);
        addressToAmount[msg.sender] = msg.value;
    }

    function withdraw() public VarifyOwner {
        for (uint256 index = 0; index < funders.length; index++) {
            addressToAmount[funders[index]] = 0;
        }

        funders = new address[](0);

        // send back the funds to addresses
        // transfer
        // call
        // send
        // only payble addresses we can send money
        // payable(msg.sender).transfer(address(this).balance);

        // using send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Faild");

        // using call

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Faild");
    }

    modifier VarifyOwner() {
        require(i_owner == msg.sender, "You don't have permissions.");
        _;
    }

    receive() external payable {
        // Special func, don't need func keyword. tiggered when someone made transaction without
        // calling fund func
        fund();
    }

    fallback() external payable {
        // Special func, don't need func keyword. tiggered when someone made invalid call data
        fund();
    }
}

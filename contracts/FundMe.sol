// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConvertor.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title crowd funding app
 * @author animesh kotka
 * @notice it is in under development, and only for demostration purpose
 * @dev this use price feed as a library
 */

contract FundMe {
    using PriceConvertor for uint256;
    uint256 constant MINIMUM_USD = 50;
    address[] private s_funders;
    mapping(address => uint256) public addressToAmount;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        // console.log(ethUsdPriceFeedAddress);
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
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

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't enough money"
        ); // here 2nd arg is revert functions
        //here require acts like a checker for send money,
        // msg is a global obj
        s_funders.push(msg.sender);
        addressToAmount[msg.sender] = msg.value;
    }

    function withdraw() public VarifyOwner {
        for (uint256 index = 0; index < s_funders.length; index++) {
            addressToAmount[s_funders[index]] = 0;
        }

        s_funders = new address[](0);

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

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

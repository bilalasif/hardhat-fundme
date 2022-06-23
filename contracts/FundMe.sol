//Get Funds from users
// Withdraw funds
// Set a minimum funding value

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    //871711
    //23515
    address public immutable i_owner;
    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didnt send enough"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onleyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);

        //actually withdraw the funds
        //transfer:
        // below address(this) refers to the address of this smartcontract FundMe and we are sending balance to who ever is calling the withdraw function
        // msg.sender will have the address of caller of withdraw function.
        // msg.sender is of type address
        // payable(msg.sender) is of type payable address
        // with transfer the gas value is capped to 2300 if more gas is used then it throws an error and transaction is reverted
        // payable(msg.sender).transfer(address(this).balance);
        // send:
        // With send the gas value is also capped but it does not throw error however it returns boolean
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failure")

        // call:
        // lower level commands
        // call returns multiple values and the empty "" means that we can call a function of the contract and if it returns value than
        // that return value gets stored in DataReturned Variable as mentioned below
        // call is recommended method
        (bool sendSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(sendSuccess, "Call Failure");
    }

    modifier onleyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // Telling here that first check the above statement and run the code after wards
    }

    //What happens when someone sends this contract ETH without calling the fund function

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}

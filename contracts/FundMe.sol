//Get Funds from users
// Withdraw funds
// Set a minimum funding value

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

/**@title A contract for crowd funding
 * @author Bilal Asif
 * @notice This contract is a demo to sample funding contract
 * @dev This implements price feeds as our library
 */

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State Variable
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    // Modefiers
    modifier onleyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // Telling here that first check the above statement and run the code after wards
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onleyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset the array
        s_funders = new address[](0);

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

    function cheaperWithdraw() public payable onleyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

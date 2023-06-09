// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint256 public ticketPrice = 1 ether; // The price of a lottery ticket

    mapping(address => uint256) public ticketBalances; // Mapping of ticket balances per player

    event TicketPurchased(address indexed player, uint256 ticketBalance, uint256 timestamp);
    event WinnerSelected(address indexed winner, uint256 ticketBalance, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function buyTicket() external payable {
        require(msg.value >= ticketPrice, "Insufficient funds to purchase a ticket");

        uint256 ticketsBought = msg.value / ticketPrice; // Calculate the number of tickets bought
        ticketBalances[msg.sender] += ticketsBought; // Increase the ticket balance of the player

        emit TicketPurchased(msg.sender, ticketBalances[msg.sender], block.timestamp);
    }

    function selectWinner() external onlyOwner {
        require(address(this).balance > 0, "Contract balance is empty");

        // You can implement the logic to select the winner here.
        // For simplicity, let's assume the owner is always the winner.
        address winnerAddress = owner;
        uint256 winningBalance = ticketBalances[winnerAddress];

        // Reset the ticket balance of the winner
        ticketBalances[winnerAddress] = 0;

        emit WinnerSelected(winnerAddress, winningBalance, block.timestamp);
    }

    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, "Contract balance is empty");

        // Transfer the contract balance to the owner
        payable(owner).transfer(address(this).balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}









// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    uint8 constant LOW = 1;
    uint8 constant RANGE = 2;
    uint8 constant HIGH = 3;

    struct Option {
        address payable creator;
        int256 strike_price;
        uint8 ticket_type;
        bool win;
    }

    address payable private owner;
    bool public function_called;
    int256 private strike_price;
    uint256 public pool;
    int256 public display_price;
    int256 public expiration_price;
    uint256 public endBet;
    uint256 public endTime;

    AggregatorV3Interface private dataFeed;
    Option[] public options;

    constructor() {
        dataFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
        endTime = block.timestamp + 10 minutes;
        endBet = block.timestamp + 5 minutes;
        function_called = false;
        pool = 0;
        owner = payable(msg.sender);
    }

    function setExpirationPrice() public {
        require(block.timestamp >= endTime, "Timestamp not reached");
        require(!function_called, "Already claimed");
        
        (, int256 answer, , ,) = dataFeed.latestRoundData();
        expiration_price = answer / 1000000;
        function_called = true;
        setBoolean();
    }
    
    function getETHUSDPriceData() public {
        (, int256 answer, , ,) = dataFeed.latestRoundData();
        strike_price = answer / 1000000;
        display_price = answer / 100000000;
    }

    function setBoolean() internal {
        for (uint256 i = 0; i < options.length; i++) {
            Option storage option = options[i];

            if (option.ticket_type == HIGH) {
                if (option.strike_price * 10501 / 10000 < expiration_price) {
                    option.win = true;
                    pool++;
                } else {
                    option.win = false;
                }
            } else if (option.ticket_type == LOW) {
                if (option.strike_price * 9499 / 10000 > expiration_price) {
                    option.win = true;
                    pool++;
                } else {
                    option.win = false;
                }
            } else if (option.ticket_type == RANGE) {
                if (option.strike_price * 95 / 100 <= expiration_price && expiration_price <= option.strike_price * 105 / 100) {
                    option.win = true;
                    pool++;
                } else {
                    option.win = false;
                }
            } else {
                option.win = false;
            }
        }
        if (pool == 0)
            owner.transfer(address(this).balance);
    }

    function betHigh() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.001 ether, "Please send exactly 0.01 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), HIGH);
    }
    
    function betRange() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.001 ether, "Please send exactly 0.01 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), RANGE);
    }

    function betLow() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.001 ether, "Please send exactly 0.01 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), LOW);
    }

    function createOption(address payable _sender, uint8 ticket_type) internal {
        Option memory newOption = Option(_sender, strike_price, ticket_type, false);
        options.push(newOption);
    }

    function sendEther() public {
        require(pool > 0, "Empty pool.");
        require(function_called == true, "Set the winner first.");
        
        uint256 transferAmount = (options.length * (uint256(1e15) - uint256(3e13))) / pool;

        for (uint256 i = 0; i < options.length; i++) {
           if (options[i].win == true)
                options[i].creator.transfer(transferAmount);
        }
        owner.transfer(address(this).balance);
    }

    function getOptionCount() public view returns (uint256) {
        return options.length;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    uint8 constant LOW = 1;
    uint8 constant RANGE = 2;
    uint8 constant HIGH = 3;
    uint256 constant ENDTIME = 10 minutes;
    uint256 constant ENDBET = 5 minutes;
    int256 constant PRICEINDOLLAR = 100000000;
    int256 constant PRICEWITHDEC = 1000000;
    uint256 constant TICKETVALUE = 1e15 wei;

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
    uint256 public totalvalue;

    AggregatorV3Interface private dataFeed;
    Option[] public options;

    constructor() {
        dataFeed = AggregatorV3Interface(0x007A22900a3B98143368Bd5906f8E17e9867581b);
        endTime = block.timestamp + ENDTIME;
        endBet = block.timestamp + ENDBET;
        function_called = false;
        pool = 0;
        totalvalue = 0;
        owner = payable(msg.sender);
    }

    function setExpirationPrice() public {
        require(block.timestamp >= endTime, "Timestamp not reached");
        require(!function_called, "Already claimed");
        
        (, int256 answer, , ,) = dataFeed.latestRoundData();
        expiration_price = answer / PRICEWITHDEC;
        function_called = true;
        setBoolean();
    }
    
    function getETHUSDPriceData() public {
        (, int256 answer, , ,) = dataFeed.latestRoundData();
        strike_price = answer / PRICEWITHDEC;
        display_price = answer / PRICEINDOLLAR;
    }

    function setBoolean() internal {
        for (uint256 i = 0; i < options.length; i++) {
            Option storage option = options[i];

            if (option.ticket_type == HIGH) {
                if (option.strike_price * 105 / 100 < expiration_price) {
                    option.win = true;
                    pool++;
                } else {
                    option.win = false;
                }
            } else if (option.ticket_type == LOW) {
                if (option.strike_price * 95 / 100 > expiration_price) {
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
        sendEther(); 
    }

    function betHigh() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == TICKETVALUE, "Please send exactly 0.001 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), HIGH);
        totalvalue = options.length * TICKETVALUE;
    }
    
    function betRange() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == TICKETVALUE, "Please send exactly 0.001 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), RANGE);
        totalvalue = options.length * TICKETVALUE;
    }

    function betLow() external payable {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == TICKETVALUE, "Please send exactly 0.001 Ether.");
        getETHUSDPriceData();
        createOption(payable(msg.sender), LOW);
        totalvalue = options.length * TICKETVALUE;
    }

    function createOption(address payable _sender, uint8 ticket_type) internal {
        Option memory newOption = Option(_sender, strike_price, ticket_type, false);
        options.push(newOption);
    }

    function sendEther() public {
        require(pool > 0, "Empty pool.");
        require(function_called == true, "Set the winner first.");
        
        uint256 transferAmount = (options.length * (TICKETVALUE - uint256(3e13))) / pool;

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

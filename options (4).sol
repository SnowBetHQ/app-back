// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    AggregatorV3Interface internal dataFeed;

    // structure option 

    struct Option 
    {
        address creator;
        int strike_price;
        uint8 ticket_type;
        bool win;
    }


    // struct OptionResult 
    // {
    //     bool win;
    //     address creator;
    // }

    // ticket type

    uint8 constant LOW = 1;
    uint8 constant RANGE = 2;
    uint8 constant HIGH = 3;

    // timestamp
    uint public endTime;
    uint public endBet;
    int internal expiration_price;    
    int internal strike_price;   
    int public display_price; 
    bool internal function_called;
    int internal  pool;

    Option[] public options;

    constructor() 
    {
        dataFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
        endTime = block.timestamp + 60 seconds;
        endBet = block.timestamp + 60 seconds;
        pool = 0;
    }

    function set_expiration_price() internal
    {
        require(block.timestamp >= endTime, "Timestamp not reached");
        require(!function_called, "Already claim");
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        expiration_price = answer / 1000000;
        function_called = true;
        set_boolean();
    }
    
    function get_ETH_USD_PriceData() public returns (int)
    {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        strike_price = answer / 1000000;
        display_price = answer / 100000000;
        return display_price;
    }

    function set_boolean() public  
    {
    //OptionResult[] memory results = new OptionResult[](options.length);
    for (uint256 i = 0; i < options.length; i++) {
        Option memory option = options[i];

       // OptionResult memory result;
        //result.creator = option.creator;

        if (option.ticket_type == HIGH) {
            // Check condition for ticket type HIGH
            if (option.strike_price * 10501 / 10000 < expiration_price) {
                option.win = true;
                pool++;
            } else {
                option.win = false;
            }
        } else if (option.ticket_type == LOW) {
            // Check condition for ticket type LOW
            if (option.strike_price * 9499 / 10000 > expiration_price) {
                option.win = true;
                pool++;
            } else {
                option.win = false;
            }
        } else if (option.ticket_type == RANGE) {
            // Check condition for ticket type RANGE
            if (option.strike_price * 95 / 100 <= expiration_price 
                && expiration_price <= option.strike_price * 105 / 100) 
            {
                option.win = true;
                pool++;
            } 
            else 
            {
                option.win = false;
            }
        } else {
            // Invalid ticket type
            option.win = false;
        }

    }
   // return results;
}

// pour payer (options.lenght - 1 * 0.01) / pool 

    // Betting data

    event TicketPurchased(address buyer, uint256 amount);

    function Bet_High() external payable 
    {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.01 ether, "Please send exactly 0.01 Ether.");
        get_ETH_USD_PriceData();

        createOption(msg.sender, HIGH);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function Bet_Range() external payable 
    {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.01 ether, "Please send exactly 0.01 Ether.");
       get_ETH_USD_PriceData();

        createOption(msg.sender, RANGE);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function Bet_Low() external payable 
    {
        require(block.timestamp <= endBet, "Bet closed");
        require(msg.value == 0.01 ether, "Please send exactly 0.01 Ether.");
        get_ETH_USD_PriceData();

        createOption(msg.sender, LOW);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function createOption(address _sender, uint8 ticket_type) internal 
    {
        Option memory newOption = Option(_sender, strike_price, ticket_type, false);
        options.push(newOption);
    }


    function getOptionCount() external view returns (uint256) {
        return options.length;
    }

//     function getOptionResult(uint256 index) public view returns (bool, address) {
//     require(index < options.length, "Invalid index");

//     OptionResult memory result = results[index];
//     return (result.win, result.creator);
// }

}

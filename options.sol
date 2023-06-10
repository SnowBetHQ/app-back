// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    AggregatorV3Interface internal dataFeed;

    constructor() {
        dataFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
    }

    uint8 constant  LOW = 1;  
    uint8 constant  RANGE = 2;  
    uint8 constant  HIGH = 3;

    function get_ETH_USD_PriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer / 100000000;
    }

    struct Option {
        address creator;     // Address of the option creator
        uint256 strikePrice; // Strike price of the option
        uint256 expiration;
        uint8   ticket_type; // 1 = bet_low 2 = range 3 = bet high;
    }
    Option[] public options;

    event OptionCreated(
        uint256 indexed optionId,
        address indexed creator,
        uint256 strikePrice,
        uint8   indexed ticket_type
    );

    function Bet_High() external payable {
    uint256 latestPrice = uint256(get_ETH_USD_PriceData());
    
    createOption(latestPrice, msg.sender, HIGH);
    }

    function Bet_Range() external payable {
    uint256 latestPrice = uint256(get_ETH_USD_PriceData());
    
    createOption(latestPrice, msg.sender, RANGE);
    }

    function Bet_Low() external payable {
    uint256 latestPrice = uint256(get_ETH_USD_PriceData());
    
    createOption(latestPrice, msg.sender, LOW);
    }

    function createOption(
        uint256 _strikePrice, address _sender, uint8 ticket_type
    ) internal {
        uint256 expiration = block.timestamp + 30 days;

        Option memory newOption = Option(
            _sender,
            _strikePrice,
            expiration,
            ticket_type
        );
        uint256 optionId = options.length;
        options.push(newOption);

        emit OptionCreated(optionId, _sender, _strikePrice, ticket_type);
    }
    function getOptionCount() external view returns (uint256) {
    return options.length;}
}
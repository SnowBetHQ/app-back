// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    AggregatorV3Interface internal dataFeed;

    constructor() {
        dataFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
    }

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
    }
    Option[] public options;

    event OptionCreated(
        uint256 indexed optionId,
        address indexed creator,
        uint256 strikePrice
    );

    function Bet_High() external payable {
    uint256 latestPrice = uint256(get_ETH_USD_PriceData());
    
    createOption(latestPrice, msg.sender);
    }

    function createOption(
        uint256 _strikePrice, address _sender
    ) internal {
        uint256 expiration = block.timestamp + 30 days;

        Option memory newOption = Option(
            _sender,
            _strikePrice,
            expiration
        );
        uint256 optionId = options.length;
        options.push(newOption);

        emit OptionCreated(optionId, _sender, _strikePrice);
    }
    function getOptionCount() external view returns (uint256) {
    return options.length;}
}
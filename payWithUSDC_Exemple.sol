// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptionContract {
    struct Option {
        address creator;     // Address of the option creator
        uint256 strikePrice; // Strike price of the option
        uint256 expiration;  // Expiration timestamp of the option
        bool isCallOption;   // Flag indicating whether it is a call option or put option
    }

    Option[] public options;

    event OptionCreated(
        uint256 indexed optionId,
        address indexed creator,
        uint256 strikePrice,
        uint256 expiration,
        bool isCallOption
    );

    function createOption(
        uint256 _strikePrice,
        uint256 _expiration,
        bool _isCallOption
    ) external {
        Option memory newOption = Option(
            msg.sender,
            _strikePrice,
            _expiration,
            _isCallOption
        );

        uint256 optionId = options.length;
        options.push(newOption);

        emit OptionCreated(optionId, msg.sender, _strikePrice, _expiration, _isCallOption);
    }

    function getOption(uint256 _optionId) external view returns (
        address creator,
        uint256 strikePrice,
        uint256 expiration,
        bool isCallOption
    ) {
        require(_optionId < options.length, "Invalid option ID");

        Option storage option = options[_optionId];
        return (
            option.creator,
            option.strikePrice,
            option.expiration,
            option.isCallOption
        );
    }

    function getOptionCount() external view returns (uint256) {
        return options.length;
    }
}

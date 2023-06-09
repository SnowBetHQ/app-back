/*                                                                     
 ,---.                            ,-----.           ,--.    ,--.        
'   .-' ,--,--,  ,---. ,--.   ,--.|  |) /_  ,---. ,-'  '-.  `--' ,---.  
`.  `-. |      \| .-. ||  |.'.|  ||  .-.  \| .-. :'-.  .-'  ,--.| .-. | 
.-'    ||  ||  |' '-' '|   .'.   ||  '--' /\   --.  |  |.--.|  |' '-' ' 
`-----' `--''--' `---' '--'   '--'`------'  `----'  `--''--'`--' `---'  
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Mumbai TestNet
     */

    /** POUR ETH/USD sur Polygon -> 0x0715A7794a1dc8e42615F059dD6e406A6594651A (https://data.chain.link/polygon/mainnet/crypto-usd/eth-usd) */
    /** POUR BTC/USD sur Polygon -> 0x007A22900a3B98143368Bd5906f8E17e9867581b*/
    /** POUR MATIC/USD sur Polygon -> 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada*/
    /** POUR UNI/USD sur Polygon -> */
    /** POUR LINK/USD sur Polygon -> 0x1C2252aeeD50e0c9B64bDfF2735Ee3C932F5C408*/

    // constructor() {
    //     dataFeed = AggregatorV3Interface(
    //         0x0715A7794a1dc8e42615F059dD6e406A6594651A
    //     );
    // }

    function get_ETH_USD_PriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A).latestRoundData();
        return answer / 100000000;
    }
    
    function get_BTC_USD_PriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(0x007A22900a3B98143368Bd5906f8E17e9867581b).latestRoundData();
        return answer / 100000000;
    }
    function get_MATIC_USD_PriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada).latestRoundData();
        return answer / 100000000;
    }
    function get_LINK_USD_PriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada).latestRoundData();
        return answer / 100000000;
    }
  
}
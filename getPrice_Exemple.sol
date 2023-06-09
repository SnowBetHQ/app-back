/*                                                                     
 ,---.                            ,-----.           ,--.    ,--.        
'   .-' ,--,--,  ,---. ,--.   ,--.|  |) /_  ,---. ,-'  '-.  `--' ,---.  
`.  `-. |      \| .-. ||  |.'.|  ||  .-.  \| .-. :'-.  .-'  ,--.| .-. | 
.-'    ||  ||  |' '-' '|   .'.   ||  '--' /\   --.  |  |.--.|  |' '-' ' 
`-----' `--''--' `---' '--'   '--'`------'  `----'  `--''--'`--' `---'  
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SnowBet {
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */

    /** POUR ETH/USD sur Polygon -> 0xf9680d99d6c9589e2a93a78a04a279e509205945 (https://data.chain.link/polygon/mainnet/crypto-usd/eth-usd) */
    /** POUR BTC/USD sur Polygon -> */
    /** POUR MATIC/USD sur Polygon -> */
    /** POUR UNI/USD sur Polygon -> */
    /** POUR LINK/USD sur Polygon -> */

    constructor() {
        dataFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
    }

    function getPriceData() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer / 100000000;
    }
}

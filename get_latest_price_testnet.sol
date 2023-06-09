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

    // Network: Polygon Mainnet (https://data.chain.link/polygon/mainnet/crypto-usd/eth-usd)

    /** POUR ETH/USD sur Polygon -> 0xF9680D99D6C9589e2a93a78A04A279e509205945 */
    /** POUR BTC/USD sur Polygon -> 0xc907E116054Ad103354f2D350FD2514433D57F6f */
    /** POUR MATIC/USD sur Polygon -> 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0 */
    /** POUR UNI/USD sur Polygon -> 0xdf0Fb4e4F928d2dCB76f438575fDD8682386e13C */
    /** POUR LINK/USD sur Polygon -> 0xd9FFdb71EbE7496cC440152d43986Aae0AB76665 */


    function get_ETH_USD_PriceData() public view returns (int) {
        (,int answer,,,) = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A).latestRoundData();
        return answer / 100000000;
    }
    
    function get_BTC_USD_PriceData() public view returns (int) {
        (,int answer,,,) = AggregatorV3Interface(0x007A22900a3B98143368Bd5906f8E17e9867581b).latestRoundData();
        return answer / 100000000;
    }
    function get_MATIC_USD_PriceData() public view returns (int) {
        (,int answer,,,) = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada).latestRoundData();
        return answer / 100000000;
    }
}

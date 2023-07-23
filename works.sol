// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./lastvault.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


contract C10Token is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("C10index", "C10") {}

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function burnTokens(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

contract C10ETF is C10Token, C10Vault {
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);
    using SafeMath for uint256;

    address public constant USDC = 0x65aFADD39029741B3b8f0756952C74678c9cEC93;
    address public constant LINK = 0xe9c4393a23246293a8D31BF7ab68c17d4CF90A29;
    IERC20 public usdcToken = IERC20(USDC);
    IERC20 public linkToken = IERC20(LINK);
    address[2] public tokenAddresses;
    uint256[1] public Proportion;
    uint256 public i = 0;
    uint256 public j = 0;
    uint24 public constant poolFee = 3000;
    C10Vault public vault;//CONTRACT DU VAULT
    

    address public usdcContract = 0x65aFADD39029741B3b8f0756952C74678c9cEC93;
    function approveLinkFaster(address spender,uint amount) external {
        IERC20 link = IERC20(usdcContract);
        link.approve(spender, amount);
    }

    //Chainlink data's array
    AggregatorV3Interface[] internal priceFeeds;
    //Assets structure array
    Asset[2] public assets;
    event transaction_success(uint256 value);

    function setVaultAddress(address _vault) public onlyOwner {
        vault = C10Vault(_vault);
    }

    function changeVaultOwner(address _vaultOwner) public onlyOwner {
        vault.setC10ContractAsOwner(_vaultOwner);
    }

    function get_supply() public view returns (uint256) {
    return totalSupply();
    }

    function mint_single(uint amount) public {
         mint(amount);
    }

    struct Asset 
    {
        uint256 price;
    }

    constructor() {
    Proportion[0] = 100;
    //Proportion[1] = 25;
    priceFeeds = new AggregatorV3Interface[](2);
    priceFeeds[0] = AggregatorV3Interface(0x48731cF7e84dc94C5f84577882c14Be11a5B7456); //LINK/USD price feed
    priceFeeds[1] = AggregatorV3Interface(0x48731cF7e84dc94C5f84577882c14Be11a5B7456); //DAI/USD
    tokenAddresses[0] = 0xe9c4393a23246293a8D31BF7ab68c17d4CF90A29;//link
    tokenAddresses[1] = 0xe9c4393a23246293a8D31BF7ab68c17d4CF90A29;
}
    
    //0x2E8D98fd126a32362F2Bd8aA427E59a1ec63F780 USDT GOERLI AAVE
    mapping (address => uint256) public tokenBalances;

    uint256 public Pool_Value;

    function buy_swap(uint256 amountIn) public returns (uint256 amountOut)
    {
        usdcToken.approve(address(swapRouter), amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: USDC,
                tokenOut: tokenAddresses[i],
                fee: poolFee,
                recipient: address(vault),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        amountOut = swapRouter.exactInputSingle(params);     
    }

    function sell_swap(address recipient, uint256 amountIn) public returns (uint256 amountOut) {

    linkToken.approve(address(swapRouter), amountIn);
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        .ExactInputSingleParams({
            tokenIn: tokenAddresses[i],
            tokenOut: USDC,
            fee: poolFee,
            recipient: recipient,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
    amountOut = swapRouter.exactInputSingle(params);
    }

    function updateAssetValues() public 
    {
        for (i = 0; i < 1; i++) 
        {
            (, int256 price, , , ) = priceFeeds[i].latestRoundData();
            assets[i].price = uint256(price);
        }
    }

    function _updateTokenBalanceWORK() public{

        for (i = 0; i < 1; i++){
            uint256 nextBalance = IERC20(tokenAddresses[i]).balanceOf(address(vault));//with 18 decimals
            tokenBalances[tokenAddresses[i]] = nextBalance;
        }
    }

    uint256 public tokenBalance;
    uint256 public tokenPrice;




function _updatePoolValueWORK() public returns (uint256) {
    Pool_Value = 0; 

    _updateTokenBalanceWORK(); 
    updateAssetValues();
    for (i = 0; i < 1; i++) {
        tokenBalance = (tokenBalances[tokenAddresses[i]]);//with 18 decimals
        tokenPrice = (assets[i].price / 1e8);
        Pool_Value = Pool_Value.add(tokenBalance.mul(tokenPrice));

        // Add logging for debugging
        //emit DebugUpdatePoolValue(i, tokenAddresses[i], tokenBalance, tokenPrice, Pool_Value);
    }

    return Pool_Value;
}

    uint256 public AUM_In_Usd;
    uint256 public C10_Supply;
    uint256 public C10_Price;

    function get_c10()public view returns(uint256){
        return AUM_In_Usd/ totalSupply();
    }

    function get_TVL()public view returns(uint256){
        return AUM_In_Usd;
    }

    

    function buyETF2(uint256 usdcAmount) public  {    
        IERC20 token = IERC20(USDC);
        
    
        require(token.allowance(msg.sender, address(this)) >= usdcAmount, "Error");
        require(token.transferFrom(msg.sender, address(this), usdcAmount), "Error.");
        AUM_In_Usd = _updatePoolValueWORK();
        C10_Supply = get_supply();
        C10_Supply = C10_Supply / 1e2;
        if (AUM_In_Usd == 0 && C10_Supply == 0){
             C10_Supply = 1e18;
             AUM_In_Usd = 1e21;
        }
        C10_Price = AUM_In_Usd / C10_Supply;//821 car ca devient un e16
        for (i = 0; i < 1; i++){
            buy_swap(Proportion[i]*usdcAmount /100);
        }
        AUM_In_Usd = _updatePoolValueWORK();
        usdcAmount = usdcAmount * 1e14;
        mint(usdcAmount / C10_Price);
    }

    function sellETF3(uint256 amount) public {

        
        address recipient = msg.sender;
        AUM_In_Usd = _updatePoolValueWORK();//with 18 decimals
        C10_Supply = get_supply();//with 18 decimals
        C10_Supply = C10_Supply / 1e2;
        C10_Price = AUM_In_Usd / C10_Supply;//821 car ca devient un e16
        for (i = 0; i < 1; i++) {
            uint256 amountToWithdraw = (amount * Proportion[i] / 100) / assets[i].price / 1e9;
            vault.withdraw(tokenAddresses[i], amountToWithdraw);
        }
        i = 0;//car le swap
        for (j = 0; j < 1; j++) {
            uint256 amountToSwap = (amount * Proportion[j] / 100) / assets[j].price / 1e9;
            sell_swap(recipient,amountToSwap);
        }
        amount =  amount / 1e15;
        AUM_In_Usd = _updatePoolValueWORK();
        burn(amount/C10_Price);
         //emit transaction_success(amount);
    }
    
}
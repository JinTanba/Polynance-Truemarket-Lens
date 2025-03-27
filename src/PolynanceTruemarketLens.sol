// SPDX-License-Identifier: UNLICENSED
import "./interfaces/ITruthMarketManager.sol";
import "./interfaces/ITruthMarket.sol";
import "./interfaces/IUniswapV3Pool.sol";

pragma solidity ^0.8.13;
//Polynance -----> https://polynance.ag
contract PolynanceTruemarketLens {
    
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    ITruthMarketManager immutable truemarketManager;
    
    struct MarketDetail {
        address id;
        string question;
        string source;
        string additionalInfo;
        uint8 status;
        uint256 createdAt;
        uint256 endOfTrading;
        uint256 winningPosition;
        address yesToken;
        address noToken;
        bool bondSettled;
        address yesPool;
        address noPool;
        uint256 yesPrice;
        uint256 noPrice;
    }


    constructor() {
        truemarketManager = ITruthMarketManager(0x61A98Bef11867c69489B91f340fE545eEfc695d7);
    }

    function getAllActiveMarketsAddress() public view returns (address[] memory) {
        uint256 count = truemarketManager.numberOfActiveMarkets();

        address[] memory markets = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            markets[i] = truemarketManager.getActiveMarketAddress(i);
        }
        return markets;
    }
    
    function getMarketdetail(address marketAddress) public view returns (MarketDetail memory) {
        ITruthMarket market = ITruthMarket(marketAddress);
        MarketDetail memory detail;
        detail.id = marketAddress;
        detail.question = market.marketQuestion();
        detail.source = market.marketSource();
        detail.additionalInfo = market.additionalInfo();
        detail.status = uint8(market.getCurrentStatus());
        detail.createdAt = market.createdAt();
        detail.endOfTrading = market.endOfTrading();
        detail.winningPosition = market.winningPosition();
        detail.yesToken = address(market.yesToken());
        detail.noToken = address(market.noToken());
        detail.bondSettled = market.bondSettled();
        (address yesPoolAddr, address noPoolAddr) = market.getPoolAddresses();
        detail.yesPool = yesPoolAddr;
        detail.noPool = noPoolAddr;
        detail.yesPrice = getTokenPrice(yesPoolAddr);
        detail.noPrice = getTokenPrice(noPoolAddr);
        return detail;
    }
    

    function getAllActiveMarketDetails(uint256 page, uint256 limit) external view returns (MarketDetail[] memory) {
        address[] memory activeMarketAddress = getAllActiveMarketsAddress();
        uint totalCount = activeMarketAddress.length;
        
        uint256 startIndex = page * limit;
        
        if (startIndex >= totalCount) {
            return new MarketDetail[](0);
        }
        
        uint256 endIndex = (startIndex + limit > totalCount) ? totalCount : startIndex + limit;

        uint256 resultSize = endIndex - startIndex;
        MarketDetail[] memory detailArray = new MarketDetail[](resultSize);

        for (uint256 i = 0; i < resultSize; i++) {
            detailArray[i] = getMarketdetail(activeMarketAddress[startIndex + i]);
        }
        
        return detailArray;
    }

    function getTokenPrice(address positionPool) public view returns (uint256 price) {
        if (positionPool != address(0)) {
            IUniswapV3Pool pool = IUniswapV3Pool(positionPool);
            (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
            
            uint256 Q96 = 2**96;
            address token0 = pool.token0();
            
            if (token0 == USDC) {
                if (sqrtPriceX96 > 0) {
                    uint256 priceX96Squared = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
                    price = (Q96 * Q96 * 1e18) / priceX96Squared;
                } else {
                    price = 0;
                }
            } else {
                uint256 priceX96Squared = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
                price = (priceX96Squared * 1e18) / (Q96 * Q96);
            }
        }
        
        return price;
    }
}
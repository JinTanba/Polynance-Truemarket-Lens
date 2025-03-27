// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PolynanceTruemarketLens} from "../src/PolynanceTruemarketLens.sol";

// fork env is localhost:9999
contract PolynanceTruemarketLensTest is Test {
    PolynanceTruemarketLens public viewer;
    
    function setUp() public {        
        // Deploy the viewer contract which will interact with actual contracts on the fork
        console.log("init");
        viewer = new PolynanceTruemarketLens();
    }
    
    function testgetAllActiveMarketDetails() public view {
        // Call the method that fetches market details from the forked chain
        PolynanceTruemarketLens.MarketDetail[] memory marketDetails = viewer.getAllActiveMarketDetails(1,50);
        
        // Check that we got some data back
        console.log("Number of markets fetched:", marketDetails.length);
        
        // If there are any markets, log some information about the first one
        if (marketDetails.length > 0) {
            console.log("First market question:", marketDetails[0].question);
            console.log("First market status:", marketDetails[0].status);
            
            // Additional assertions based on expected data from the fork
            // These would be specific to your fork's state
            assertTrue(bytes(marketDetails[0].question).length > 0, "Market question should not be empty");
            assertTrue(marketDetails[0].createdAt > 0, "Market creation timestamp should be greater than 0");
        }
    }
    
    function testGetAllActiveMarketsAddress() public view {
        // Get all active market addresses
        address[] memory markets = viewer.getAllActiveMarketsAddress();
        
        // Log the number of active markets
        console.log("Number of active markets:", markets.length);
        
        // If there are any markets, log some information about the first one
        if (markets.length > 0) {
            console.log("First market address:", markets[0]);
            
            // Additional assertions
            assertTrue(markets[0] != address(0), "Market address should not be zero");
        }
    }
    
    function testGetMarketDetails() public view {
        // Get all active market addresses first
        address[] memory markets = viewer.getAllActiveMarketsAddress();
        
        // Skip if no markets are available
        if (markets.length == 0) {
            console.log("No markets available to test");
            return;
        }
        
        // Get details for the first market
        PolynanceTruemarketLens.MarketDetail memory details = viewer.getMarketdetail(markets[0]);
        
        // Log the details
        console.log("Market question:", details.question);
        console.log("Market source:", details.source);
        console.log("Market status:", details.status);
        console.log("Market creation time:", details.createdAt);
        console.log("Market end of trading:", details.endOfTrading);
        
        // Some assertions on the data
        assertTrue(bytes(details.question).length > 0, "Market question should not be empty");
        assertTrue(details.createdAt > 0, "Created timestamp should be greater than 0");
    }
}
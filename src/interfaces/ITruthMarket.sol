// SPDX-License-Identifier: MIT
import "./IERC20.sol";
pragma solidity ^0.8.0;

enum MarketStatus {
    Created,                // 0
    OpenForResolution,      // 1
    ResolutionProposed,     // 2
    DisputeRaised,          // 3
    SetByCouncil,           // 4
    ResetByCouncil,         // 5
    EscalatedDisputeRaised, // 6
    Finalized               // 7
}

interface ITruthMarket {

    /* ========== VIEWS / VARIABLES ========== */
    function VERSION() external pure returns (string memory);
    
    function winningPosition() external view returns (uint256);
    
    function endOfTrading() external view returns (uint256);
    
    function createdAt() external view returns (uint256);
    function resolutionProposedAt() external view returns (uint256);
    function disputedAt() external view returns (uint256);
    function councilDecisionAt() external view returns (uint256);
    function escalatedDisputeAt() external view returns (uint256);
    function finalizedAt() external view returns (uint256);
    
    function firstChallengePeriod() external view returns (uint256);
    function secondChallengePeriod() external view returns (uint256);
    
    function yesNoTokenCap() external view returns (uint256);
    
    function resolverBondAmount() external view returns (uint256);
    function disputerBondAmount() external view returns (uint256);
    function escalatorBondAmount() external view returns (uint256);

    
    function marketQuestion() external view returns (string memory);
    function marketSource() external view returns (string memory);
    function additionalInfo() external view returns (string memory);
    
    function yesToken() external view returns (address);
    function noToken() external view returns (address);

    function rewardAmount() external view returns (uint256);
    function rewardToken() external view returns(address);
    function POOL_FEE() external view returns (uint24);
    
    function yesPool() external view returns (address);
    function noPool() external view returns (address);
    
    
    function currentStatus() external view returns (MarketStatus);
    
    function bondSettled() external view returns (bool);
    
    function positionCount() external pure returns (uint256);
    
    function getUserClaimableAmount(address _account) external view returns (uint256);
    
    function getAllAmounts() external view returns (uint256, uint256, uint256);
    
    function getCurrentStatus() external view returns (MarketStatus);
    
    function getUserPosition(address user) external view returns (uint256 yesAmount, uint256 noAmount);
    
    function getPoolAddresses() external view returns (address, address);
    
    function paused() external view returns (bool);
    
    /* ========== MUTATIVE FUNCTIONS ========== */
    function proposeResolution(uint256 _outcome) external;
    
    function raiseDispute() external;
    
    function resolveMarketByCouncil(uint256 _outcome) external;
    
    function resetMarketByCouncil(bool _returnToOpenForResolution) external;
    
    function raiseEscalatedDispute() external;
    
    function resolveMarketByEscalation(uint256 _outcome) external;
    
    function resetMarketByEscalation() external;
    
    function setYesNoTokenCap(uint256 _yesNoTokenCap) external;
    
    function setEndOfTrading(uint256 _endOfTrading) external;
    
    function setFirstChallengePeriod(uint256 _firstChallengePeriod) external;
    
    function setSecondChallengePeriod(uint256 _secondChallengePeriod) external;
    
    function mint(uint256 paymentTokenAmount) external;
    
    function burn(uint256 amount) external;
    
    function redeem(uint256 amount) external;
    
    function withdrawFromCanceledMarket() external;
    
    function settleBonds() external;
}
## Polynance Truemarket Helper

**Polynance Truemarket Helper** is a Solidity-based utility for interacting with the Polynance prediction markets platform. This repository contains a lens contract that provides easy access to Truemarket data on the Base blockchain.

Polynance (https://polynance.ag) is a prediction markets aggregator that allows users to access and interact with various prediction market platforms, including Truemarket where users can create markets around yes/no questions and trade tokens representing different outcomes.

### Deployment

The contract is deployed on Base blockchain at:
https://basescan.org/address/0x4cb8dd3e342c05c9d9760f0efeff78ac87cf1cdf

### Key Features

- **Market Data Retrieval**: Fetch comprehensive details about active prediction markets including questions, sources, status, trading end times, and token information
- **Price Information**: Get real-time pricing for YES/NO position tokens via Uniswap V3 pools
- **Pagination Support**: Retrieve market data in paginated format for efficient frontend integration

### Components

- **PolynanceTruemarketLens**: Main contract that interfaces with the Truemarket system
- **Interfaces**: Definitions for interacting with Truemarket contracts and Uniswap V3 pools

### Development

This project is built using Foundry, a modern Ethereum development toolkit.

#### Build

```shell
$ forge build
```

#### Test

```shell
$ forge test
```

#### Deploy

```shell
$ forge script script/deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Documentation

For more information about Foundry:
https://book.getfoundry.sh/

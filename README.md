## Chainlink Fundamentals - Contracts

Solidity Smart Contracts for the Chainlink Fundamentals course on Cyfrin Updraft.

## Setup

### Clone

```shell
$ git clone https://github.com/gabehellz/chainlink-fundamentals-contracts
$ cd chainlink-fundamentals-contracts
```

### Install Libraries

```shell
$ forge install https://github.com/smartcontractkit/chainlink-evm@branch=contracts-solidity/1.5.0 
$ forge install openzeppelin-contracts-5.5.0=https://github.com/OpenZeppelin/openzeppelin-contracts@v5.5.0
```

## Tests

### Data Feeds

```shell
$ forge test --match-path 'test/data-feeds/*'
```

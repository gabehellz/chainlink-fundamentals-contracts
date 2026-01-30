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
$ forge install openzeppelin-contrcts-4.9.6=https://github.com/OpenZeppelin/openzeppelin-contracts@v4.9.6
$ forge install https://github.com/smartcontractkit/chainlink-ccip
$ forge install https://github.com/smartcontractkit/chainlink-local
```

## Tests

### Data Feeds

```shell
$ forge test --match-path 'test/data-feeds/*'
```

### CCIP

``` shell
$ forge test --match-path 'test/ccip/*'
```

### VRF

``` shell
$ forge test --match-path 'test/vrf/*'
```

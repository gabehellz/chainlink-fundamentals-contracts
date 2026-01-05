// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts@5.5.0/access/Ownable.sol";
import {MyERC20} from "./MyERC20.sol";

contract TokenShop is Ownable {
    AggregatorV3Interface internal immutable _PRICE_FEED;
    MyERC20 public immutable UNDERLYING;

    uint256 public constant TOKEN_DECIMALS = 18;
    uint256 public constant TOKEN_USD_PRICE = 2 * 10 ** TOKEN_DECIMALS; // 2 USD with 18 decimals

    event BalanceWithdrawn();

    error ZeroETHSent();
    error CouldNotWithdraw();

    constructor(address tokenAddress_, address aggregatorAddress_) Ownable(msg.sender) {
        UNDERLYING = MyERC20(tokenAddress_);
        _PRICE_FEED = AggregatorV3Interface(aggregatorAddress_);
    }

    receive() external payable {
        if (msg.value == 0) revert ZeroETHSent();
        UNDERLYING.mint(msg.sender, amountToMint(msg.value));
    }

    function amountToMint(uint256 amountInEth) public view returns (uint256) {
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer()) * 10 ** (TOKEN_DECIMALS - _PRICE_FEED.decimals());
        uint256 ethAmountInUsd = amountInEth * ethUsd / 10 ** TOKEN_DECIMALS;
        return (ethAmountInUsd * 10 ** TOKEN_DECIMALS) / TOKEN_USD_PRICE;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        (
            /* uint80 roundId */,
            int256 price,
            /* uint256 startedAt */,
            /* uint256 timestamp */,
            /* uint80 answeredInRound */
        ) = _PRICE_FEED.latestRoundData();

        return price;
    }

    function withdraw() external onlyOwner {
        (bool success,) = payable(owner()).call{value: address(this).balance}("");
        if (!success) revert CouldNotWithdraw();
        emit BalanceWithdrawn();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/shared/mocks/MockV3Aggregator.sol";
import {TokenShop} from "../../src/data-feeds/TokenShop.sol";
import {MyERC20} from "../../src/data-feeds/MyERC20.sol";

contract TokenShopTest is Test {
    int256 public constant INITIAL_ANSWER = 315982115200;

    MockV3Aggregator public aggregator;
    MyERC20 public token;
    TokenShop public tokenShop;

    address public userAddress = makeAddr("USER");

    function setUp() public {
        // Initialize Contracts
        aggregator = new MockV3Aggregator(uint8(8), INITIAL_ANSWER);
        token = new MyERC20();
        tokenShop = new TokenShop(address(token), address(aggregator));

        // Setup Contracts
        token.grantRole(token.MINTER_ROLE(), address(tokenShop));
    }

    function test_checkMinterRole() public view {
        assert(token.hasRole(token.MINTER_ROLE(), address(tokenShop)));
    }

    function test_checkInitialAnswer() public view {
        int256 price = tokenShop.getChainlinkDataFeedLatestAnswer();
        assertEq(price, INITIAL_ANSWER);
    }

    function test_buyUsd() public {
        uint256 balanceBefore = token.balanceOf(userAddress);
        vm.deal(userAddress, 1 ether);

        vm.startPrank(userAddress);
        (bool success,) = payable(address(tokenShop)).call{value: 0.01 ether}("");
        assert(success);
        vm.stopPrank();

        uint256 balanceAfter = token.balanceOf(userAddress);
        assertGt(balanceAfter, balanceBefore);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {CCIPLocalSimulator} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {LinkToken} from "@chainlink/local/src/shared/LinkToken.sol";
import {MessageSender} from "../../src/ccip/MessageSender.sol";
import {MessageReceiver} from "../../src/ccip/MessageReceiver.sol";

contract CCIPLocalSimulatorTest is Test {
    CCIPLocalSimulator public localSimulator;
    LinkToken public linkToken;
    MessageSender public messageSender;
    MessageReceiver public messageReceiver;

    uint64 public chainSelector;
    IRouterClient public sourceRouter;
    IRouterClient public destinationRouter;

    function setUp() public {
        localSimulator = new CCIPLocalSimulator();

        (chainSelector, sourceRouter, destinationRouter,, linkToken,,) = localSimulator.configuration();

        messageSender = new MessageSender(address(sourceRouter), address(linkToken));
        messageReceiver = new MessageReceiver(address(destinationRouter));
    }

    function test_sendMessage() public {
        string memory message = "Hey there!";

        vm.expectEmit(false, true, false, true, address(messageSender));

        emit MessageSender.MessageSent(
            bytes32(0), chainSelector, address(messageReceiver), message, address(linkToken), 0
        );

        bytes32 messageId = messageSender.sendMessage(chainSelector, address(messageReceiver), message);

        (bytes32 receivedMessageId, string memory receivedMessage) = messageReceiver.getLastReceivedMessageDetails();
        assertEq(receivedMessageId, messageId);
        assertEq(abi.encode(receivedMessage), abi.encode(message));
    }
}

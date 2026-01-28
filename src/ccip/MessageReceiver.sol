// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";

contract MessageReceiver is CCIPReceiver {
    event MessageReceived(bytes32 indexed messageId, uint64 indexed sourceChainSelector, address sender, string text);

    bytes32 private _lastReceivedMessageId;
    string private _lastReceivedText;

    constructor(address router_) CCIPReceiver(router_) {}

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        _lastReceivedMessageId = any2EvmMessage.messageId;
        _lastReceivedText = abi.decode(any2EvmMessage.data, (string));

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            abi.decode(any2EvmMessage.data, (string))
        );
    }

    function getLastReceivedMessageDetails() external view returns (bytes32 messageId, string memory text) {
        return (_lastReceivedMessageId, _lastReceivedText);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MessageSender is Ownable {
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string text,
        address feeToken,
        uint256 fees
    );

    IRouterClient private _router;
    IERC20 private _linkToken;

    constructor(address router_, address link_) Ownable(msg.sender) {
        _router = IRouterClient(router_);
        _linkToken = IERC20(link_);
    }

    function sendMessage(uint64 destinationChainSelector, address receiver, string calldata message)
        external
        onlyOwner
        returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(message),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200000})),
            feeToken: address(_linkToken)
        });

        uint256 fees = _router.getFee(destinationChainSelector, evm2AnyMessage);

        if (fees > _linkToken.balanceOf(address(this))) {
            revert NotEnoughBalance(_linkToken.balanceOf(address(this)), fees);
        }

        _linkToken.approve(address(_router), fees);
        messageId = _router.ccipSend(destinationChainSelector, evm2AnyMessage);
        emit MessageSent(messageId, destinationChainSelector, receiver, message, address(_linkToken), fees);
        return messageId;
    }
}

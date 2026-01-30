// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract HousePicker is VRFConsumerBaseV2Plus {
    bytes32 public constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public constant ROLL_IN_PROGRESS = 4;

    uint256 public subscriptionId;

    uint32 public callbackGasLimit = 40000;
    uint32 public numWords = 1;

    uint16 public requestConfirmations = 3;

    mapping(uint256 => address) private _rollers;
    mapping(address => uint256) private _results;

    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);

    constructor(uint256 subscriptionId_, address coordinatorAddress_) VRFConsumerBaseV2Plus(coordinatorAddress_) {
        subscriptionId = subscriptionId_;
    }

    function rollDice() public returns (uint256 requestId) {
        require(_results[msg.sender] == 0, "Already rolled");

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: KEY_HASH,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true})) // Native Payment because it's easier to test using VRFCoordinatorV2_5Mock.
            })
        );

        _rollers[requestId] = msg.sender;
        _results[msg.sender] = ROLL_IN_PROGRESS;
        emit DiceRolled(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 d6Value = (randomWords[0] % 4);
        _results[_rollers[requestId]] = d6Value;
        emit DiceLanded(requestId, d6Value);
    }

    function house(address player) public view returns (string memory) {
        require(_results[player] != 0, "Dice not rolled");
        require(_results[player] != ROLL_IN_PROGRESS, "Roll in progress");
        return _getHouseName(_results[player]);
    }

    function _getHouseName(uint256 id) private pure returns (string memory) {
        string[4] memory houseNames = ["Gryffindor", "Hufflepuff", "Slytherin", "Ravenclaw"];
        return houseNames[id];
    }
}

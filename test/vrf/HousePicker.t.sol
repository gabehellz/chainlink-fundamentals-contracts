// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {HousePicker} from "../../src/vrf/HousePicker.sol";

contract HousePickerTest is Test {
    uint96 private _BASE_FEE = 1;
    uint96 private _GAS_PRICE = 1;
    int256 private _WEI_PER_UNIT_LINK = 1;

    VRFCoordinatorV2_5Mock public coordinator;
    HousePicker public housePicker;

    uint256 public subscriptionId;

    function setUp() public {
        coordinator = new VRFCoordinatorV2_5Mock(_BASE_FEE, _GAS_PRICE, _WEI_PER_UNIT_LINK);
        subscriptionId = coordinator.createSubscription();
        housePicker = new HousePicker(subscriptionId, address(coordinator));
        coordinator.addConsumer(subscriptionId, address(housePicker));
        coordinator.fundSubscriptionWithNative{value: 10 ether}(subscriptionId);
    }

    function test_rollDice() public {
        vm.expectRevert(bytes("Dice not rolled"));
        housePicker.house(address(this));

        vm.expectEmit(true, true, false, false, address(housePicker));
        emit HousePicker.DiceRolled(1, address(this));
        uint256 requestId = housePicker.rollDice();

        coordinator.fulfillRandomWords(requestId, address(housePicker));
        string memory house = housePicker.house(address(this));
        assertEq(abi.encode(house), abi.encode("Hufflepuff"));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract DiceGame is VRFConsumerBaseV2 {
    uint256 internal fee;
    uint256 public randomResult;
    address public owner;
    uint64 public s_subscriptionId;
    LinkTokenInterface LINKTOKEN;
    VRFCoordinatorV2Interface COORDINATOR;

    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    address link_token_contract = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        owner = msg.sender;
        s_subscriptionId = subscriptionId;
        LINKTOKEN = LinkTokenInterface(link_token_contract);
    }

    function getRandomNumber() public returns (uint256 requestId) {
        require(
            LINKTOKEN.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    function fulfillRandomWords(
    uint256 /* requestId */,
    uint256[] memory randomWords
    ) internal override {
        randomResult = (randomWords[0] % 6) + 1;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return LINKTOKEN.balanceOf(address(this));
    }
}

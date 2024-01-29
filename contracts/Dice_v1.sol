// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract VRFv2Consumer is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Cozy coin code.
    // address payable public owner;
    struct gameStatus{
        uint256 gameRoomId;
        address playUser;
        uint256 bet;
        uint8 expect;
        uint8 rand;
        bool result;
    }
    uint256 public gameRoomId;
    mapping(uint256 => gameStatus) public gameRoomInfo;
    uint256 public feeNumerator = 98;
    uint256 public feeDenominator = 100;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     */
    constructor(
        uint64 subscriptionId
    )
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        s_subscriptionId = subscriptionId;
        gameRoomId = 1;
        // owner = payable(msg.sender);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords()
        public
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256 randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords[0] % 6 + 1);
    }

    function joinGame(uint8 expectNumber) payable public {
        // requestRandomWords에서 requestId 받아온다.
        uint256 requestId = requestRandomWords();

        // 돈을 컨트랙트로 전송
        // msg.value에 입력시 자동으로 전송된다.

        // gameroom에 참가하는 유저, 베팅, 예측값, 랜덤값, requestId, 게임결과 를 넣는다.
        gameRoomInfo[requestId] = gameStatus({
            gameRoomId: gameRoomId,
            playUser: msg.sender,
            bet: msg.value,
            expect: expectNumber,
            rand: 0,
            result: false
        });
        gameRoomId++;
    }

    function gameResult(uint256 requestId, uint8 rand) payable public{
        require(gameRoomInfo[requestId].playUser == msg.sender, "not available user");
        gameRoomInfo[requestId].rand = rand;
        // 게임 승리
        if(rand == gameRoomInfo[requestId].expect){
            uint256 bet = gameRoomInfo[requestId].bet;
            uint256 payout = bet * 2 * feeNumerator / feeDenominator;
            require(address(this).balance >= payout, "not enough eth");
            payable(msg.sender).transfer(payout);
        }
        // 게임 패배
        gameRoomInfo[requestId].result = true;
    }

    function getGameRoomId(uint256 requestId) view public returns(uint256) {
        return gameRoomInfo[requestId].gameRoomId;
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

// 체인링크 VRF를 활용한 홀짝게임
// 참여자는 홀과 짝 중 하나를 선택하여 베팅을 한다.

contract OddEvenGame is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // Sepolia coordinator.
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    // Sepolia LINK token contract.
    address link_token_contract = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    // A reasonable default is 100000, but this value could be different
    // on other networks.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    // 3 ~ 100 설정 가능하고, 이는 몇 블록 뒤에 랜덤값이 생성되는지를 의미한다
    // 숫자가 작으면 값이 빠르게 나오는 대신 보안적으로 위험하고, 숫자가 크면 반대이다.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    // 우리는 1개의 랜덤값만 필요하다
    uint32 numWords = 1;

    // Storage parameters
    uint256[] public s_randomWords;
    uint256 public s_randomRange;
    uint256 public s_requestId;
    uint64 public s_subscriptionId;
    // 컨트랙트 owner
    address s_owner;

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */
    
    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;

        // _requestRandomWords();
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        // 1~6 사이의 랜덤 숫자를 생성
        // s_randomRange = (randomWords[0] % 6) + 1;
        s_randomWords = randomWords;
    }

    function requestRandomWords() external returns (uint256 requestId)
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
        
        return requestId;
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    // function rollDice(address roller) public returns (uint256 requestId) {
    //     // Will revert if subscription is not set and funded.
    //     requestId = COORDINATOR.requestRandomWords(
    //         keyHash,
    //         s_subscriptionId,
    //         requestConfirmations,
    //         callbackGasLimit,
    //         numWords
    //     );
        
    //     return requestId;
    // }

    // function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    //     s_randomRange = (randomWords[0] % 20) + 1;
    // }

    function get_randomwords() public view returns (uint256) {
        // requestRandomWords();
        return s_randomWords[0];
    }

    function get_subscriptionId() public view returns (uint64) {
        return s_subscriptionId;
    }

    function get_requestId() public view returns (uint256) {
        return s_requestId;
    }
}

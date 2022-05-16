// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract HilowContract is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address s_owner;
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 s_keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 2;

    uint256 private constant DRAW_IN_PROGRESS = 99;

    event CardDrawn(uint256 indexed requestId, address indexed drawer);
    event CardSeen(
        uint256 indexed requestId,
        uint256 indexed cardValue,
        uint256 indexed suitValue
    );

    mapping(uint256 => address) private s_drawers;
    mapping(address => uint256[2]) private s_results;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function drawCard(address drawer) public returns (uint256 requestId) {
        require(s_results[drawer][0] != DRAW_IN_PROGRESS, "Draw in progress");
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_drawers[requestId] = drawer;
        s_results[drawer] = [DRAW_IN_PROGRESS, DRAW_IN_PROGRESS];
        emit CardDrawn(requestId, drawer);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 cardValue = (randomWords[0] % 13) + 1;
        uint256 suitValue = (randomWords[1] % 4) + 1;
        s_results[s_drawers[requestId]] = [cardValue, suitValue];
        emit CardSeen(requestId, cardValue, suitValue);
    }

    function card(address player) public view returns (string memory) {
        require(s_results[player][0] != 0, "Card not drawn");
        require(s_results[player][0] != DRAW_IN_PROGRESS, "Draw in progress");
        return getCard(s_results[player][0], s_results[player][1]);
    }

    function getCard(uint256 cardValue, uint256 suitValue)
        private
        pure
        returns (string memory)
    {
        string[13] memory cardNames = [
            "A",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "J",
            "Q",
            "K"
        ];

        string[4] memory suitNames = ["Spades", "Hearts", "Diamonds", "Clubs"];

        return
            string(
                abi.encodePacked(
                    cardNames[cardValue - 1],
                    " of ",
                    suitNames[suitValue - 1]
                )
            );
    }
}

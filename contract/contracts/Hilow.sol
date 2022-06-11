// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Hilow is VRFConsumerBaseV2 {
    struct Card {
        uint256 value;
    }

    struct Game {
        Card firstDraw;
        Card secondDraw;
    }

    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address s_owner;
    address constant vrfCoordinator =
        0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 constant s_keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 constant callbackGasLimit = 1000000;
    uint16 constant requestConfirmations = 3;
    uint32 private constant MAX_WORDS = 20;
    uint32 private constant BUFFER_WORDS = 16;
    Card dummyCard = Card(0);
    mapping(uint256 => uint256) private LOW_BET_PAYOFFS;
    mapping(uint256 => uint256) private HIGH_BET_PAYOFFS;

    event CardDrawn(address indexed player, uint256 firstDrawCard);
    event GameFinished(
        address indexed player,
        uint256 firstDrawCard,
        uint256 secondDrawCard,
        bool isWin,
        uint256 payoutAmount
    );
    event DealerTipped(address indexed tipper, uint256 amount);

    constructor(uint64 subscriptionId)
        payable
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = payable(msg.sender);
        s_subscriptionId = subscriptionId;

        // Set low bet payoffs
        LOW_BET_PAYOFFS[1] = 300;
        LOW_BET_PAYOFFS[2] = 285;
        LOW_BET_PAYOFFS[3] = 270;
        LOW_BET_PAYOFFS[4] = 253;
        LOW_BET_PAYOFFS[5] = 236;
        LOW_BET_PAYOFFS[6] = 219;
        LOW_BET_PAYOFFS[7] = 202;
        LOW_BET_PAYOFFS[8] = 185;
        LOW_BET_PAYOFFS[9] = 168;
        LOW_BET_PAYOFFS[10] = 151;
        LOW_BET_PAYOFFS[11] = 134;
        LOW_BET_PAYOFFS[12] = 117;
        LOW_BET_PAYOFFS[13] = 100;

        // Set low bet payoffs
        HIGH_BET_PAYOFFS[1] = 100;
        HIGH_BET_PAYOFFS[2] = 117;
        HIGH_BET_PAYOFFS[3] = 134;
        HIGH_BET_PAYOFFS[4] = 151;
        HIGH_BET_PAYOFFS[5] = 168;
        HIGH_BET_PAYOFFS[6] = 185;
        HIGH_BET_PAYOFFS[7] = 202;
        HIGH_BET_PAYOFFS[8] = 219;
        HIGH_BET_PAYOFFS[9] = 236;
        HIGH_BET_PAYOFFS[10] = 253;
        HIGH_BET_PAYOFFS[11] = 270;
        HIGH_BET_PAYOFFS[12] = 285;
        HIGH_BET_PAYOFFS[13] = 300;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, bytes memory data) = s_owner.call{value: balance}(
            "Withdrawing funds"
        );
        require(success, "Withdraw failed");
    }

    Card[MAX_WORDS] private cards;
    using Counters for Counters.Counter;
    Counters.Counter private _currentCard;
    mapping(address => Game) private gamesByAddr;

    function viewCards()
        public
        view
        onlyOwner
        returns (Card[MAX_WORDS] memory)
    {
        return cards;
    }

    function viewCurrentCardCounter() public view onlyOwner returns (uint256) {
        return _currentCard.current();
    }

    function viewGame(address addr)
        public
        view
        onlyOwner
        returns (Game memory)
    {
        return gamesByAddr[addr];
    }

    function viewPayoffForBet(bool higher, uint256 firstCard)
        public
        view
        returns (uint256)
    {
        require(firstCard >= 1 && firstCard <= 13, "Invalid first card");
        if (higher) return HIGH_BET_PAYOFFS[firstCard];
        else return LOW_BET_PAYOFFS[firstCard];
    }

    function tip() public payable {
        console.log("Dealer tipped");
        emit DealerTipped(msg.sender, msg.value);
    }

    function drawBulkRandomCards() private returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            MAX_WORDS
        );
    }

    function initialCardLoad() public onlyOwner {
        drawBulkRandomCards();
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        for (uint256 index = 0; index < MAX_WORDS; index++) {
            cards[index] = Card((randomWords[index] % 13) + 1);
        }
        _currentCard.reset();
    }

    function isGameAlreadyStarted() public view returns (bool) {
        Game memory currentGame = gamesByAddr[msg.sender];
        if (
            (currentGame.firstDraw.value > 0 &&
                currentGame.secondDraw.value == 0)
        ) {
            return true;
        }
        return false;
    }

    function getActiveGame() public view returns (bool, Game memory) {
        if (isGameAlreadyStarted()) {
            return (true, gamesByAddr[msg.sender]);
        }
        return (false, Game(dummyCard, dummyCard));
    }

    function drawCard() public {
        if (_currentCard.current() > BUFFER_WORDS) {
            drawBulkRandomCards();
        }
        if (_currentCard.current() > MAX_WORDS) {
            _currentCard.reset();
        }

        require(!isGameAlreadyStarted(), "Game already started");
        uint256 currentCard = _currentCard.current();
        _currentCard.increment();
        Card memory firstDraw = cards[currentCard];
        Game memory game = Game(firstDraw, dummyCard);
        gamesByAddr[msg.sender] = game;
        emit CardDrawn(msg.sender, firstDraw.value);
    }

    function checkWin(Game memory currentGame, bool higher)
        private
        view
        returns (bool, uint256)
    {
        bool isWin;
        if (higher) {
            if (currentGame.firstDraw.value == 1) {
                if (
                    currentGame.secondDraw.value > currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            } else if (currentGame.firstDraw.value == 13) {
                if (
                    currentGame.secondDraw.value == currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            } else {
                if (
                    currentGame.secondDraw.value >= currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            }
        } else {
            if (currentGame.firstDraw.value == 1) {
                if (
                    currentGame.secondDraw.value == currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            } else if (currentGame.firstDraw.value == 13) {
                if (
                    currentGame.secondDraw.value < currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            } else {
                if (
                    currentGame.secondDraw.value <= currentGame.firstDraw.value
                ) {
                    isWin = true;
                }
            }
        }

        uint256 payoutAmount;
        if (isWin) {
            if (higher) {
                payoutAmount = SafeMath.div(
                    HIGH_BET_PAYOFFS[currentGame.firstDraw.value] * msg.value,
                    100
                );
            } else {
                payoutAmount = SafeMath.div(
                    LOW_BET_PAYOFFS[currentGame.firstDraw.value] * msg.value,
                    100
                );
            }
        }

        return (isWin, payoutAmount);
    }

    function bet(bool higher) public payable {
        Game memory currentGame = gamesByAddr[msg.sender];
        require(
            currentGame.firstDraw.value > 0,
            "First card should be drawn for the game"
        );
        require(
            currentGame.secondDraw.value == 0,
            "Second card has already been drawn for the game"
        );
        if (_currentCard.current() > MAX_WORDS) {
            _currentCard.reset();
        }

        uint256 currentCard = _currentCard.current();
        _currentCard.increment();
        Card memory secondDraw = cards[currentCard];
        currentGame.secondDraw = secondDraw;
        gamesByAddr[msg.sender] = currentGame;

        bool isWin;
        uint256 payoutAmount;
        (isWin, payoutAmount) = checkWin(currentGame, higher);
        if (isWin) {
            (bool success, bytes memory data) = payable(msg.sender).call{
                value: payoutAmount
            }("Sending payout");
            require(success, "Payout failed");
        }

        emit GameFinished(
            msg.sender,
            currentGame.firstDraw.value,
            currentGame.secondDraw.value,
            isWin,
            payoutAmount
        );
    }
}

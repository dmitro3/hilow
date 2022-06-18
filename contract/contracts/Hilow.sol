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

    struct GameCards {
        Card firstDraw;
        Card secondDraw;
        Card thirdDraw;
    }

    struct Game {
        GameCards cards;
        uint256 betAmount;
        bool firstPrediction;
        bool secondPrediction;
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
    event FirstBetMade(
        address indexed player,
        uint256 firstDrawCard,
        uint256 secondDrawCard,
        bool isWin
    );
    event GameFinished(
        address indexed player,
        uint256 firstDrawCard,
        uint256 secondDrawCard,
        uint256 thirdDrawCard,
        bool isWin,
        uint256 payoutMultiplier,
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
        GameCards memory currentGame = gamesByAddr[msg.sender].cards;
        if (
            (currentGame.firstDraw.value > 0 &&
                currentGame.thirdDraw.value == 0)
        ) {
            return true;
        }
        return false;
    }

    function getActiveGame() public view returns (bool, Game memory) {
        if (isGameAlreadyStarted()) {
            return (true, gamesByAddr[msg.sender]);
        }
        return (
            false,
            Game(GameCards(dummyCard, dummyCard, dummyCard), 0, false, false)
        );
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
        GameCards memory gameCards = GameCards(firstDraw, dummyCard, dummyCard);
        Game memory game = Game(gameCards, 0, false, false);
        gamesByAddr[msg.sender] = game;
        emit CardDrawn(msg.sender, firstDraw.value);
    }

    function checkWin(
        uint256 cardOne,
        uint256 cardTwo,
        bool higher
    ) private pure returns (bool) {
        bool isWin;
        if (higher) {
            if (cardOne == 1) {
                if (cardTwo > cardOne) {
                    isWin = true;
                }
            } else if (cardOne == 13) {
                if (cardTwo == cardOne) {
                    isWin = true;
                }
            } else {
                if (cardTwo >= cardOne) {
                    isWin = true;
                }
            }
        } else {
            if (cardOne == 1) {
                if (cardTwo == cardOne) {
                    isWin = true;
                }
            } else if (cardOne == 13) {
                if (cardTwo < cardOne) {
                    isWin = true;
                }
            } else {
                if (cardTwo <= cardOne) {
                    isWin = true;
                }
            }
        }

        return isWin;
    }

    function getPayoutMultiplier(uint256 cardOne, bool higher)
        private
        view
        returns (uint256)
    {
        uint256 multiplier;
        if (higher) {
            multiplier = HIGH_BET_PAYOFFS[cardOne];
        } else {
            multiplier = LOW_BET_PAYOFFS[cardOne];
        }

        return multiplier;
    }

    function makeFirstBet(bool higher) public payable {
        Game memory currentGame = gamesByAddr[msg.sender];
        GameCards memory currentGameCards = currentGame.cards;
        require(
            currentGameCards.firstDraw.value > 0,
            "First card should be drawn for the game"
        );
        require(
            currentGameCards.secondDraw.value == 0,
            "Second card has already been drawn for the game"
        );
        if (_currentCard.current() > MAX_WORDS) {
            _currentCard.reset();
        }

        uint256 currentCard = _currentCard.current();
        _currentCard.increment();
        Card memory secondDraw = cards[currentCard];
        currentGameCards.secondDraw = secondDraw;
        currentGame.betAmount = msg.value;
        currentGame.firstPrediction = higher;
        gamesByAddr[msg.sender] = Game(
            currentGameCards,
            currentGame.betAmount,
            currentGame.firstPrediction,
            false
        );

        bool isWin;
        isWin = checkWin(
            currentGameCards.firstDraw.value,
            currentGameCards.secondDraw.value,
            higher
        );
        // TODO: Reset to dummy game if not a win

        emit FirstBetMade(
            msg.sender,
            currentGameCards.firstDraw.value,
            currentGameCards.secondDraw.value,
            isWin
        );
    }

    function makeSecondBet(bool higher) public {
        Game memory currentGame = gamesByAddr[msg.sender];
        GameCards memory currentGameCards = currentGame.cards;
        require(
            currentGameCards.firstDraw.value > 0 &&
                currentGameCards.secondDraw.value > 0,
            "First and second card should be drawn for the game"
        );
        require(
            currentGameCards.thirdDraw.value == 0,
            "Third card has already been drawn for the game"
        );
        if (_currentCard.current() > MAX_WORDS) {
            _currentCard.reset();
        }

        uint256 currentCard = _currentCard.current();
        _currentCard.increment();
        Card memory thirdDraw = cards[currentCard];
        currentGameCards.thirdDraw = thirdDraw;
        currentGame.secondPrediction = higher;
        gamesByAddr[msg.sender] = Game(
            currentGameCards,
            currentGame.betAmount,
            currentGame.firstPrediction,
            currentGame.secondPrediction
        );

        bool isFirstWin = checkWin(
            currentGameCards.firstDraw.value,
            currentGameCards.secondDraw.value,
            currentGame.firstPrediction
        );
        bool isSecondWin = checkWin(
            currentGameCards.secondDraw.value,
            currentGameCards.thirdDraw.value,
            currentGame.secondPrediction
        );

        uint256 payoutMultiplier;
        uint256 payoutAmount;

        if (isFirstWin && isSecondWin) {
            uint256 multiplier1 = getPayoutMultiplier(
                currentGameCards.firstDraw.value,
                currentGame.firstPrediction
            );
            uint256 multiplier2 = getPayoutMultiplier(
                currentGameCards.secondDraw.value,
                currentGame.secondPrediction
            );
            payoutAmount =
                (currentGame.betAmount * multiplier1 * multiplier2) /
                10000;
            (bool success, bytes memory data) = payable(msg.sender).call{
                value: payoutAmount
            }("Sending payout");
            require(success, "Payout failed");
        }

        emit GameFinished(
            msg.sender,
            currentGameCards.firstDraw.value,
            currentGameCards.secondDraw.value,
            currentGameCards.thirdDraw.value,
            isSecondWin,
            payoutMultiplier,
            payoutAmount
        );
    }
}

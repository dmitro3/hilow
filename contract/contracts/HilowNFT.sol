//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";
import "./PayableContract.sol";

import {Base64} from "./libraries/Base64.sol";

contract HilowSupporterNFT is ERC721URIStorage, Ownable, PayableHilowContract {
    address internal _gameContractAddress;
    PayableHilowContract gameContract;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 TOTAL_NFTS = 676;
    uint256 MIN_MINT_PRICE = 10 * 10**15;
    uint256 MAX_MINT_PER_WALLET = 3;
    uint256 private mintedCount;
    uint256[] mintedTokenIds;
    mapping(uint256 => string) suits;
    mapping(address => uint256) mintCountByAddress;

    event NFTMinted(address owner, uint256 tokenId);

    constructor() ERC721("DegenJack Supporter NFT", "DEGENJACK") {
        console.log("DegenJack supporter NFT!");
        suits[0] = unicode"♦";
        suits[1] = unicode"♠";
        suits[2] = unicode"♥";
        suits[3] = unicode"♣";
    }

    receive() external payable {}

    function setGameContract(address payable _address) public onlyOwner {
        _gameContractAddress = _address;
        gameContract = PayableHilowContract(_gameContractAddress);
    }

    function getMintedCount() public view returns (uint256) {
        return mintedCount;
    }

    function mint() public payable {
        require(mintedCount < TOTAL_NFTS, "No more NFTs can be minted!");
        require(msg.value >= MIN_MINT_PRICE, "Not enough MATIC paid");
        require(
            mintCountByAddress[msg.sender] < MAX_MINT_PER_WALLET,
            "No more NFTs can be minted with this wallet"
        );
        uint256 currentId = _tokenIds.current();
        _safeMint(msg.sender, currentId);
        string memory suit = suits[currentId / 169];
        string memory card1 = getCardName((currentId % 169) / 13);
        string memory card2 = getCardName((currentId % 169) % 13);
        string memory name = string(
            abi.encodePacked(suit, " (", card1, ", ", card2, ")")
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "I am rooting for DegenJack!", ',
                        '"image": "ipfs://QmabaLMm2FTzzFTQRt11aKrHFcVadGZEWb5rduvnkJeK4N"}'
                    )
                )
            )
        );
        _setTokenURI(
            currentId,
            string(abi.encodePacked("data:application/json;base64,", json))
        );
        _tokenIds.increment();
        mintedCount += 1;
        mintedTokenIds.push(currentId);
        mintCountByAddress[msg.sender] += 1;
        emit NFTMinted(msg.sender, currentId);
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            currentId,
            msg.sender
        );
        require(
            _gameContractAddress != address(0),
            "Game contract address should be set"
        );
        bool success = gameContract.sendFunds{value: msg.value}();
        require(success, "Fund transfer to game contract failed");
    }

    function getCardName(uint256 value) internal pure returns (string memory) {
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

        return cardNames[value];
    }

    function payoutSupporters() public onlyOwner {
        require(
            _gameContractAddress != address(0),
            "Game contract address should be set"
        );
        uint256 balance = address(this).balance;
        uint256 payoutPerSupporter = SafeMath.div(balance, TOTAL_NFTS);

        for (uint256 index = 0; index < mintedTokenIds.length; index++) {
            uint256 tokenId = mintedTokenIds[index];
            address tokenOwner = ownerOf(tokenId);
            (bool success, bytes memory data) = payable(tokenOwner).call{
                value: payoutPerSupporter
            }("Sending payout to supporter");
            require(success, "Payout failed");
        }

        uint256 postPayoutBalance = address(this).balance;
        bool rsuccess = gameContract.sendFunds{value: postPayoutBalance}();
        require(rsuccess, "Return funds failed");
    }
}

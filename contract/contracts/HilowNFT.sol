//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract TheNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 TOTAL_NFTS = 676;
    uint256 private mintedCount;

    event NFTMinted(address owner, uint256 tokenId);

    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    constructor() ERC721("DegenJack Supporter NFT", "DEGENJACK") {
        console.log("DegenJack supporter NFT!");
    }

    function getMintedCount() public view returns (uint256) {
        return mintedCount;
    }

    function mint() public {
        require(mintedCount < TOTAL_NFTS, "No more NFTs can be minted!");
        uint256 currentId = _tokenIds.current();
        string memory nftSvg = string(
            abi.encodePacked(baseSvg, currentId, "</text></svg>")
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        currentId,
                        '", "description": "Your message - ',
                        currentId,
                        '", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(nftSvg)),
                        '"}'
                    )
                )
            )
        );
        _safeMint(msg.sender, currentId);
        _setTokenURI(
            currentId,
            string(abi.encodePacked("data:application/json;base64,", json))
        );
        _tokenIds.increment();
        mintedCount += 1;
        emit NFTMinted(msg.sender, currentId);
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            currentId,
            msg.sender
        );
    }
}

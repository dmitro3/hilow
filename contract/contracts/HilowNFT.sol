//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract HilowSupporterNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 TOTAL_NFTS = 676;
    uint256 private mintedCount;

    event NFTMinted(address owner, uint256 tokenId);

    constructor() ERC721("DegenJack Supporter NFT", "DEGENJACK") {
        console.log("DegenJack supporter NFT!");
    }

    function getMintedCount() public view returns (uint256) {
        return mintedCount;
    }

    function mint() public {
        require(mintedCount < TOTAL_NFTS, "No more NFTs can be minted!");
        uint256 currentId = _tokenIds.current();
        _safeMint(msg.sender, currentId);
        _setTokenURI(
            currentId,
            "ipfs://QmU4bXDe36gBtp7QLePi7LYWDSTptM1cZ2f4RwJmUUkGT8"
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

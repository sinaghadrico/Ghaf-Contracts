// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Erc721 implements the standard functionality.
// Ownable is used for access control functionality.

contract GhafNFT is Ownable, ERC721URIStorage {
    // name and symbol
    constructor() ERC721("Ghaf NFT", "GNFT") {}

    /// @notice           Mint a NFT token
    /// @param recipient  Address of the owner of the NFT
    /// @param tokenId    A number that you can specify to uniquely identify the NFT within the NFT token contract.
    /// @param tokenURI    A URL that points to the location of the NFT metadata. A common storage for the NFT is IPFS. Alternatively,

    function mint(
        address recipient,
        uint256 tokenId,
        string memory tokenURI
    ) public onlyOwner {
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}

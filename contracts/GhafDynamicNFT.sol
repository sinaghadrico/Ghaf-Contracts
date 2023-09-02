// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GhafDynamicNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _tokenIdCounter;
    string private _baseTokenURI;

    mapping(uint256 => string) private _tokenAttributes;

    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    function setBaseTokenURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function mint(string memory attributes) external onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _mint(msg.sender, tokenId);
        _tokenAttributes[tokenId] = attributes;
        _tokenIdCounter++;
    }

    function getTokenAttributes(uint256 tokenId) external view returns (string memory) {
        return _tokenAttributes[tokenId];
    }
}

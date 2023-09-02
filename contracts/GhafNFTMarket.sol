// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is ERC1155, Ownable {
    uint256 private _tokenIdCounter;

    mapping(uint256 => address) private _tokenCreators;
    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => address) private _tokenOwners;

    constructor(string memory uri) ERC1155(uri) {}

    function createNFT(string memory _uri, uint256 initialSupply, uint256 price) external onlyOwner {
        uint256 tokenId = _tokenIdCounter++;
        _mint(msg.sender, tokenId, initialSupply, "");
        _tokenCreators[tokenId] = msg.sender;
        _tokenPrices[tokenId] = price;
        _tokenOwners[tokenId] = msg.sender;
        // _setURI(tokenId, _uri);
    }

    function offerForSale(uint256 tokenId, uint256 price) external {
        require(_tokenOwners[tokenId] == msg.sender, "You're not the owner of this token");
        _tokenPrices[tokenId] = price;
    }

    function purchase(uint256 tokenId) external payable {
        require(_tokenPrices[tokenId] > 0, "This token is not for sale");
        require(msg.value >= _tokenPrices[tokenId], "Insufficient funds");

        address seller = _tokenOwners[tokenId];
        address buyer = msg.sender;
        uint256 price = _tokenPrices[tokenId];

        safeTransferFrom(seller, buyer, tokenId, 1, "");
        _tokenPrices[tokenId] = 0; // Remove the token from sale
        _tokenOwners[tokenId] = buyer; // Update ownership
        payable(seller).transfer(price); // Send funds to the seller
    }

    function tokenCreator(uint256 tokenId) external view returns (address) {
        return _tokenCreators[tokenId];
    }

    function tokenPrice(uint256 tokenId) external view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _tokenOwners[tokenId];
    }
}

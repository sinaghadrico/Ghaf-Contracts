// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GhafUserBusinessToken is ERC721, Ownable {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    uint256 private tokenIdCounter;

    struct Business {
        string name;
        string description;
        address owner;
    }

    mapping(uint256 => Business) public businesses;

    function createBusiness(
        string memory _name,
        string memory _description
    ) external onlyOwner {
        uint256 tokenId = tokenIdCounter;
        _mint(msg.sender, tokenId);
        businesses[tokenId] = Business(_name, _description, msg.sender);
        tokenIdCounter++;
    }

    function updateBusiness(
        uint256 _tokenId,
        string memory _name,
        string memory _description
    ) external {
        require(_exists(_tokenId), "Token does not exist");
        require(
            msg.sender == businesses[_tokenId].owner,
            "Not the owner of the business"
        );

        businesses[_tokenId].name = _name;
        businesses[_tokenId].description = _description;
    }
}

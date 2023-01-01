// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IGhafNftMarketPlace {
    // Struct

    struct Auction {
        address seller;
        address owner;
        uint256 initialPrice;
        address highestBidder;
        uint256 highestBid;
        uint256 closeTimestamp;
        uint256 tokenId;
        address nftContractAddress;
    }

    // Events

    event AuctionCreated(
        address seller,
        address owner,
        uint256 initialPrice,
        address highestBidder,
        uint256 highestBid,
        uint256 closeTimestamp,
        uint256 indexed tokenId,
        address nftContractAddress
    );

    event BidCreated(
        address bidder,
        uint256 bidPrice,
        uint256 indexed tokenId,
        address nftContractAddress
    );

    // Read-only functions

    // State-changing functions

    function listMyNFTToSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _auctionDuration
    ) external returns (bool);

    function bidForNFT(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    ) external payable returns (bool);
}

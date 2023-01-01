// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/IGhafNftMarketPlace.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GhafNftMarketPlace is IGhafNftMarketPlace, Ownable {
    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "GhafNftMarketPlace: zero address");
        _;
    }

    modifier nonZeroValue(uint _value) {
        require(_value > 0, "GhafNftMarketPlace: zero value");
        _;
    }

    mapping(address => mapping(uint256 => Auction)) public auctions;

    /// @notice                     List NFT to auction List for sale
    /// @dev                        Call approve function of Nft Contract before the call this func
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _initialPrice        The initial price value that can be bid on an action
    /// @param _auctionDuration     The period of time (timestamp) each user can bid on an action
    /// @return                     True if auction is added successfully
    function listMyNFTToSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _auctionDuration
    )
        external
        override
        nonZeroAddress(_nftContractAddress)
        nonZeroValue(_initialPrice)
        returns (bool)
    {
        IERC721(_nftContractAddress).transferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        Auction memory item;
        item.seller = _msgSender();
        item.owner = address(this);
        item.initialPrice = _initialPrice;
        item.closeTimestamp = block.timestamp + _auctionDuration;

        auctions[_nftContractAddress][_tokenId] = item;

        emit AuctionCreated(
            item.seller,
            item.owner,
            item.initialPrice,
            item.highestBidder,
            item.highestBid,
            item.closeTimestamp,
            item.tokenId,
            item.nftContractAddress
        );

        return true;
    }

    /// @notice                     Bid on an auction to get a NFT
    /// @dev                        Submit the asking price in order to complete the bid on ( msg value )
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _bidPrice            The price that is bigger than the initial price and last bid price is on this action
    function bidForNFT(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    )
        external
        payable
        override
        nonZeroAddress(_nftContractAddress)
        nonZeroValue(_bidPrice)
        returns (bool)
    {
        Auction memory auctionItem = auctions[_nftContractAddress][_tokenId];

        require(
            block.timestamp < auctionItem.closeTimestamp,
            "auction is closed"
        );

        require(
            _bidPrice > auctionItem.highestBid &&
                _bidPrice >= auctionItem.initialPrice,
            "bid price is low"
        );

        require(
            msg.value == _bidPrice,
            "please submit the asking price in order to complete the bid, incompatible msg value"
        );

        if (auctionItem.highestBidder != address(0)) {
            Address.sendValue(
                payable(auctionItem.highestBidder),
                auctionItem.highestBid
            );
        }

        auctions[_nftContractAddress][_tokenId].highestBidder = _msgSender();
        auctions[_nftContractAddress][_tokenId].highestBid = _bidPrice;

        emit BidCreated(_msgSender(), _bidPrice, _tokenId, _nftContractAddress);

        return true;
    }
}

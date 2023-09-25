// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";



library GhafMarketPlaceLib {

    // Structures

    enum BuyTypes {
        BUYNOW, // BUYNOW
        AUCTION //AUCTION                    
    }


    /// @notice Structure for storing Nft data
    /// @param seller Address of seller 
    /// @param isSold True if the Nft is sold
    /// @param hasAccepted True if the seller accepted one of the bids
    /// @param deadline The time(timestamp) each user can bid on an nft
    /// @param buyType Type of Buy nft (e.g. BUYNOW or AUCTION )
    /// @param initialAmount Initial Amount of buyre's can uses for payment
    /// @param initialPaymentToken Initial Address of token that buyer uses for payment
	struct Nft {
        address seller;
        bool isSold;
        bool hasAccepted;
        bool isListed;
        uint256 deadline;
        BuyTypes buyType;
        uint initialAmount;
        address initialPaymentToken;
  	}

    /// @notice Structure for recording buyers bids
    /// @param buyer Buyer can withdraw ETH to this address or send Nft to this address
    /// @param bidAmount Amount of buyre's bid
    /// @param isAccepted True if the bid is accepted by seller
    /// @param paymentToken Address of token that buyer uses for payment
	struct Bid {
		address buyer;
		uint bidAmount;
        bool isAccepted;
        address paymentToken;
  	}

    function listNftHelper(
        address _nftContractAddress,
        uint256 _tokenId,
        BuyTypes _buyType,
        uint256 _deadline,
        mapping(address =>  mapping(uint => Nft)) storage nfts,
        address _seller,
        uint _initialAmount,
        address _initialPaymentToken
    ) external  {
        require(
            !nfts[_nftContractAddress][_tokenId].isListed, 
            "GhafMarketPlace: already listed"
        );
 
        // Saves listed Nft
        Nft memory _nft;
        _nft.seller = _seller;
        _nft.isListed = true;
        _nft.buyType = _buyType;
        _nft.deadline = _deadline;
        _nft.initialAmount = _initialAmount;
        _nft.initialPaymentToken = _initialPaymentToken;
        nfts[_nftContractAddress][_tokenId] = _nft;
    }

    function delistNftHelper(
        address _nftContractAddress,
        uint256 _tokenId,
        mapping(address  => mapping(uint => Nft)) storage nfts,
        address _seller
    ) external view {
        require(nfts[_nftContractAddress][_tokenId].isListed, "GhafMarketPlace: no nft");
        require(nfts[_nftContractAddress][_tokenId].seller == _seller, "GhafMarketPlace: not owner");
        require(!nfts[_nftContractAddress][_tokenId].isSold, "GhafMarketPlace: already sold");
        require(!nfts[_nftContractAddress][_tokenId].hasAccepted, "GhafMarketPlace: already accepted");
    }

    function putBidHelper(
        address _nftContractAddress,
        uint256 _tokenId,
        mapping(address  => mapping(uint => Nft)) storage nfts,
        uint256 timestamp
    ) external view {
        _canBid(
            nfts[_nftContractAddress][_tokenId].isListed, 
            nfts[_nftContractAddress][_tokenId].hasAccepted,
            nfts[_nftContractAddress][_tokenId].isSold,
            nfts[_nftContractAddress][_tokenId].buyType,
            nfts[_nftContractAddress][_tokenId].deadline,
            timestamp
        );
    }

    function increaseBidHelper(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _bidIdx,
        uint _newAmount,
        mapping(address  => mapping(uint => Nft)) storage nfts,
        mapping(address  => mapping(uint => Bid[])) storage bids,
        address _seller,
        uint256 timestamp
    ) external view {
        _canBid(
            nfts[_nftContractAddress][_tokenId].isListed, 
            nfts[_nftContractAddress][_tokenId].hasAccepted,
            nfts[_nftContractAddress][_tokenId].isSold,
            nfts[_nftContractAddress][_tokenId].buyType,
            nfts[_nftContractAddress][_tokenId].deadline,
            timestamp
        );

        require(
            bids[_nftContractAddress][_tokenId][_bidIdx].buyer == _seller, 
            "GhafMarketPlace: not owner"
        );
        require(
            _newAmount > bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount, 
            "GhafMarketPlace: low amount"
        );
    }

  

    /// @notice Checks the bidding conditions
    /// @dev Conditions for bidding: Nft exists, no offer accepted, not sold
    function _canBid(
        bool _isListed,
        bool _hasAccepted,
        bool _isSold,
        BuyTypes buyType,
        uint256 deadline,
        uint256 timestamp
    ) private pure {
        require(_isListed, "GhafMarketPlace: not listed");
        require(!_hasAccepted, "GhafMarketPlace: already accepted");
        require(!_isSold, "GhafMarketPlace: sold nft");
        require(buyType == BuyTypes.AUCTION, "GhafMarketPlace: buyType is not AUCTION");
        require(
            timestamp < deadline,
            "GhafMarketPlace: The deadline for bid is over"
        );
    }
}
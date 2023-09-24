// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.4;

import "./interfaces/IGhafMarketPlaceLogic.sol";
import "./GhafMarketPlaceStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GhafMarketPlaceLogic is IGhafMarketPlaceLogic, GhafMarketPlaceStorage,
    OwnableUpgradeable, PausableUpgradeable {

    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "GhafMarketPlace: address is zero");
        _;
    }

    function initialize(
        uint _protocolFee,
        address _treasury
    ) public initializer {
        OwnableUpgradeable.__Ownable_init();
        // ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        PausableUpgradeable.__Pausable_init();

        setProtocolFee(_protocolFee);
        setTreasury(_treasury);
    }

    receive() external payable {}
    

    /// @notice Setter for treasury address
    function setTreasury(address _treasury) public override nonZeroAddress(_treasury) onlyOwner {
        treasury = _treasury;
    }

    /// @notice Setter for protocol fee
    function setProtocolFee(uint _protocolFee) public override onlyOwner {
        require(MAX_PROTOCOL_FEE >= _protocolFee, "GhafMarketPlace: invalid fee");
        protocolFee = _protocolFee;
    }


    /// @notice Pause the contract so only the functions can be called which are whenPaused
    /// @dev Only owner can pause 
    function pause() external override onlyOwner {
        _pause();
    }

    /// @notice Unpause the contract so only the functions can be called which are whenNotPaused
    /// @dev Only owner can pause
    function unpause() external override onlyOwner {
        _unpause();
    }

    function renounceOwnership() public virtual override onlyOwner {}
    
    /// @notice                     Lists Nft of a user
    /// @dev                        Call approve function of Nft Contract before the call this func
    /// @dev                        Just owner of nft can call this func
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _buyType             Type of Buy nft (e.g. BUYNOW or AUCTION )
    function listNft(
        address _nftContractAddress,
        uint256 _tokenId,
        GhafMarketPlaceLib.BuyTypes _buyType
	) external  whenNotPaused  override returns (bool) {


        require(
                IERC721(_nftContractAddress).ownerOf(_tokenId
                ) == _msgSender(),
                "Caller is not the owner"
            );
        IERC721(_nftContractAddress).transferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );
        
        GhafMarketPlaceLib.listNftHelper(
            _nftContractAddress,
            _tokenId,
            _buyType,
            nfts,
            _msgSender()
        );
        
        emit NftListed(
            _nftContractAddress, 
            _tokenId, 
            _msgSender(), 
            _buyType
        );

        return true;
    }

    /// @notice                     Delists an Nft
    /// @dev                        Revokes all the existing bids
    ///                             Reverts if the seller has accepted a bid or sold it
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    function delistNft(
        address _nftContractAddress,
        uint256 _tokenId
    ) external override returns (bool) {


        address _seller = nfts[_nftContractAddress][_tokenId].seller;


        GhafMarketPlaceLib.delistNftHelper(
            _nftContractAddress,
            _tokenId,
            nfts,
            nfts[_nftContractAddress][_tokenId].seller
        );

         IERC721(_nftContractAddress).transferFrom(
            address(this),
            _seller,
            _tokenId
        );

        // Revokes all bids
        for (uint i = 0; i < bids[_nftContractAddress][_tokenId].length; i++) {
            if (bids[_nftContractAddress][_tokenId][i].buyerAddress != address(0)) { 
                // ^ If the bid is not empty
                emit BidRevoked(
                    _nftContractAddress, 
                    _tokenId, 
                    nfts[_nftContractAddress][_tokenId].seller,
                    bids[_nftContractAddress][_tokenId][i].buyerAddress,
                    i
                );
                _removeBid(
                    _nftContractAddress, 
                    _tokenId, 
                    bids[_nftContractAddress][_tokenId][i].buyerAddress, 
                    i
                );
            }    
        }



        emit NftDelisted(
            _nftContractAddress, 
            _tokenId, 
            nfts[_nftContractAddress][_tokenId].seller
        );
        nfts[_nftContractAddress][_tokenId].seller = address(0);
        nfts[_nftContractAddress][_tokenId].isSold = false;
        nfts[_nftContractAddress][_tokenId].hasAccepted = false;
        nfts[_nftContractAddress][_tokenId].isListed = false;
        nfts[_nftContractAddress][_tokenId].buyType = GhafMarketPlaceLib.BuyTypes.BUYNOW;

        return true;
    }

    /// @notice                     Puts bid for buyying an Nft
    /// @dev                        User sends the bid amount along with the request
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _amount              Amount of buyer's bid
    /// @param _paymentToken        Address of token that buyer uses for payment
    function putBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _amount,
        address _paymentToken
    ) external payable whenNotPaused nonZeroAddress(_paymentToken) override returns (uint _bidIdx) {
        
        GhafMarketPlaceLib.putBidHelper(_nftContractAddress, _tokenId, nfts);

        // Stores bid
        GhafMarketPlaceLib.Bid memory _bid;
        _bid.buyerAddress = _msgSender();
        if (_paymentToken == NATIVE_TOKEN) {
            require(msg.value == _amount, "GhafMarketPlace: wrong value");
        } else {
            IERC20(_paymentToken).transferFrom(_msgSender(), address(this), _amount);
        }
        _bid.bidAmount = _amount;
        _bid.paymentToken = _paymentToken;
        bids[_nftContractAddress][_tokenId].push(_bid);
        _bidIdx = bids[_nftContractAddress][_tokenId].length - 1;

        emit NewBid(
            _nftContractAddress, 
            _tokenId,
            nfts[_nftContractAddress][_tokenId].seller, 
            _msgSender(),
            _amount,
            _paymentToken,
            _bidIdx
        );

    }

    /// @notice                     Increases the existing bid amount
    /// @dev                        Reverts if the new amount is lower than the previous amount
    ///                             User sends the bid difference
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _bidIdx              of the buyer
    /// @param _newAmount           of bid
    function increaseBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _bidIdx,
        uint _newAmount
    ) external payable whenNotPaused override returns (bool) {

        GhafMarketPlaceLib.increaseBidHelper(
            _nftContractAddress,
            _tokenId,
            _bidIdx,
            _newAmount,
            nfts,
            bids,
            _msgSender()
        );

        uint bidDifference = _newAmount - bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount;
        address paymentToken = bids[_nftContractAddress][_tokenId][_bidIdx].paymentToken;

        if (paymentToken == NATIVE_TOKEN) {
            require(msg.value == bidDifference, "GhafMarketPlace: wrong value");
        } else {
            IERC20(paymentToken).transferFrom(_msgSender(), address(this), bidDifference);
        }
        
        bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount = _newAmount;

        emit BidUpdated(
            _nftContractAddress, 
            _tokenId, 
            nfts[_nftContractAddress][_tokenId].seller,
            _msgSender(),
            _bidIdx,
            _newAmount
        );

        return true;
    }

    /// @notice                     Removes buyer's bid
    /// @dev                        Only bid owner can call this function
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _bidIdx              Index of the bid in bids list
    function cancelBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _bidIdx
    ) external override returns (bool) {
        require(
            bids[_nftContractAddress][_tokenId][_bidIdx].buyerAddress == _msgSender(),
            "GhafMarketPlace: not owner"
        );

        // Handles the case where the seller accepted a bid 
        if (bids[_nftContractAddress][_tokenId][_bidIdx].isAccepted) {
            require(!nfts[_nftContractAddress][_tokenId].isSold, "GhafMarketPlace: nft sold");
            // Changes the status of the Nft (so seller can accept a new bid)
            nfts[_nftContractAddress][_tokenId].hasAccepted = false;
        }

        emit BidCanceled(
            _nftContractAddress, 
            _tokenId, 
            nfts[_nftContractAddress][_tokenId].seller,
            bids[_nftContractAddress][_tokenId][_bidIdx].buyerAddress,
            _bidIdx
        );
        _removeBid(_nftContractAddress, _tokenId,_msgSender(), _bidIdx);

        return true;
    }

    /// @notice                     Accepts one of the existing bids & Sends funds to seller & Send Nft to Buyer
    /// @dev                        Will be reverted if the seller has already accepted a bid
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _bidIdx              Index of the bid in bids list
    function acceptBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _bidIdx
    ) external whenNotPaused override returns (bool) {
        require(nfts[_nftContractAddress][_tokenId].seller == _msgSender(), "GhafMarketPlace: not owner");
        require(nfts[_nftContractAddress][_tokenId].buyType == GhafMarketPlaceLib.BuyTypes.AUCTION, "GhafMarketPlace: buyType is not AUCTION");
        require(!nfts[_nftContractAddress][_tokenId].hasAccepted, "GhafMarketPlace: already accepted");
        require(bids[_nftContractAddress][_tokenId].length > _bidIdx, "GhafMarketPlace: invalid idx");  


        nfts[_nftContractAddress][_tokenId].hasAccepted = true;
        bids[_nftContractAddress][_tokenId][_bidIdx].isAccepted = true;


        emit BidAccepted(
            _nftContractAddress, 
            _tokenId,
            nfts[_nftContractAddress][_tokenId].seller,
            bids[_nftContractAddress][_tokenId][_bidIdx].buyerAddress,
            _bidIdx
        );
        _buy(_nftContractAddress,_tokenId,bids[_nftContractAddress][_tokenId][_bidIdx].buyerAddress,bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount,bids[_nftContractAddress][_tokenId][_bidIdx].paymentToken,GhafMarketPlaceLib.BuyTypes.AUCTION);

        return true;
    }

    /// @notice                     Sends funds to seller & Send Nft to Buyer
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _buyerAddress     Address of buyer
    /// @param _amount              Amount of buyer's pay
    /// @param _paymentToken        Address of token that buyer uses for payment
    function _buy(
        address _nftContractAddress,
        uint256 _tokenId,
        address _buyerAddress,
        uint _amount,
        address _paymentToken,
        GhafMarketPlaceLib.BuyTypes  _buyType
    ) internal  returns (bool) {
        // Checks that Nft hasn't been sold before
        require(!nfts[_nftContractAddress][_tokenId].isSold, "GhafMarketPlace: sold nft");
        
        IERC721(_nftContractAddress).transferFrom(
            address(this),
            _buyerAddress,
            _tokenId
        );

        

        nfts[_nftContractAddress][_tokenId].isSold = true;
        nfts[_nftContractAddress][_tokenId].isListed = false;
        nfts[_nftContractAddress][_tokenId].hasAccepted = false;

        uint fee = _sendTokens(_nftContractAddress,_tokenId, _amount,_paymentToken);

         emit NftSold(
            _nftContractAddress, 
            _tokenId,
            nfts[_nftContractAddress][_tokenId].seller,
            _buyerAddress,
            fee,
            _amount,
            _paymentToken,
            _buyType
            );
        
        

        return true;
    }

    /// @notice                     Puts amount for buyying an Nft & Sends funds to seller & Send Nft to Buyer
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _amount              Amount of buyer's pay
    /// @param _paymentToken        Address of token that buyer uses for payment
    function buyNft(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _amount,
        address _paymentToken
    ) external payable override returns (bool){
      require(nfts[_nftContractAddress][_tokenId].buyType == GhafMarketPlaceLib.BuyTypes.BUYNOW, "GhafMarketPlace: buyType is not BUYNOW");

       if (_paymentToken == NATIVE_TOKEN) {
            require(msg.value == _amount, "GhafMarketPlace: wrong value");
        } else {
            IERC20(_paymentToken).transferFrom(_msgSender(), address(this), _amount);
        }
        _buy(_nftContractAddress,_tokenId,_msgSender(),_amount,_paymentToken,GhafMarketPlaceLib.BuyTypes.BUYNOW);
    }

    /// @notice                     Removes a bid
    /// @param _nftContractAddress  Address of NFT token contract
    /// @param _tokenId             A number that identify the NFT within the NFT token contract
    /// @param _buyer               Address of buyer
    /// @param _bidIdx              Index of the bid in bids list
    function _removeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _buyer, 
        uint _bidIdx
    ) private {
        if (bids[_nftContractAddress][_tokenId][_bidIdx].paymentToken == NATIVE_TOKEN) {
            // Sends ETH to buyer
            Address.sendValue(payable(_buyer), bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount);
        } else {
            IERC20(bids[_nftContractAddress][_tokenId][_bidIdx].paymentToken).transfer(
                _buyer,
                bids[_nftContractAddress][_tokenId][_bidIdx].bidAmount
            );
        }

        // Deletes the bid
        delete bids[_nftContractAddress][_tokenId][_bidIdx];
    }

    /// @notice Sends tokens to seller and treasury
    function _sendTokens(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _payAmount,
        address _paymentToken
    ) internal returns (uint _fee) {

        address paymentToken = _paymentToken;
        uint payAmount = _payAmount;
        _fee = protocolFee * payAmount / MAX_PROTOCOL_FEE;
        
        if (paymentToken == NATIVE_TOKEN) {
            Address.sendValue(payable(nfts[_nftContractAddress][_tokenId].seller), payAmount - _fee);
            if (_fee > 0) {
                Address.sendValue(payable(treasury), _fee);
            }
        } else { 
            IERC20(paymentToken).transfer(
                nfts[_nftContractAddress][_tokenId].seller,
                payAmount - _fee
            );
            if (_fee > 0) {
                IERC20(paymentToken).transfer(
                    treasury,
                    _fee
                );
            }
        }
    }
}

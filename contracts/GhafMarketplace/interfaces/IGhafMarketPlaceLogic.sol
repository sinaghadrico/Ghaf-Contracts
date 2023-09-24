// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.4;

import "./IGhafMarketPlaceStorage.sol";
import "../GhafMarketPlaceLib.sol";


interface IGhafMarketPlaceLogic is IGhafMarketPlaceStorage {

  	// Events

    event NftListed(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller,
        GhafMarketPlaceLib.BuyTypes buyType
    );

    event NftDelisted(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller
    );

    event NewBid(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller, 
        address buyer,
        uint bidAmount,
        address paymentToken,
        uint bidIdx
    );

    event BidUpdated(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller, 
        address buyer, 
        uint bidIdx,
        uint newAmount
    );

    event BidAccepted(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller, 
        address buyer,
        uint bidIdx
    );

    event BidCanceled(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller, 
        address buyer,
        uint bidIdx
    );

    event BidRevoked(
        address nftContractAddress, 
        uint256 tokenId, 
        address seller, 
        address buyer, 
        uint bidIdx
    );

    event NftSold(
        address nftContractAddress, 
        uint256 tokenId,  
        address seller, 
        address buyer,
        uint fee,
        uint payAmount,
        address paymentToken,
        GhafMarketPlaceLib.BuyTypes buyType
    );

	// State-changing functions



    function setProtocolFee(uint _protocolFee) external;

    function setTreasury(address _treasury) external;


    function pause() external;

    function unpause() external;

	function listNft(
        address _nftContractAddress,
        uint256 _tokenId,
        GhafMarketPlaceLib.BuyTypes _buyType
	) external returns (bool);

    function delistNft(address _nftContractAddress,uint256 _tokenId) external returns (bool);

    function putBid(
        address _nftContractAddress, 
        uint256 _tokenId,
        uint _amount,
        address _paymentToken
    ) external payable returns (uint);

    function increaseBid(
        address _nftContractAddress, 
        uint256 _tokenId,
        uint _bidIdx,
        uint _newAmount
    ) external payable returns (bool);

    function cancelBid(
        address _nftContractAddress, 
        uint256 _tokenId,
        uint _bidIdx
    ) external returns (bool);

    function acceptBid(
        address _nftContractAddress, 
        uint256 _tokenId,
        uint _bidIdx
    ) external returns (bool);

    function buyNft(
        address _nftContractAddress, 
        uint256 _tokenId,
        uint _amount,
        address _paymentToken
    ) external payable returns (bool);
    

}
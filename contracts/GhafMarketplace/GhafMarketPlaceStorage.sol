// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.4;

import "./interfaces/IGhafMarketPlaceStorage.sol";

contract GhafMarketPlaceStorage is IGhafMarketPlaceStorage {

    address constant public NATIVE_TOKEN = address(1);
    uint constant public MAX_PROTOCOL_FEE = 100; // 100 = %100
    
    address public override treasury;
    uint public override protocolFee;
    
    mapping(address =>  mapping(uint => GhafMarketPlaceLib.Nft)) public nfts;
    // ^ Mapping from [_nftContractAddress][_tokenId] to a listed Nft
    mapping(address => mapping(uint => GhafMarketPlaceLib.Bid[])) public bids; 
    // ^ Mapping from [_nftContractAddress][_tokenId] to bids (note: it wasn't possible to define Bid[] in Nft)

}
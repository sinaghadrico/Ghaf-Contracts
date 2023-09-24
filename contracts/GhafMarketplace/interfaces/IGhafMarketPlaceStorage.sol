// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.4;

import "../GhafMarketPlaceLib.sol";

interface IGhafMarketPlaceStorage {

	// Read-only functions

    function protocolFee() external view returns (uint);

    function treasury() external view returns (address);

}
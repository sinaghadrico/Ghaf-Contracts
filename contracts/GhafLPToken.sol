// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GhafLPToken is ERC20 {
    address public owner;
    address public lpRewardDistribution;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _lpRewardDistribution
    ) ERC20(_name, _symbol) {
        owner = msg.sender;
        lpRewardDistribution = _lpRewardDistribution;
    }

    // Function to mint LP tokens, can only be called by the owner
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    // Function to distribute rewards to LP holders
    function distributeRewards(uint256 rewardAmount) external {
        require(msg.sender == lpRewardDistribution, "Only the LP reward distributor can call this function");
        require(rewardAmount > 0, "Reward amount must be greater than 0");

        uint256 totalSupply_ = totalSupply();

        if (totalSupply_ > 0) {
            for (uint256 i = 0; i < balanceOf(lpRewardDistribution); i++) {
                address lpHolder = tokenOfOwnerByIndex(lpRewardDistribution, i);
                uint256 lpShare = balanceOf(lpHolder) * rewardAmount / totalSupply_;
                _transfer(lpRewardDistribution, lpHolder, lpShare);
            }
        }
    }

    // Function to retrieve LP token holders by index
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(this, owner, index)))));
    }
}

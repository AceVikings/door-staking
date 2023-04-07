// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    struct stakeInfo {
        address token;
        uint amount;
    }

    mapping(address => bool) public tokenWhitelisted;
    mapping(address => mapping(address => uint256)) public userTokenBalance;
    bool public paused;

    function stake(stakeInfo[] calldata stake) external {
        require(!paused, "Staking paused");
        for (uint i = 0; i < stake.length; i++) {
            require(tokenWhitelisted[stake[i].token], "Token not whitelisted");
            IERC20(stake[i].token).transferFrom(
                msg.sender,
                address(this),
                stake[i].amount
            );
            userTokenBalance[msg.sender][stake[i].token] += stake[i].amount;
        }
    }

    function unStake(stakeInfo[] calldata stake) external {
        for (uint i = 0; i < stake.length; i++) {
            require(tokenWhitelisted[stake[i].token], "Token not whitelisted");
            userTokenBalance[msg.sender][stake[i].token] -= stake[i].amount;
            IERC20(stake[i].token).transfer(msg.sender, stake[i].amount);
        }
    }

    function whitelistToken(
        address _token,
        bool _whitelist
    ) external onlyOwner {
        tokenWhitelisted[_token] = _whitelist;
    }

    function pause(bool _pause) external onlyOwner {
        paused = _pause;
    }
}

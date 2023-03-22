// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import {ERC_NMultiBarter} from "../extensions/ERC_NMultiBarter.sol";

contract PermissionlessERC_NMultiBarter is ERC_NMultiBarter {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC_NMultiBarter(_name, _symbol) {}

    function mint(address account, uint256 tokenId) public {
        _mint(account, tokenId);
    }

    function enableBarterWith(address tokenAddr) public {
        _enableBarterWith(tokenAddr);
    }

    function stopBarterWith(address tokenAddr) public {
        _stopBarterWith(tokenAddr);
    }

    function domainSeparator() public view returns (bytes32) {
        return _domainSeparatorV4();
    }
}

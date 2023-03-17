// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import {ERCN} from "../ERCN.sol";

contract PermissionlessERCN is ERCN {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERCN(_name, _symbol) {}

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

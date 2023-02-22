// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {NST} from "src/NST.sol";

/// @title Mock implementation of NST without restriction
contract PermissiveNST is NST {
    constructor(string memory name, string memory symbol) NST(name, symbol) {}

    function mint(address account, uint256 tokenId) public {
        _mint(account, tokenId);
    }

    function allowNST(address tokenAddr) public {
        _allowExchangeWith(tokenAddr);
    }

    function banNST(address tokenAddr) public {
        _banExchangeWith(tokenAddr);
    }
}

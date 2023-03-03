// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {NST} from "src/NST.sol";

/// @title Mock implementation of NST without restriction
contract PermissiveNST is NST {
    uint256 private _lastTokenId;
    string private _ipfsGateway;
    string private _ipfsHash;

    constructor(
        string memory name,
        string memory symbol,
        string memory ipfsHash
    ) NST(name, symbol) {
        _ipfsGateway = "https://ipfs.io/ipfs/";
        _ipfsHash = ipfsHash;
    }

    function mint(address account) public {
        _mint(account, _lastTokenId++);
    }

    function mint(address account, uint256 tokenId) public {
        _mint(account, tokenId);
    }

    function allowNST(address tokenAddr) public {
        _allowExchangeWith(tokenAddr);
    }

    function banNST(address tokenAddr) public {
        _banExchangeWith(tokenAddr);
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return string.concat(_ipfsGateway, _ipfsHash);
    }

    function destruct() public {
        delete _ipfsGateway;
        delete _ipfsHash;
        selfdestruct(payable(msg.sender));
    }

    function setIpfsGateway(string memory ipfsGateway) external {
        _ipfsGateway = ipfsGateway;
    }
}

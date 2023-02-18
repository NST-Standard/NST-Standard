// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC721Enumerable, ERC721, IERC721} from "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

import {ITrade} from "./ITrade.sol";

contract Gift is ERC721, ITrade {
    using ECDSA for bytes32;

    address private _issuer;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function mint(uint256 tokenId) external {
        _mint(msg.sender, tokenId);
    }

    function trade(
        Trade memory _trade,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // readMessage no need to check only on transfer

        // digest data
        bytes32 structHash = keccak256(
            abi.encode(bytes32("type_hash"), keccak256(abi.encode(_trade)))
        );
        bytes32 typedDataHash = keccak256(
            abi.encodePacked("\x19\x01", bytes32("DS"), structHash)
        );

        // verify sig
        address sender = Gift(_trade.a.contractAddr).permit(_trade, v, r, s);

        Gift(_trade.a.contractAddr).transferFrom(
            _trade.b.to,
            msg.sender,
            _trade.a.tokenId
        );
        _transfer(msg.sender, sender, _trade.b.tokenId);
    }

    function permit(
        Trade memory _trade,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (address) {
        bytes32 structHash = keccak256(
            abi.encode(bytes32("type_hash"), keccak256(abi.encode(_trade)))
        );
        bytes32 typedDataHash = keccak256(
            abi.encodePacked("\x19\x01", bytes32("DS"), structHash)
        );

        // verify sig
        address sender = typedDataHash.recover(v, r, s);
        require(sender == _trade.b.to, "Sig not match");

        _setApprovalForAll(sender, msg.sender, true);

        return sender;
    }
}

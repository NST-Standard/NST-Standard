// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface ITrade {
    struct TradePart {
        address contractAddr;
        uint256 tokenId;
        address to;
    }

    struct Trade {
        TradePart a;
        TradePart b;
    }
}

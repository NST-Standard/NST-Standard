// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface INST {
    // --- events ---
    event TokenExchangeabilityUpdated(
        address indexed tokenAddr,
        bool indexed exchangeable
    );

    // --- errors ---
    error NotExchangeable(address tokenAddr);
    error InvalidSignatureOwner(address expectedOwner);

    // --- structs ---
    struct Token {
        address tokenAddr;
        uint256 tokenId;
        uint256 amount;
    }

    struct Tokens {
        address tokenAddr;
        uint256[] tokenIds;
        uint256[] amounts;
    }

    struct Message {
        address owner;
        uint256 nonce;
        // uint256 deadline
    }

    struct SingleExchange {
        Token bid;
        Token ask;
        Message message;
    }

    struct MultipleExchange {
        Tokens bid;
        Tokens ask;
        Message message;
    }

    // not tested => gas expensive
    struct ComposedExchange {
        Tokens[] bid;
        Tokens[] ask;
        Message message;
    }

    // --- getters ---
    function SINGLE_EXCHANGE_TYPEHASH() external view returns (bytes32);

    function MULTIPLE_EXCHANGE_TYPEHASH() external view returns (bytes32);

    function TOKEN_TYPEHASH() external view returns (bytes32);

    function TOKENS_TYPEHASH() external view returns (bytes32);

    function MESSAGE_TYPEHASH() external view returns (bytes32);

    function nonce(address account) external view returns (uint256);

    // --- methods ---
    function transferFor(
        SingleExchange memory exchangeData,
        address to,
        bytes memory signature
    ) external;

    function transferFor(
        MultipleExchange memory exchangeData,
        address to,
        bytes memory signature
    ) external;

    function exchange(
        SingleExchange memory exchangeData,
        bytes memory signature
    ) external;
}

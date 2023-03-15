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

interface IERC0000 {
    /**
     * @dev This emits when a token address barterable properties change
     * This emits when a new contract address is set as barterable (`barterable` == true)
     * and revoked (`barterable` == false)
     */
    event BarterNetworkUpdated(
        address indexed tokenAddr,
        bool indexed barterable
    );

    /**
     * @dev Structs containing barter terms can change depends on the
     * nature of the barter, but structs MUST be shared by both barter
     * parties.
     */
    struct BarterTerms {
        Componant bid;
        Componant ask;
        Message message;
    }

    struct Componant {
        address tokenAddr;
        uint256 tokenId;
        uint256 amount;
    }

    /**
     * @dev BarterTerms MUST always include a nonce to the message signed
     * to prevent a signature from being used multiple times
     */
    struct Message {
        address owner;
        uint256 nonce;
        uint48 deadline;
    }

    /**
     * @notice Counter of successful signed barter
     * @dev This value must be included whenever a signature
     * is generated for {transferFor}. Every successful call
     * to {transferFor} increases `account`'s nonce by one.
     * This prevents a signature from being used multiple times
     *
     * @param account address to query the actual nonce
     * @return nonce of the `account`
     */
    function nonce(address account) external view returns (uint256);

    /**
     * @param tokenAddr contract address to verify
     * @return true is `tokenAddr` is set as barterable
     */
    function isBarterable(address tokenAddr) external view returns (bool);

    /**
     * @notice Perform the bid transfer of the barter componant, MUST be
     * only called by the contract address included in the ask part of the
     * barter terms and this address MUST be allowed as a barterable contract
     * address
     * @dev call the internal method {_transfer} only if the result of the
     * `ecrecover` return the owner of the message or if approved by the token
     * owner. This function should increase the message owner nonce to prevents
     * a signature from being used multiple times
     *
     * @param data struct of the barter terms
     * @param to recipient address
     * @param signature signature of the hashed struct following EIP712
     */
    function transferFor(
        BarterTerms memory data,
        address to,
        bytes memory signature
    ) external;

    /**
     * @notice Call {transferFor} on the bid contract address (can be self) and
     * perform the ask transfer of the barter componant. the bid contract address
     * MUST be allowed as a barterable contract
     * @dev Call {transferFor} with the `msg.sender` or the token owner (case of
     * authorized operator).
     *
     * @param data struct of the barter terms
     * @param signature signature of the hashed struct following EIP712
     */
    function barter(BarterTerms memory data, bytes memory signature) external;
}

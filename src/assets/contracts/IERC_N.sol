// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface IERC_N {
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
     * @dev Represent one side the barter, here the minimal struct
     * information for a one-to-one ERC721 barter.
     */
    struct Componant {
        address tokenAddr;
        uint256 tokenId;
    }

    /**
     * @dev Aggregates informations about the barter, namely both side of the
     * barter represented by the {Componant} struct, and informations about the
     * signer.
     */
    struct BarterTerms {
        Componant bid;
        Componant ask;
        uint256 nonce;
        address owner;
        uint48 deadline;
    }

    /// @dev Typehash of the {BarterTerms} struct
    function BARTER_TERMS_TYPEHASH() external view returns (bytes32);

    /// @dev Typehash of the {Componant} struct
    function COMPONANT_TYPEHASH() external view returns (bytes32);

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

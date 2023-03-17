// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IPureBarter {
    /**
     * @dev Structs containing barter terms can change depends on the
     * nature of the barter, but structs MUST be shared by both barter
     * parties.
     */
    struct PureBarterTerms {
        Componant bid;
        Componant ask;
        address owner;
        uint256 nonce;
    }

    struct Componant {
        address tokenAddr;
        uint256 tokenId;
    }

    function PURE_BARTER_TERMS_TYPEHASH() external view returns (bytes32);

    function COMPONANT_TYPEHASH() external view returns (bytes32);

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
        PureBarterTerms memory data,
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
    function barter(
        PureBarterTerms memory data,
        bytes memory signature
    ) external;
}

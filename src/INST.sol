// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface INST {
    event TokenExchangeabilityUpdated(
        address indexed tokenAddr,
        bool indexed exchangeable
    );

    error NotExchangeable(address tokenAddr);
    error InvalidSignatureOwner(address expectedOwner);

    struct TransferInfo {
        address tokenAddr;
        uint256 tokenId;
        uint256 amount;
    }

    struct SignerInfo {
        address owner;
        // uint256 nonce
        // uint256 deadline
    }

    struct SingleExchangeInfo {
        TransferInfo given;
        TransferInfo asked;
        SignerInfo signerInfo;
    }

    struct MultipleExchangeInfo {
        TransferInfo[] given;
        TransferInfo[] asked;
        SignerInfo signerInfo;
    }

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function permit(
        SingleExchangeInfo memory exchangeMessage,
        bytes memory signature
    ) external returns (address);

    function exchange(
        SingleExchangeInfo memory exchangeMessage,
        bytes memory signature
    ) external;
}

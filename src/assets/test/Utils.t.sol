// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {IERCN, IPureBarter, IMultiBarter} from "../contracts/IERCN.sol";

contract Utils {
    bytes32 internal constant EIP712_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 internal constant COMPONANT_TYPEHASH =
        keccak256(
            abi.encodePacked("Componant(address tokenAddr,uint256 tokenId)")
        );
    bytes32 internal constant MULTI_COMPONANT_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "MultiComponant(address tokenAddr,uint256[] tokenIds)"
            )
        );
    bytes32 internal constant PURE_BARTER_TERMS_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "PureBarterTerms(Componant bid,Componant ask,address owner,uint256 nonce)Componant(address tokenAddr,uint256 tokenId)"
            )
        );
    bytes32 internal constant MULTI_BARTER_TERMS_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "MultiBarterTerms(MultiComponant bid,MultiComponant ask,address owner,uint256 nonce)MultiComponant(address tokenAddr,uint256[] tokenIds)"
            )
        );

    function workaround_EIP712TypedData(
        bytes32 structHash,
        string memory name,
        string memory version,
        address bidtokenAddr
    ) internal view returns (bytes32) {
        bytes32 domainSeparator = workaround_BuildDomainSeparator(
            name,
            version,
            bidtokenAddr
        );

        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }

    function workaround_BuildDomainSeparator(
        string memory name,
        string memory version,
        address verifyingContract
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_TYPEHASH, // typeHash
                    keccak256(abi.encodePacked(name)), // nameHash
                    keccak256(abi.encodePacked(version)), // versionHash
                    block.chainid,
                    verifyingContract
                )
            );
    }

    function workaround_CreatePureBarterTerms(
        address bidTokenAddr,
        uint256 bidTokenId,
        address askTokenAddr,
        uint256 askTokenId,
        address owner,
        uint256 nonce
    )
        internal
        pure
        returns (IPureBarter.PureBarterTerms memory data, bytes32 structHash)
    {
        IPureBarter.Componant memory bid = IPureBarter.Componant({
            tokenAddr: bidTokenAddr,
            tokenId: bidTokenId
        });
        IPureBarter.Componant memory ask = IPureBarter.Componant({
            tokenAddr: askTokenAddr,
            tokenId: askTokenId
        });
        data = IPureBarter.PureBarterTerms(bid, ask, owner, nonce);

        bytes32 bidStructHash = keccak256(
            abi.encode(COMPONANT_TYPEHASH, bidTokenAddr, bidTokenId)
        );
        bytes32 askStructHash = keccak256(
            abi.encode(COMPONANT_TYPEHASH, askTokenAddr, askTokenId)
        );
        structHash = keccak256(
            abi.encode(
                PURE_BARTER_TERMS_TYPEHASH,
                bidStructHash,
                askStructHash,
                owner,
                nonce
            )
        );
    }
}

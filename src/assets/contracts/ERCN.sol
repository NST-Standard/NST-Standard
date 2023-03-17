// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import {ERC721, IERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {EIP712} from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

import {IERCN} from "./IERCN.sol";

contract ERCN is ERC721, EIP712, IERCN {
    using ECDSA for bytes32;

    error BarterNotEnabled(address tokenAddr);
    error InvalidSignatureOwner(address expectedOwner);
    error NotOwnerNorApproved(address attempter, uint256 tokenId);

    /// @dev Hash of the message/struct to sign and send
    bytes32 public immutable override PURE_BARTER_TERMS_TYPEHASH;
    bytes32 public immutable override MULTI_BARTER_TERMS_TYPEHASH;
    bytes32 public immutable override COMPONANT_TYPEHASH;
    bytes32 public immutable override MULTI_COMPONANT_TYPEHASH;

    /// @dev Users nonces to protect against replay attack
    mapping(address => uint256) private _nonces;

    /// @dev keep track of allowed token which can be traded with this one
    mapping(address => bool) private _barterables;

    /// @dev allow only whitelisted token to call a function
    modifier onlyExchangeable(address tokenAddr) {
        if (!_barterables[tokenAddr]) revert BarterNotEnabled(tokenAddr);
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) EIP712(name_, "1") {
        // simples struct typehash
        COMPONANT_TYPEHASH = keccak256(
            abi.encodePacked("Componant(address tokenAddr,uint256 tokenId)")
        );
        MULTI_COMPONANT_TYPEHASH = keccak256(
            abi.encodePacked(
                "MultiComponant(address tokenAddr,uint256[] tokenIds)"
            )
        );
        PURE_BARTER_TERMS_TYPEHASH = keccak256(
            abi.encodePacked(
                "PureBarterTerms(Componant bid,Componant ask,address owner,uint256 nonce)Componant(address tokenAddr,uint256 tokenId)"
            )
        );
        MULTI_BARTER_TERMS_TYPEHASH = keccak256(
            abi.encodePacked(
                "MultiBarterTerms(MultiComponant bid,MultiComponant ask,address owner,uint256 nonce)MultiComponant(address tokenAddr,uint256[] tokenIds)"
            )
        );
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                              PUBLIC FUNCTIONS
    ////////////////////////////////////////////////////////////////////////////////////////////////*/
    /**
     * @notice See {IPureBarter}
     */
    function barter(
        PureBarterTerms memory data,
        bytes memory signature
    ) external onlyExchangeable(data.bid.tokenAddr) {
        IERCN(data.bid.tokenAddr).transferFor(data, msg.sender, signature);

        // transfer ask token
        if (!_isApprovedOrOwner(msg.sender, data.ask.tokenId))
            revert NotOwnerNorApproved(msg.sender, data.ask.tokenId);
        _transfer(msg.sender, data.owner, data.ask.tokenId);
    }

    /**
     * @notice See {IMultiBarter}
     */
    function barter(
        MultiBarterTerms memory data,
        bytes memory signature
    ) external onlyExchangeable(data.bid.tokenAddr) {
        IERCN(data.bid.tokenAddr).transferFor(data, msg.sender, signature);

        for (uint256 i; i < data.ask.tokenIds.length; ) {
            if (!_isApprovedOrOwner(data.owner, data.ask.tokenIds[i]))
                revert NotOwnerNorApproved(data.owner, data.ask.tokenIds[i]);
            _transfer(msg.sender, data.owner, data.ask.tokenIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice see {IPureBarter}
     */
    function transferFor(
        PureBarterTerms memory data,
        address to,
        bytes memory signature
    ) external onlyExchangeable(msg.sender) {
        // reconstruct the hash of signed message and use nonce
        bytes32 structHash = _hashPureBarterTerms(data);

        address signer = _checkMessageSignature(
            structHash,
            data.owner,
            signature
        );

        // transfer bid token
        if (!_isApprovedOrOwner(signer, data.bid.tokenId))
            revert NotOwnerNorApproved(signer, data.bid.tokenId);
        _transfer(data.owner, to, data.bid.tokenId);
    }

    function transferFor(
        MultiBarterTerms memory data,
        address to,
        bytes memory signature
    ) external onlyExchangeable(msg.sender) {
        // reconstruct the hash of signed message and use nonce
        bytes32 structHash = _hashMultiBarterTerms(data);

        address signer = _checkMessageSignature(
            structHash,
            data.owner,
            signature
        );

        for (uint256 i; i < data.bid.tokenIds.length; ) {
            if (!_isApprovedOrOwner(signer, data.bid.tokenIds[i]))
                revert NotOwnerNorApproved(signer, data.bid.tokenIds[i]);
            _transfer(data.owner, to, data.bid.tokenIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                                GETTERS
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    function nonce(address account) external view returns (uint256) {
        return _nonces[account];
    }

    function isBarterable(address tokenAddr) external view returns (bool) {
        return _barterables[tokenAddr];
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                  ERC721 - disable transfer functions
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    function transferFrom(address, address, uint256) public pure override {
        revert("Not implemented");
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert("Not implemented");
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override {
        revert("Not implemented");
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                          INTERNAL FUNCTIONS
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal function to implement for allowing transfer with
     * others NST.
     * Emit {BarterNetworkUpdated}
     * @param tokenAddr token address to approve
     */
    function _enableBarterWith(address tokenAddr) internal {
        _barterables[tokenAddr] = true;
        emit BarterNetworkUpdated(tokenAddr, true);
    }

    /**
     * @dev Internal function to implement for banning transfer with
     * others NST.
     * Emit {BarterNetworkUpdated}
     * @param tokenAddr token address to ban
     *
     */
    function _stopBarterWith(address tokenAddr) internal {
        _barterables[tokenAddr] = false;
        emit BarterNetworkUpdated(tokenAddr, false);
    }

    function _useNonce(address account) internal returns (uint256) {
        unchecked {
            return _nonces[account]++;
        }
    }

    function _checkMessageSignature(
        bytes32 structHash,
        address messageOwner,
        bytes memory signature
    ) internal view returns (address) {
        bytes32 typedDataHash = _hashTypedDataV4(structHash);

        // perform ecrecover and get signer address
        address signer = typedDataHash.recover(signature);
        if (signer != messageOwner) revert InvalidSignatureOwner(signer);
        return signer;
    }

    function _hashPureBarterTerms(
        PureBarterTerms memory data
    ) internal returns (bytes32) {
        bytes32 bidStructHash = keccak256(
            abi.encode(COMPONANT_TYPEHASH, data.bid.tokenAddr, data.bid.tokenId)
        );
        bytes32 askStructHash = keccak256(
            abi.encode(COMPONANT_TYPEHASH, data.ask.tokenAddr, data.ask.tokenId)
        );

        return
            keccak256(
                abi.encode(
                    PURE_BARTER_TERMS_TYPEHASH,
                    bidStructHash,
                    askStructHash,
                    data.owner,
                    _useNonce(data.owner)
                )
            );
    }

    function _hashMultiBarterTerms(
        MultiBarterTerms memory data
    ) internal returns (bytes32) {
        bytes32 bidStructHash = keccak256(
            abi.encode(
                MULTI_COMPONANT_TYPEHASH,
                data.bid.tokenAddr,
                data.bid.tokenIds // encode array?
            )
        );
        bytes32 askStructHash = keccak256(
            abi.encode(
                MULTI_COMPONANT_TYPEHASH,
                data.ask.tokenAddr,
                data.ask.tokenIds // encode array?
            )
        );

        return
            keccak256(
                abi.encode(
                    MULTI_BARTER_TERMS_TYPEHASH,
                    bidStructHash,
                    askStructHash,
                    data.owner,
                    _useNonce(data.owner)
                )
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC721, IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {EIP712} from "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import {INST} from "src/INST.sol";

/**
 * @title Implementation of NST by heriting full ERC721 contract
 *
 * @dev `permit` function is added to modify allowance following the
 * EIP-2612.
 * `exchange` is executed with a signature to perform two transfer into
 * one transaction
 *
 * NOTE SECURITY: add nonces and deadline to the message
 */
contract NST is ERC721, EIP712, INST {
    using ECDSA for bytes32;

    /// @dev Hash of the message/struct to sign and send
    bytes32 public immutable override SINGLE_EXCHANGE_TYPEHASH;
    bytes32 public immutable override MULTIPLE_EXCHANGE_TYPEHASH;
    bytes32 public immutable override TOKEN_TYPEHASH;
    bytes32 public immutable override TOKENS_TYPEHASH;
    bytes32 public immutable override MESSAGE_TYPEHASH;

    /// @dev Users nonces to protect against replay attack
    mapping(address => uint256) private _nonces;

    /// @dev keep track of allowed token which can be traded with this one
    mapping(address => bool) private _exchangeable;

    /// @dev allow only whitelisted token to call a function
    modifier onlyExchangeable(address tokenAddr) {
        if (!_exchangeable[tokenAddr]) revert NotExchangeable(tokenAddr);
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) EIP712(name_, "1") {
        // simples struct typehash
        TOKEN_TYPEHASH = keccak256(
            abi.encodePacked(
                "Token(address tokenAddr,uint256 tokenId,uint256 amount)"
            )
        );
        TOKENS_TYPEHASH = keccak256(
            abi.encodePacked(
                "Tokens(address tokenAddr,uint256[] tokenIds,uint256[] amounts)"
            )
        );
        MESSAGE_TYPEHASH = keccak256(
            abi.encodePacked("Message(address owner,uint256 nonce)")
        );

        // composed struct typehash
        SINGLE_EXCHANGE_TYPEHASH = keccak256(
            abi.encodePacked(
                "SingleExchange(Token bid,Token ask,Message message)Message(address owner,uint256 nonce)Token(address tokenAddr,uint256 tokenId,uint256 amount)"
            )
        );
        MULTIPLE_EXCHANGE_TYPEHASH = keccak256(
            abi.encodePacked(
                "MultipleExchange(Tokens bid,Tokens ask,Message message)Message(address owner,uint256 nonce)Tokens(address tokenAddr,uint256[] tokenIds,uint256[] amounts)"
            )
        );
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                      NST - approve exchange (follow EIP2612)
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Only callable by another "whitelisted" token
     * @dev Perform an `ecrecover` on the signature and (if valid) change
     * the token allowance
     *
     * @param data struct of the message
     * @param to recipient address
     * @param signature signature of the hashed struct following EIP712
     *
     * NOTE Only the owner of the signer message and the given token ID are
     * necessary for this function. The struct hash (or typed data hash) can be passed instead
     *
     * TODO This function should increase a `nonce` of user to avoid replay attack
     */

    function transferFor(
        SingleExchange memory data,
        address to,
        bytes memory signature
    ) external onlyExchangeable(msg.sender) {
        // reconstruct the hash of signed message and use nonce
        bytes32 structHash = _hashSimpleExchangeStruct(data);

        _checkMessageSignature(structHash, data.message.owner, signature);

        // transfer bid token
        _transfer(data.message.owner, to, data.bid.tokenId);
    }

    function transferFor(
        MultipleExchange memory data,
        address to,
        bytes memory signature
    ) external onlyExchangeable(msg.sender) {
        // reconstruct the hash of signed message and use nonce
        bytes32 structHash = _hashMultipleExchangeStruct(data);

        _checkMessageSignature(structHash, data.message.owner, signature);

        for (uint256 i; i < data.bid.tokenIds.length; ) {
            _transfer(data.message.owner, to, data.bid.tokenIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                        NST - execute exchange
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Allow users to perform an exchange of two NST
     * @dev Only the signature is checked for validity, then the contract
     * rely on ERC721 check on transfers.
     *
     * @param exchangeData struct of the message
     * @param signature signature of the hashed struct following EIP712
     */
    function exchange(
        SingleExchange memory exchangeData,
        bytes memory signature
    ) external onlyExchangeable(exchangeData.bid.tokenAddr) {
        INST(exchangeData.bid.tokenAddr).transferFor(
            exchangeData,
            msg.sender,
            signature
        );

        // transfer ask token
        _transfer(
            msg.sender,
            exchangeData.message.owner,
            exchangeData.ask.tokenId
        );
    }

    function exchange(
        MultipleExchange memory exchangeData,
        bytes memory signature
    ) external onlyExchangeable(exchangeData.bid.tokenAddr) {
        INST(exchangeData.bid.tokenAddr).transferFor(
            exchangeData,
            msg.sender,
            signature
        );

        for (uint256 i; i < exchangeData.ask.tokenIds.length; ) {
            _transfer(
                msg.sender,
                exchangeData.message.owner,
                exchangeData.ask.tokenIds[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function nonce(address account) external view returns (uint256) {
        return _nonces[account];
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                      ERC721 - restrict transfer functions
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /// @dev `onlyExchangeable` modifier prevent transferability outside an `exchange` call
    function transferFrom(address, address, uint256) public pure override {
        revert("Not implemented");
    }

    /// @dev `onlyExchangeable` modifier prevent transferability outside an `exchange` call
    function safeTransferFrom(address, address, uint256) public pure override {
        revert("Not implemented");
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                      NST - internal 
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal function to implement for allowing transfer with
     * others NST.
     * Emit {TokenExchangeabilityUpdated}
     * @param tokenAddr token address to approve
     *
     */
    function _allowExchangeWith(address tokenAddr) internal {
        _exchangeable[tokenAddr] = true;
        emit TokenExchangeabilityUpdated(tokenAddr, true);
    }

    /**
     * @dev Internal function to implement for banning transfer with
     * others NST.
     * Emit {TokenExchangeabilityUpdated}
     * @param tokenAddr token address to ban
     *
     */
    function _banExchangeWith(address tokenAddr) internal {
        _exchangeable[tokenAddr] = false;
        emit TokenExchangeabilityUpdated(tokenAddr, false);
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
    ) internal view {
        bytes32 typedDataHash = _hashTypedDataV4(structHash);

        // perform ecrecover and get signer address
        address signer = typedDataHash.recover(signature);
        if (signer != messageOwner) revert InvalidSignatureOwner(signer);
    }

    function _hashSimpleExchangeStruct(
        SingleExchange memory data
    ) internal returns (bytes32) {
        bytes32 bidStructHash = keccak256(
            abi.encode(
                TOKEN_TYPEHASH,
                data.bid.tokenAddr,
                data.bid.tokenId,
                data.bid.amount
            )
        );
        bytes32 askStructHash = keccak256(
            abi.encode(
                TOKEN_TYPEHASH,
                data.ask.tokenAddr,
                data.ask.tokenId,
                data.ask.amount
            )
        );
        bytes32 messageStructHash = keccak256(
            abi.encode(
                MESSAGE_TYPEHASH,
                data.message.owner,
                _useNonce(data.message.owner)
            )
        );

        return
            keccak256(
                abi.encode(
                    SINGLE_EXCHANGE_TYPEHASH,
                    bidStructHash,
                    askStructHash,
                    messageStructHash
                )
            );
    }

    function _hashMultipleExchangeStruct(
        MultipleExchange memory data
    ) internal returns (bytes32) {
        bytes32 bidStructHash = keccak256(
            abi.encode(
                TOKENS_TYPEHASH,
                data.bid.tokenAddr,
                data.bid.tokenIds, // encode array?
                data.bid.amounts
            )
        );
        bytes32 askStructHash = keccak256(
            abi.encode(
                TOKENS_TYPEHASH,
                data.ask.tokenAddr,
                data.ask.tokenIds,
                data.ask.amounts
            )
        );
        bytes32 messageStructHash = keccak256(
            abi.encode(
                MESSAGE_TYPEHASH,
                data.message.owner,
                _useNonce(data.message.owner)
            )
        );

        return
            keccak256(
                abi.encode(
                    MULTIPLE_EXCHANGE_TYPEHASH,
                    bidStructHash,
                    askStructHash,
                    messageStructHash
                )
            );
    }
}

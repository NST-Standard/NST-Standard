// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC721, IERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {EIP712} from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

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

    /// @dev keep track of allowed token which can be traded with this one
    mapping(address => bool) private _exchangeable;

    /// @dev Hash of the message/struct to sign and send
    bytes32 public immutable override PERMIT_TYPEHASH;

    /// @dev allow only whitelisted token to call a function
    modifier onlyExchangeable() {
        if (!_exchangeable[msg.sender]) revert NotExchangeable(msg.sender);
        _;
    }

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
        EIP712(name_, "1")
    {
        PERMIT_TYPEHASH = keccak256(
            "SingleExchangeInfo(TransferInfo given, TransferInfo asked, SignerInfo signerInfo)"
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
     * @param exchangeMessage struct of the message
     * @param signature signature of the hashed struct following EIP712
     *
     * NOTE Only the owner of the signer message and the given token ID are
     * necessary for this function. The struct hash (or typed data hash) can be passed instead
     *
     * TODO This function should increase a `nonce` of user to avoid replay attack
     */
    function permit(
        SingleExchangeInfo memory exchangeMessage,
        bytes memory signature
    ) external onlyExchangeable returns (address) {
        // reconstruct the hash of signed message
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, exchangeMessage)
        );
        bytes32 typedDataHash = _hashTypedDataV4(structHash);

        // perform ecrecover and get signer address
        address signer = typedDataHash.recover(signature);
        if (signer != exchangeMessage.signerInfo.owner)
            revert InvalidSignatureOwner(signer);

        // increase allowance for this tokenId
        _approve(msg.sender, exchangeMessage.given.tokenId);
        // emit Approval(ERC721.ownerOf(tokenId), to, tokenId); ?

        // This is not necessary as the signer is compared to the message owner
        return signer;
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                        NST - execute exchange
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Allow users to perform an exchange of two NST
     * @dev Only the signature is checked for validity, then the contract
     * rely on ERC721 check on transfers.
     *
     * @param exchangeMessage struct of the message
     * @param signature signature of the hashed struct following EIP712
     */
    function exchange(
        SingleExchangeInfo memory exchangeMessage,
        bytes memory signature
    ) external {
        address to = INST(exchangeMessage.given.tokenAddr).permit(
            exchangeMessage,
            signature
        );

        IERC721(exchangeMessage.given.tokenAddr).transferFrom(
            to,
            msg.sender,
            exchangeMessage.given.tokenId
        );
        _transfer(msg.sender, to, exchangeMessage.asked.tokenId);
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                      NST - internal exchangeable 
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal function to implement for allowing transfer with
     * others NST.
     * Emit {TokenExchangeabilityUpdated}
     * @param tokenAddr token address to approve
     * */
    function _allowExchangeWith(address tokenAddr) internal {
        _exchangeable[tokenAddr] = true;
        emit TokenExchangeabilityUpdated(tokenAddr, true);
    }

    /**
     * @dev Internal function to implement for banning transfer with
     * others NST.
     * Emit {TokenExchangeabilityUpdated}
     * @param tokenAddr token address to ban
     * */
    function _banExchangeWith(address tokenAddr) internal {
        _exchangeable[tokenAddr] = false;
        emit TokenExchangeabilityUpdated(tokenAddr, false);
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                      ERC721 - restrict transfer functions
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    /// @dev `onlyExchangeable` modifier prevent transferability outside an `exchange` call
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override onlyExchangeable {
        super.transferFrom(from, to, tokenId);
    }

    /// @dev `onlyExchangeable` modifier prevent transferability outside an `exchange` call
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override onlyExchangeable {
        super.safeTransferFrom(from, to, tokenId);
    }
}

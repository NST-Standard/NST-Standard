---
eip: 0000
title: Non sellable Tokens
description: An extension to SBTs to performing exchange/barter between authorised tokens, implemented at the contract level.
author: Cédric Nicolas (@cedric-n-icolas), Casey (@ ), Grégoire (@ ), Kerel Verwaerde (@NSTKerel), Matthieu Chassagne (@ ), Perrin (@pgrandne), Rafael Fitoussi (@fi2c), Raphael (@RaphaelHardFork), Virgil (@virgilea2410)
discussions-to: https://ethereum-magicians.org
status: Draft
type: Standards Track
category: ERC
created: 2023-03-15
requires: 165, 712, 721, (1271)
---

## Abstract

This EIP is an extensions of [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) to create non-sellable tokens (NST). It proposes a strong resriction on transfers in order to prevent speculation on token price while maintaining the possibility of transfers, transfers are performed in a barter way (send to receive or receive to send).

## Motivation

Interest for soulbound tokens (SBT) in the Ethereum community still growing since the V. Buterin [idea publication](https://vitalik.ca/general/2022/01/26/soulbound.html), highlighting the non-transferrability (non-)features to prevent, _in fine_, speculation of the token. While a lot of propositions emerged for implementation of SBT, the non-transferability is often too restrictive and requires a certain level of centralization, especially when users want to transfer a SBT between two owned accounts. Thus SBTs are way more fitted for account-bounded properties such as reputation, voting rights, privileges, ...

In case of transferable items which cannot be sellable (such as game items, gifts, discounts, ...), SBTs can fit but they require strong level of centralization as transfer are restricted by the token creator (or the community in case of DAO managed SBT).

NSTs propose a way to enforce users to perform barter of tokens between two authorized tokens in order to maintain a value equivalence in the exchange and so reduce the risk of speculation associated with an one way transfer. NSTs would provide a solution for transferring non-valuable tokens between projects based on their true value instead of their perceived/ speculated value without leveraging a third party.

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

All EIP-721 functions related to token transfer (excepted for mint and burn), namely `transferFrom` and `safeTransferFrom`, MUST be disabled or not implemented. Functions related to token allowances MAY be implemented to accept barter on behalf of approved account by the token owner and MUST be implemented following the same execution logic as the EIP721.

To perform a NST exchange, both token contracts MUST first approve each other (see Permisionless barter). Token owners carry out a barter as follow:

- a first token owner create and sign a message by taking up the terms of the barter following the [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md)
- a second token owner, if own the asked token of the signed message, accept and call the `barter` function on the asked token contract
- both transfers occurs in the above function method call

Terms of the barter is described in BarterTerms struct

### Contract interface

NST MUST implement the following interfaces:

- [EIP-165](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)'s `ERC165` (`0x01ffc9a7`)
- [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)'s:
  - `ERC721Metadata` (`0x5b5e139f`)
  - event `Transfer(address indexed,address indexed,uint256 indexed)`

NST MAY implement the following interfaces:

- `ERC721`, but MUST disable or remove following methods:
  - `safeTransferFrom(address,address,uint256,bytes)` (`0xb88d4fde`)
  - `safeTransferFrom(address,address,uint256)` (`0x42842e0e`)
  - `transferFrom(address,address,uint256)` (`0x23b872dd`)

The NST interface:

- MUST implement:

  - function `transferFor(BarterTerms memory,address,bytes memory)`
  - function `barter(BarterTerms memory,bytes memory)`
    Where `BarterTerms` is a set of arguments containing the terms of the barter (see BarterTerms struct)

- MAY implement:
  - event `BarterNetworkUpdated(address indexed,bool indexed)`
  - function `isBarterable(address)`
  - function `nonce(address)`

```solidity
// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.9;

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
    }

    /**
     * @dev BarterTerms MUST always include a nonce to the message signed
     * to prevent a signature from being used multiple times
     */
    struct Message {
        address owner;
        uint256 nonce;
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
```

Using [ECDSA.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol) (`v4.7.3` at least) and [EIP712.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol) library from OpenZeppelin is very RECOMMANDED for signature verifications, verification only based on `ecrecover` SHOULD NOT be used.

### Barter terms struct

As seen in the above interface the `BarterTerms` struct can be implemented in several way depending on the allowed barter type between NST. The struct SHOULD contain a maximum set of informations to prevent a misuse of the signed message.Both NST contracts MUST implement the same struct to perform a barter.

NST can implement several structs depending on allowed barter type, if any, functions `transferFor` and `barter` can leverage Solidity's [functions overloading](https://docs.soliditylang.org/en/latest/contracts.html#function-overloading) to implement the specific logic for each barter type.

The `BarterStruct` defined in the above interface is used to perform one-to-one barter, thus this struct can be extended by adding or replacing following struct members:

- `uint256 amount` when working with an `ERC1155`

```solidity
struct Componant {
    address tokenAddr;
    uint256 tokenId;
    uint256 amount;
}
```

- `uint256[] tokenIds` for multiple tokens barter

```solidity
struct Componant {
    address tokenAddr;
    uint256[] tokenIds;
}
```

- `uint48 deadline` for expirable barter propositions

```solidity
struct Message {
    address owner;
    uint256 nonce;
    uint48 deadline;
}
```

## Rationale [WIP]

Research paths explorer to solve NST and propose this EIP

### Permissionless barter

#### Fully permissionless

With the fully ownership of the token and the maximum of decentralization in mind, preventing the sellability of a token without enforce restriction on the transfer was very hard and falling into complex, highly centralized solution and with poor interoperability. Instead we leveraging game theory to enforce transfer with a counter party.

But allowing any couterparty implies into a barter fall back into a classic transfer as any NST could be exchangeable to any other NST, even fake NST contract to perform a one way exchange. So we assume to keep NST barter into only allowed NST list, list which can be managed by multisig or DAO.

By maintaining this list at the contract level, a network of barterable NST can be created. So even if the transfer is possible between NSTs, strong couterparty at the transfer and restriction at the contract level made NSTs fully illiquid to be selled into a marketplace or by OTC agreement.

#### One way permissionless

Leaving the asked NST contract without restriction of calling the `barter` function for a non-allowed contract would open the risk of barter of non equivalent token.

Thus by allowing a new NST contract attention must be paid on the implementation of the contract

### Multi NST contract barter

As the barterable network is set at the contract level, performing a barter implies to have signature of the both part and verify one signature for on token.

### Register of allowed NST

Managed by a DAO, NST network better...

### Third party protocol

Implement as a protocol for NFT swap like [Sudoswap](https://otc.sudoswap.xyz/#/create), still have EIP721 properties.

### "Barter" word choice

see [NFT word choice](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md#rationale)

### "NST" word choice

### Work from a minimal ERC721 interface

This still allow to rely on `Transfer` event and `allowances` features and maintaining a fully backward compability.

## Backwards Compatibility

This proposal is fully backward compatible with [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)

## Test Cases

(Link to reference implementation test suite.) Written using Foundry

## Reference Implementation

Link to the minimal implementation contracts (can be the same as Test Cast)

## Security Considerations

Front runnning attack when not specifying the tokenID (must be included in rational?)

Or leave:

Needs discussion.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).

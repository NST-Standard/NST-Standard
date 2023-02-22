// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PermissiveNST} from "test/base/MockNST.sol";

import {NST, INST} from "src/NST.sol";

contract NST_test is Test {
    // contracts
    PermissiveNST internal ticket;
    PermissiveNST internal discount;
    address internal TICKET;
    address internal DISCOUNT;

    // roles
    address internal constant OWNER = address(501);
    address internal USER1 = vm.addr(0x123);
    address internal USER2 = vm.addr(0xABC);

    // hash
    bytes32 internal constant TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 internal PERMIT_TYPEHASH;

    function setUp() public {
        // deploy two NST contracts
        ticket = new PermissiveNST("Ticket", "TCK");
        discount = new PermissiveNST("Discount", "D");
        TICKET = address(ticket);
        DISCOUNT = address(discount);

        PERMIT_TYPEHASH = ticket.PERMIT_TYPEHASH();

        // mint one token to both users
        ticket.mint(USER1, 100); // tokenId = 100
        discount.mint(USER2, 79);

        // "whitelist" token
        ticket.allowNST(DISCOUNT);
        discount.allowNST(TICKET);
    }

    function test_exchange_RealizeOneExchange() public {
        // USER1 create the trade message
        INST.SingleExchangeInfo
            memory exchangeMessage = workaround_CreateSingleExchangeInfo({
                givenTokenAddr: TICKET,
                givenTokenId: 100,
                givenAmount: 1,
                askedTokenAddr: DISCOUNT,
                askedTokenId: 79,
                askedAmount: 1,
                owner: USER1
            });

        // USER1 create the message digest to sign
        bytes32 typedDataHash = workaround_EIP712TypedData(exchangeMessage);

        // USER1 sign with his private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x123, typedDataHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        // USER2 take the message and the signature and execute the exchange
        vm.prank(USER2);
        discount.exchange(exchangeMessage, signature);

        // transfers has been done
        assertEq(ticket.ownerOf(100), USER2);
        assertEq(discount.ownerOf(79), USER1);
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                                WORKAROUNDS
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    function workaround_CreateSingleExchangeInfo(
        address givenTokenAddr,
        uint256 givenTokenId,
        uint256 givenAmount,
        address askedTokenAddr,
        uint256 askedTokenId,
        uint256 askedAmount,
        address owner
    ) internal pure returns (INST.SingleExchangeInfo memory) {
        INST.TransferInfo memory toGive = INST.TransferInfo({
            tokenAddr: givenTokenAddr,
            tokenId: givenTokenId,
            amount: givenAmount
        });

        INST.TransferInfo memory toAsk = INST.TransferInfo({
            tokenAddr: askedTokenAddr,
            tokenId: askedTokenId,
            amount: askedAmount
        });

        INST.SignerInfo memory signerInfo = INST.SignerInfo({owner: owner});

        return
            INST.SingleExchangeInfo({
                given: toGive,
                asked: toAsk,
                signerInfo: signerInfo
            });
    }

    function workaround_EIP712TypedData(
        INST.SingleExchangeInfo memory exchangeMessage
    ) internal view returns (bytes32) {
        // create digest of the message
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, exchangeMessage)
        );

        // get the domain separator (unique for each NST contract)
        bytes32 domainSeparator = workaround_BuildDomainSeparator(
            NST(exchangeMessage.given.tokenAddr)
        );

        // digest of the typed data
        // EIP712::_hashTypedDataV4(bytes32 structHash) => ECDSA::toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }

    function workaround_BuildDomainSeparator(NST token)
        internal
        view
        returns (bytes32)
    {
        // EIP712::_buildDomainSeparator(bytes32 typeHash, bytes32 nameHash, bytes32 versionHash)
        return
            keccak256(
                abi.encode(
                    TYPE_HASH, // typeHash
                    keccak256(abi.encodePacked(token.name())), // nameHash
                    keccak256("1"), // versionHash
                    block.chainid,
                    address(token)
                )
            );
    }
}

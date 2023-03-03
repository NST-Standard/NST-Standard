// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PermissiveNST} from "src/mocks/PermissiveNST.sol";

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
    bytes32 internal constant EIP712_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    function setUp() public {
        // deploy two NST contracts
        ticket = new PermissiveNST("Ticket", "TCK", "ipfs://{...}");
        discount = new PermissiveNST("Discount", "D", "ipfs://{...}");
        TICKET = address(ticket);
        DISCOUNT = address(discount);

        // mint one token to both users
        ticket.mint(USER1, 100); // tokenId = 100
        discount.mint(USER2, 79);

        // "whitelist" token
        ticket.allowNST(DISCOUNT);
        discount.allowNST(TICKET);

        // label address
        vm.label(TICKET, "TICKET");
        vm.label(DISCOUNT, "DISCOUNT");
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
    }

    function test_exchange_RealizeOneExchange() public {
        // USER1 create the trade message
        (
            INST.SingleExchange memory exchangeData,
            bytes32 structHash
        ) = workaround_CreateSingleExchangeStruct({
                givenTokenAddr: TICKET,
                givenTokenId: 100,
                givenAmount: 1,
                askedTokenAddr: DISCOUNT,
                askedTokenId: 79,
                askedAmount: 1,
                owner: USER1,
                nonce: ticket.nonce(USER1)
            });

        // USER1 create the message digest to sign
        bytes32 typedDataHash = workaround_EIP712TypedData(structHash, TICKET);

        // USER1 sign with his private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x123, typedDataHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        // USER2 take the message and the signature and execute the exchange
        vm.prank(USER2);
        discount.exchange(exchangeData, signature);

        // transfers has been done
        assertEq(ticket.ownerOf(100), USER2);
        assertEq(discount.ownerOf(79), USER1);
    }

    function test_exchange_MultipleTokenExchange() public {
        // mint tokens
        ticket.mint(USER1, 34);
        ticket.mint(USER1, 99);
        ticket.mint(USER1, 51);
        discount.mint(USER2, 12);
        discount.mint(USER2, 13);
        discount.mint(USER2, 78);
        discount.mint(USER2, 1000);

        // create message
        uint256[] memory bidTokenIds = new uint256[](2);
        bidTokenIds[0] = 34;
        bidTokenIds[1] = 100;
        uint256[] memory askTokenIds = new uint256[](4);
        askTokenIds[0] = 12;
        askTokenIds[1] = 13;
        askTokenIds[2] = 78;
        askTokenIds[3] = 79;
        uint256[] memory amounts; //  not used with ERC721
        (
            INST.MultipleExchange memory exchangeData,
            bytes32 structHash
        ) = workaround_CreateMultipleExchangeStruct({
                givenTokenAddr: TICKET,
                givenTokenId: bidTokenIds,
                givenAmount: amounts,
                askedTokenAddr: DISCOUNT,
                askedTokenId: askTokenIds,
                askedAmount: amounts,
                owner: USER1,
                nonce: ticket.nonce(USER1)
            });

        // sign message
        bytes32 typedDataHash = workaround_EIP712TypedData(structHash, TICKET);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x123, typedDataHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        // execute exchange
        vm.prank(USER2);
        discount.exchange(exchangeData, signature);

        assertEq(ticket.ownerOf(34), USER2);
        assertEq(ticket.ownerOf(100), USER2);
        assertEq(ticket.ownerOf(99), USER1);
        assertEq(ticket.ownerOf(51), USER1);
        assertEq(discount.ownerOf(12), USER1);
        assertEq(discount.ownerOf(13), USER1);
        assertEq(discount.ownerOf(78), USER1);
        assertEq(discount.ownerOf(79), USER1);
        assertEq(discount.ownerOf(1000), USER2);
    }

    function test_exchange_CannotReuseMessage() public {
        (
            INST.SingleExchange memory exchangeData,
            bytes32 structHash
        ) = workaround_CreateSingleExchangeStruct({
                givenTokenAddr: TICKET,
                givenTokenId: 100,
                givenAmount: 1,
                askedTokenAddr: DISCOUNT,
                askedTokenId: 79,
                askedAmount: 1,
                owner: USER1,
                nonce: ticket.nonce(USER1)
            });

        // USER1 create the message digest to sign
        bytes32 typedDataHash = workaround_EIP712TypedData(structHash, TICKET);

        // USER1 sign with his private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x123, typedDataHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));
        vm.prank(USER2);
        discount.exchange(exchangeData, signature);

        // transfers has been done
        assertEq(ticket.ownerOf(100), USER2);
        assertEq(discount.ownerOf(79), USER1);

        // reverse exchange
        (
            INST.SingleExchange memory exchangeDataReverse,
            bytes32 structHashReverse
        ) = workaround_CreateSingleExchangeStruct({
                givenTokenAddr: DISCOUNT,
                givenTokenId: 79,
                givenAmount: 1,
                askedTokenAddr: TICKET,
                askedTokenId: 100,
                askedAmount: 1,
                owner: USER1,
                nonce: discount.nonce(USER1)
            });
        typedDataHash = workaround_EIP712TypedData(structHashReverse, DISCOUNT);
        (v, r, s) = vm.sign(0x123, typedDataHash);
        bytes memory signatureReverse = bytes.concat(r, s, bytes1(v));

        vm.prank(USER2);
        ticket.exchange(exchangeDataReverse, signatureReverse);

        // initiale state
        assertEq(ticket.ownerOf(100), USER1);
        assertEq(discount.ownerOf(79), USER2);

        // USER2 try to reuse the first message and signature
        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature(
                "InvalidSignatureOwner(address)",
                0x8aF92cF9B3DDf78Ba4B399530515FdF49b6c03f3 // another address recovered
                // because the nonce has been incremented from 0 to 1
            )
        );
        discount.exchange(exchangeData, signature);
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                                WORKAROUNDS
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    function workaround_CreateSingleExchangeStruct(
        address givenTokenAddr,
        uint256 givenTokenId,
        uint256 givenAmount,
        address askedTokenAddr,
        uint256 askedTokenId,
        uint256 askedAmount,
        address owner,
        uint256 nonce
    )
        internal
        view
        returns (INST.SingleExchange memory exchangeData, bytes32 structHash)
    {
        INST.Token memory bid = INST.Token({
            tokenAddr: givenTokenAddr,
            tokenId: givenTokenId,
            amount: givenAmount
        });

        INST.Token memory ask = INST.Token({
            tokenAddr: askedTokenAddr,
            tokenId: askedTokenId,
            amount: askedAmount
        });

        INST.Message memory message = INST.Message(owner, nonce);

        exchangeData = INST.SingleExchange(bid, ask, message);
        structHash = keccak256(
            abi.encode(
                ticket.SINGLE_EXCHANGE_TYPEHASH(),
                bid,
                ask,
                owner,
                nonce
            )
        );
    }

    function workaround_CreateMultipleExchangeStruct(
        address givenTokenAddr,
        uint256[] memory givenTokenId,
        uint256[] memory givenAmount,
        address askedTokenAddr,
        uint256[] memory askedTokenId,
        uint256[] memory askedAmount,
        address owner,
        uint256 nonce
    )
        internal
        view
        returns (INST.MultipleExchange memory exchangeData, bytes32 structHash)
    {
        INST.Tokens memory bid = INST.Tokens({
            tokenAddr: givenTokenAddr,
            tokenIds: givenTokenId,
            amounts: givenAmount
        });

        INST.Tokens memory ask = INST.Tokens({
            tokenAddr: askedTokenAddr,
            tokenIds: askedTokenId,
            amounts: askedAmount
        });

        INST.Message memory message = INST.Message(owner, nonce);

        exchangeData = INST.MultipleExchange(bid, ask, message);
        structHash = keccak256(
            abi.encode(
                ticket.MULTIPLE_EXCHANGE_TYPEHASH(),
                bid,
                ask,
                owner,
                nonce
            )
        );
    }

    function workaround_EIP712TypedData(
        bytes32 structHash,
        address bidtokenAddr
    ) internal view returns (bytes32) {
        // get the domain separator (unique for each NST contract)
        bytes32 domainSeparator = workaround_BuildDomainSeparator(
            NST(bidtokenAddr)
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
                    EIP712_TYPEHASH, // typeHash
                    keccak256(abi.encodePacked(token.name())), // nameHash
                    keccak256("1"), // versionHash
                    block.chainid,
                    address(token)
                )
            );
    }
}

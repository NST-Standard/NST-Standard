// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {Utils} from "./Utils.t.sol";
import {PermissionlessERCN} from "../contracts/mocks/PermissionlessERCN.sol";
import {ERCN} from "../contracts/ERCN.sol";
import {IERCN} from "../contracts/IERCN.sol";

contract ERCN_test is Test, Utils {
    using stdStorage for StdStorage;

    // tokens
    PermissionlessERCN internal ticket;
    address internal TICKET;
    PermissionlessERCN internal discount;
    address internal DISCOUNT;

    // users and their private keys
    uint256 internal constant USER1_PK = 0x111;
    uint256 internal constant USER2_PK = 0x222;
    uint256 internal constant USER3_PK = 0x333;
    uint256 internal constant USER4_PK = 0x444;
    address internal USER1 = vm.addr(USER1_PK);
    address internal USER2 = vm.addr(USER2_PK);
    address internal USER3 = vm.addr(USER3_PK);
    address internal USER4 = vm.addr(USER4_PK);

    function setUp() public {
        // deploy tokens
        ticket = new PermissionlessERCN("Ticket", "00");
        TICKET = address(ticket);
        discount = new PermissionlessERCN("Discount", "01");
        DISCOUNT = address(discount);

        // enable barters
        ticket.enableBarterWith(DISCOUNT);
        discount.enableBarterWith(TICKET);

        // label address
        vm.label(TICKET, "TICKET");
        vm.label(DISCOUNT, "DISCOUNT");
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
        vm.label(USER3, "USER3");
        vm.label(USER4, "USER4");
    }

    function test_constructor_SetDomainSeparators() public {
        assertEq(
            ticket.domainSeparator(),
            workaround_BuildDomainSeparator("Ticket", "1", TICKET)
        );
        assertEq(
            discount.domainSeparator(),
            workaround_BuildDomainSeparator("Discount", "1", DISCOUNT)
        );
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                              TEST CASES
    ////////////////////////////////////////////////////////////////////////////////////////////////*/

    function test_barter_OneToOneBarter() public {
        ticket.mint(USER1, 25);
        discount.mint(USER2, 12);

        (
            IERCN.PureBarterTerms memory data,
            bytes memory signature
        ) = workaround_User1Ask(DISCOUNT, 12);

        assertEq(ticket.ownerOf(25), USER1);
        assertEq(discount.ownerOf(12), USER2);

        vm.prank(USER2);
        discount.barter(data, signature);

        assertEq(ticket.ownerOf(25), USER2);
        assertEq(discount.ownerOf(12), USER1);
    }

    function test_barter_RevertBartersNotAllowed() public {
        ticket.mint(USER1, 25);
        discount.mint(USER2, 12);

        (
            IERCN.PureBarterTerms memory data,
            bytes memory signature
        ) = workaround_User1Ask(DISCOUNT, 12);

        // one way
        ticket.stopBarterWith(DISCOUNT);
        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature("BarterNotEnabled(address)", DISCOUNT)
        );
        discount.barter(data, signature);

        // other way
        discount.stopBarterWith(TICKET);
        ticket.enableBarterWith(DISCOUNT);
        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature("BarterNotEnabled(address)", TICKET)
        );
        discount.barter(data, signature);

        // both
        ticket.stopBarterWith(DISCOUNT);
        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature("BarterNotEnabled(address)", TICKET)
        );
        discount.barter(data, signature);
    }

    function test_barter_EnableBarterOnSameContractIsRequired() public {
        ticket.mint(USER1, 25);
        ticket.mint(USER2, 50);

        (
            IERCN.PureBarterTerms memory data,
            bytes memory signature
        ) = workaround_User1Ask(TICKET, 50);

        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature("BarterNotEnabled(address)", TICKET)
        );
        ticket.barter(data, signature);
    }

    function test_barter_BarterOnSameContract() public {
        ticket.mint(USER1, 25);
        ticket.mint(USER2, 50);
        ticket.enableBarterWith(TICKET);

        (
            IERCN.PureBarterTerms memory data,
            bytes memory signature
        ) = workaround_User1Ask(TICKET, 50);

        vm.prank(USER2);
        ticket.barter(data, signature);

        assertEq(ticket.ownerOf(25), USER2);
        assertEq(ticket.ownerOf(50), USER1);
    }

    function test_barter_NoncePreventSignatureReuse() public {
        ticket.mint(USER1, 25);
        discount.mint(USER2, 12);

        (
            IERCN.PureBarterTerms memory data,
            bytes memory signature
        ) = workaround_User1Ask(DISCOUNT, 12);

        // execute the barter
        vm.prank(USER2);
        discount.barter(data, signature);
        assertEq(ticket.ownerOf(25), USER2);
        assertEq(discount.ownerOf(12), USER1);

        // rollback last barter with cheats
        stdstore
            .target(TICKET)
            .sig("ownerOf(uint256)")
            .with_key(25)
            .checked_write(USER1);
        stdstore
            .target(DISCOUNT)
            .sig("ownerOf(uint256)")
            .with_key(12)
            .checked_write(USER2);
        assertEq(ticket.ownerOf(25), USER1);
        assertEq(discount.ownerOf(12), USER2);

        // try a new barter
        vm.prank(USER2);
        vm.expectRevert(
            abi.encodeWithSignature(
                "InvalidSignatureOwner(address)",
                0x658A6BeB176F50Bed0F6D5ea0e7d80e24C6Dd8A8 // unpredictable
            )
        );
        discount.barter(data, signature);
    }

    /*////////////////////////////////////////////////////////////////////////////////////////////////
                                              WORKAROUND
    ////////////////////////////////////////////////////////////////////////////////////////////////*/
    function workaround_User1Ask(
        address tokenAddr,
        uint256 tokenId
    ) internal view returns (IERCN.PureBarterTerms memory, bytes memory) {
        (
            IERCN.PureBarterTerms memory data,
            bytes32 structHash
        ) = workaround_CreatePureBarterTerms({
                bidTokenAddr: TICKET,
                bidTokenId: 25,
                askTokenAddr: tokenAddr,
                askTokenId: tokenId,
                owner: USER1,
                nonce: ticket.nonce(USER1)
            });

        bytes32 typedDataHash = workaround_EIP712TypedData(
            structHash,
            ticket.name(),
            "1",
            TICKET
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(USER1_PK, typedDataHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        return (data, signature);
    }
}

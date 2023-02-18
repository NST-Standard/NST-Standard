// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {Gift, ITrade} from "src/Gift.sol";

contract Gift_Test is Test {
    Gift internal a;
    Gift internal b;
    address internal A;
    address internal B;

    uint256 internal constant alicePrivateKey = 0xA11CE;
    uint256 internal constant bobPrivateKey = 0xB0B;
    address internal ALICE;
    address internal BOB;

    function setUp() public {
        a = new Gift("Gift A", "A");
        b = new Gift("Gift B", "B");

        ALICE = vm.addr(alicePrivateKey);
        BOB = vm.addr(bobPrivateKey);

        vm.prank(ALICE);
        a.mint(5);
        vm.prank(BOB);
        b.mint(10);
    }

    function test_transfer_in_one_tx() public {
        assertEq(a.balanceOf(ALICE), 1);
        assertEq(a.balanceOf(BOB), 0);
        assertEq(b.balanceOf(ALICE), 0);
        assertEq(b.balanceOf(BOB), 1);

        // create the trade from Alice
        ITrade.TradePart memory alicePart = ITrade.TradePart(
            address(a),
            5,
            BOB
        );
        ITrade.TradePart memory bobPart = ITrade.TradePart(
            address(b),
            10,
            ALICE
        );
        ITrade.Trade memory trade = ITrade.Trade(alicePart, bobPart);

        // sign following EIP712
        bytes32 structHash = keccak256(
            abi.encode(bytes32("type_hash"), keccak256(abi.encode(trade)))
        );
        bytes32 typedDataHash = keccak256(
            abi.encodePacked("\x19\x01", bytes32("DS"), structHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            alicePrivateKey,
            typedDataHash
        );

        // bob execute the trade
        vm.prank(BOB);
        b.trade(trade, v, r, s);

        assertEq(a.balanceOf(ALICE), 0);
        assertEq(a.balanceOf(BOB), 1);
        assertEq(b.balanceOf(ALICE), 1);
        assertEq(b.balanceOf(BOB), 0);
    }
}

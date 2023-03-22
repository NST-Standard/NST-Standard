// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";

// import {PermissiveNST} from "src/mocks/PermissiveNST.sol";
// import {INST} from "src/INST.sol";

contract exchange is Script {
    // INST private inst;
    address private DEPLOYER;
    uint256 private ANVIL1_PK =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address private ANVIL1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    bytes32 internal constant EIP712_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes private signature =
        hex"29a0e227e55d19cffa1ca37ee183c5977d42ccca85a7db289f8e1d4aaebca951124a07e04406ad61b524995d1e2beed93d4a5621c2f4af31abcd61a3bd556fbe1b";

    function run() public {
        // import `.env` private key
        uint256 pk = vm.envUint("DEPLOYER_ANVIL");
        DEPLOYER = vm.addr(pk);

        vm.startBroadcast(pk);

        // console.log(block.chainid);
        // console.log(vm.addr(ANVIL1_PK));

        // PermissiveNST smokeBond = PermissiveNST(
        //     0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
        // );
        // inst = INST(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);

        // INST.Token memory bid = INST.Token({
        //     tokenAddr: 0x5FbDB2315678afecb367f032d93F642f64180aa3,
        //     tokenId: 0,
        //     amount: 1
        // });
        // INST.Token memory ask = INST.Token({
        //     tokenAddr: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0,
        //     tokenId: 1,
        //     amount: 1
        // });
        // INST.Message memory message = INST.Message({owner: ANVIL1, nonce: 0});
        // INST.SingleExchange memory exchangeData = INST.SingleExchange(
        //     bid,
        //     ask,
        //     message
        // );

        // // manual signature
        // (
        //     INST.SingleExchange memory exchangeDataStruct,
        //     bytes32 structHash
        // ) = workaround_CreateSingleExchangeStruct(
        //         0x5FbDB2315678afecb367f032d93F642f64180aa3,
        //         0,
        //         1,
        //         0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0,
        //         1,
        //         1,
        //         ANVIL1,
        //         0
        //     );
        // string memory name = PermissiveNST(
        //     0x5FbDB2315678afecb367f032d93F642f64180aa3
        // ).name();

        // bytes32 hashToSign = workaround_EIP712TypedData(
        //     structHash,
        //     0x5FbDB2315678afecb367f032d93F642f64180aa3,
        //     name
        // );
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(ANVIL1_PK, hashToSign);
        // bytes memory signature2 = bytes.concat(r, s, bytes1(v));

        // console2.logBytes(signature2);

        // smokeBond.exchange(exchangeData, signature);

        vm.stopBroadcast();
    }

    // function workaround_CreateSingleExchangeStruct(
    //     address givenTokenAddr,
    //     uint256 givenTokenId,
    //     uint256 givenAmount,
    //     address askedTokenAddr,
    //     uint256 askedTokenId,
    //     uint256 askedAmount,
    //     address owner,
    //     uint256 nonce
    // )
    //     internal
    //     view
    //     returns (INST.SingleExchange memory exchangeData, bytes32 structHash)
    // {
    //     INST.Token memory bid = INST.Token({
    //         tokenAddr: givenTokenAddr,
    //         tokenId: givenTokenId,
    //         amount: givenAmount
    //     });
    //     bytes32 bidStructHash = keccak256(
    //         abi.encode(
    //             inst.TOKEN_TYPEHASH(),
    //             givenTokenAddr,
    //             givenTokenId,
    //             givenAmount
    //         )
    //     );
    //     INST.Token memory ask = INST.Token({
    //         tokenAddr: askedTokenAddr,
    //         tokenId: askedTokenId,
    //         amount: askedAmount
    //     });
    //     bytes32 askStructHash = keccak256(
    //         abi.encode(
    //             inst.TOKEN_TYPEHASH(),
    //             askedTokenAddr,
    //             askedTokenId,
    //             askedAmount
    //         )
    //     );
    //     INST.Message memory message = INST.Message(owner, nonce);
    //     bytes32 messageStructHash = keccak256(
    //         abi.encode(inst.MESSAGE_TYPEHASH(), owner, nonce)
    //     );

    //     exchangeData = INST.SingleExchange(bid, ask, message);
    //     structHash = keccak256(
    //         abi.encode(
    //             inst.SINGLE_EXCHANGE_TYPEHASH(),
    //             bidStructHash,
    //             askStructHash,
    //             messageStructHash
    //         )
    //     );
    // }

    // function workaround_EIP712TypedData(
    //     bytes32 structHash,
    //     address bidTokenAddr,
    //     string memory name
    // ) internal view returns (bytes32) {
    //     // get the domain separator (unique for each NST contract)
    //     bytes32 domainSeparator = workaround_BuildDomainSeparator(
    //         name,
    //         bidTokenAddr
    //     );

    //     // digest of the typed data
    //     // EIP712::_hashTypedDataV4(bytes32 structHash) => ECDSA::toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
    //     return
    //         keccak256(
    //             abi.encodePacked("\x19\x01", domainSeparator, structHash)
    //         );
    // }

    // function workaround_BuildDomainSeparator(
    //     string memory name,
    //     address bidTokenAddr
    // ) internal view returns (bytes32) {
    //     // EIP712::_buildDomainSeparator(bytes32 typeHash, bytes32 nameHash, bytes32 versionHash)
    //     return
    //         keccak256(
    //             abi.encode(
    //                 EIP712_TYPEHASH, // typeHash
    //                 name, // keccak256(abi.encodePacked(name)), // nameHash
    //                 "1", //  keccak256("1"), // versionHash
    //                 block.chainid,
    //                 bidTokenAddr
    //             )
    //         );
    // }
}

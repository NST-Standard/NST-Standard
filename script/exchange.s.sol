// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract exchange is Script {
    address private DEPLOYER;

    function run() public {
        // import `.env` private key
        uint256 pk = vm.envUint("DEPLOYER_GOERLI");
        DEPLOYER = vm.addr(pk);

        vm.startBroadcast(pk);

        console.log(DEPLOYER.balance);

        vm.stopBroadcast();
    }
}

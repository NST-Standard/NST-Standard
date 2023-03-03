// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PermissiveNST} from "src/mocks/PermissiveNST.sol";

contract deploy is Script {
    address private DEPLOYER;

    function run() public {
        // import `.env` private key
        uint256 pk = vm.envUint("DEPLOYER_GOERLI");
        DEPLOYER = vm.addr(pk);

        _logsDeploymentEnvironment();

        vm.startBroadcast(pk);

        PermissiveNST supportTicket = new PermissiveNST(
            "Support Ticket",
            "SpTick",
            "QmQkrjVa6TMhuApkLNi9B8Vn9bYy9RcW8aGzrBvBRzkSLm"
        );

        PermissiveNST gardenticket = new PermissiveNST(
            "Garden Ticket",
            "Garden",
            "QmYzkWw4bdmh7mSVcQDMyMRessTk8eY6D4pmCMXixwuE7A"
        );

        PermissiveNST smokeBond = new PermissiveNST(
            "Cigar credit note",
            "CIGAR",
            "QmQG9Zz15cNENFYCNuUoLLCcBxcf7cXRU485RMzqiLCuwo"
        );

        vm.stopBroadcast();
    }

    /// @notice util to log the deployment environment
    function _logsDeploymentEnvironment() internal view {
        // network
        console.log("Network:", block.chainid);

        // block number
        console.log("Block number:", block.number);
        // console.log(string.concat("Block number: ", block.number.toString()));

        // deployer
        console.log("Deployer: ", DEPLOYER);
        console.log("Balance:", DEPLOYER.balance);
    }
}

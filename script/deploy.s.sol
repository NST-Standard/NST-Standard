// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";
// import {PermissiveNST} from "src/mocks/PermissiveNST.sol";

contract deploy is Script {
    address private DEPLOYER;
    address private ANVIL1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() public {
        // import `.env` private key
        uint256 pk = vm.envUint("DEPLOYER_ANVIL");
        DEPLOYER = vm.addr(pk);

        _logsDeploymentEnvironment();

        vm.startBroadcast(pk);

        // PermissiveNST supportTicket = new PermissiveNST(
        //     "Support Ticket",
        //     "SpTick",
        //     "QmQkrjVa6TMhuApkLNi9B8Vn9bYy9RcW8aGzrBvBRzkSLm"
        // );

        // PermissiveNST gardenTicket = new PermissiveNST(
        //     "Garden Ticket",
        //     "Garden",
        //     "QmYzkWw4bdmh7mSVcQDMyMRessTk8eY6D4pmCMXixwuE7A"
        // );

        // PermissiveNST smokeBond = new PermissiveNST(
        //     "Cigar credit note",
        //     "CIGAR",
        //     "QmQG9Zz15cNENFYCNuUoLLCcBxcf7cXRU485RMzqiLCuwo"
        // );

        // supportTicket.allowNST(address(smokeBond));
        // supportTicket.allowNST(address(gardenTicket));
        // smokeBond.allowNST(address(supportTicket));
        // smokeBond.allowNST(address(gardenTicket));
        // gardenTicket.allowNST(address(smokeBond));
        // gardenTicket.allowNST(address(supportTicket));

        // supportTicket.mint(ANVIL1);
        // supportTicket.mint(ANVIL1);

        // smokeBond.mint(DEPLOYER);
        // smokeBond.mint(DEPLOYER);

        // PermissiveNST(0x5FbDB2315678afecb367f032d93F642f64180aa3).allowNST(
        //     0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
        // );
        // PermissiveNST(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0).allowNST(
        //     0x5FbDB2315678afecb367f032d93F642f64180aa3
        // );

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

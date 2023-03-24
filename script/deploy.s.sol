// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PermissionlessERC_NMultiBarter} from "contracts/mocks/PermissionlessERC_NMultiBarter.sol";
import {PermissionlessERC_N} from "contracts/mocks/PermissionlessERC_N.sol";

contract deploy is Script {
    address private DEPLOYER;
    address private ANVIL1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() public {
        // import `.env` private key
        uint256 pk = vm.envUint("DEPLOYER_GOERLI");
        DEPLOYER = vm.addr(pk);

        _logsDeploymentEnvironment();

        vm.startBroadcast(pk);

        PermissionlessERC_NMultiBarter supportTicket = new PermissionlessERC_NMultiBarter(
                "Support Ticket",
                "SUP",
                "QmQkrjVa6TMhuApkLNi9B8Vn9bYy9RcW8aGzrBvBRzkSLm"
            );

        PermissionlessERC_NMultiBarter gardenTicket = new PermissionlessERC_NMultiBarter(
                "Garden Ticket",
                "GARDEN",
                "QmYzkWw4bdmh7mSVcQDMyMRessTk8eY6D4pmCMXixwuE7A"
            );

        PermissionlessERC_N catBox = new PermissionlessERC_N(
            "Cat Box",
            "CAT",
            "QmZZcGTza5eHfQsqkCq1B4mNTKCnPGYYL7F4CLCiparr7c"
        );

        supportTicket.enableBarterWith(address(gardenTicket));
        supportTicket.enableBarterWith(address(supportTicket));
        supportTicket.enableBarterWith(address(catBox));

        gardenTicket.enableBarterWith(address(supportTicket));
        catBox.enableBarterWith(address(supportTicket));

        vm.stopBroadcast();
    }

    /// @notice util to log the deployment environment
    function _logsDeploymentEnvironment() internal view {
        // network
        console.log("Network:", block.chainid);

        // block number
        console.log("Block number:", block.number);

        // deployer
        console.log("Deployer: ", DEPLOYER);
        console.log("Balance:", DEPLOYER.balance);
    }
}

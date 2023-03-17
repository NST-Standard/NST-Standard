// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IPureBarter} from "./barters/IPureBarter.sol";
import {IMultiBarter} from "./barters/IMultiBarter.sol";

interface IERCN is IPureBarter, IMultiBarter {
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
}

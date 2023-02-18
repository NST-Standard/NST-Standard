# Non sellable token

## ERC721

**Mandatory element** for ERC721 retrocompability

**Storage:**
| Name | Type | Slot | Offset | Bytes |
|--------------------|---------------------------------|------|--------|-------|
| **\_name** | string | 0 | 0 | 32 |
| **\_symbol** | string | 1 | 0 | 32 |
| \_owners | mapping(uint256 => address) | 2 | 0 | 32 |
| \_balances | mapping(address => uint256) | 3 | 0 | 32 |
| \_tokenApprovals | mapping(uint256 => address) | 4 | 0 | 32 |
| \_operatorApprovals | mapping(address => mapping(address => bool)) | 5 | 0 | 32 |

**Methods:**
|Method name|Parameters|Selector|
|---|---|---|
|approve|address,uint256|`0x095ea7b3`|
|balanceOf|address|`0x70a08231`|
|getApproved|uint256|`0x081812fc`|
|isApprovedForAll|address,address|`0xe985e9c5`|
|**name**||`0x06fdde03`|
|ownerOf|uint256|`0x6352211e`|
|safeTransferFrom|address,address,uint256|`0x42842e0e`|
|safeTransferFrom|address,address,uint256,bytes|`0xb88d4fde`|
|setApprovalForAll|address,bool|`0xa22cb465`|
|supportsInterface|bytes4|`0x01ffc9a7`|
|**symbol**||`0x95d89b41`|
|**tokenURI**|uint256|`0xc87b56dd`|
|transferFrom|address,address,uint256|`0x23b872dd`|

Events:

| Event Name     | Parameters              | Hash                                                                 |
| -------------- | ----------------------- | -------------------------------------------------------------------- |
| Approval       | address,address,uint256 | `0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925` |
| ApprovalForAll | address,address,bool    | `0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31` |
| **Transfer**   | address,address,uint256 | `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef` |

## SBT implementations

### General / custom implementation:

[WOLGEN](https://www.codeslaw.app/contracts/ethereum/0xde2967afc57055b2041685f2d5b376bfc2d0b536?file=WOLSBT.sol&start=258)

```js
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId, /* firstTokenId */
    uint256 batchSize
) internal override(ERC721, ERC721Enumerable) {
    require(from == address(0), "Err: token is SOUL BOUND");
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
}
```

[YKNERC721A](https://www.codeslaw.app/contracts/ethereum/0xf9ae12ddba6cbeb7930489119f4612cc42d5a3b2?file=contracts%2FMGYERC721A.sol&start=354)

```js
function _beforeTokenTransfers(
    address from_,
    address to_,
    uint256 startTokenId_,
    uint256 quantity_
) internal virtual override {
    require(
        !isSBTEnabled ||
            msg.sender == owner() ||
            from_ == address(0) ||
            to_ == address(0),
        "SBT mode Enabled: token transfer while paused."
    );

    //check tokenid transfer
    for (
        uint256 tokenId = startTokenId_;
        tokenId < startTokenId_ + quantity_;
        tokenId++
    ) {
        //check staking
        require(
            !isStakingEnabled ||
                _stakingStartedTimestamp[tokenId] == NULL_STAKED,
            "Staking now.: token transfer while paused."
        );

        //unstake if staking
        if (_stakingStartedTimestamp[tokenId] != NULL_STAKED) {
            //accum current time
            uint256 deltaTime = block.timestamp -
                _stakingStartedTimestamp[tokenId];
            _stakingTotalTime[tokenId] += deltaTime;
            //no longer staking
            _stakingStartedTimestamp[tokenId] = NULL_STAKED;
            _claimedLastTimestamp[tokenId] = NULL_STAKED;
        }
    }
    super._beforeTokenTransfers(from_, to_, startTokenId_, quantity_);
}
```

### ERC4973

modifier: `onlyAllowedOperator(from)`

[Oldeus721](https://www.codeslaw.app/contracts/ethereum/0x427cfa4947cccc6db3040ab32908a7ea6d31f370?file=contracts%2FOldeus721.sol&start=48)

```js
function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
  super.transferFrom(from, to, tokenId);
}
```

[SharkzSoulDV1](https://www.codeslaw.app/contracts/ethereum/0x41fd751eaadd666ada7d0780a4022284358bbffd?file=contracts%2Flib-upgradeable%2F4973%2FERC4973SoulContainerUpgradeable.sol&start=57)
No implementation of `transfer` function (only `IERC721Metadata`)

**Proxy + only IERC721Metadata**, the token is still on OpenSea: https://opensea.io/assets/ethereum/0x12deb1cb5732e40dd55b89abb6d5c31df13a6e38/54

Comment in the code:

```
 * This implementation included many features for real-life usage, by including ERC721
 * Metadata extension, we allow NFT platforms to recognize the token name, symbol and token
 * metadata, ex. token image, attributes. By design, ERC721 transfer, operator, and approval
 * mechanisms are all removed.
```

### ERC5192

[ERC721DelegateALockable](https://www.codeslaw.app/contracts/ethereum/0x3698f1be02c32bfe24dc042a3d23fdda802e6d5f?file=contracts%2Flib%2FERC5192.sol&start=6)

Use `whenNotLocked(tokenId)`

```js
function _transfer(
    address from,
    address to,
    uint256 tokenId
) internal virtual override whenNotLocked(tokenId) {
    super._transfer(from, to, tokenId);
}
```

[Relic protocol](https://www.codeslaw.app/contracts/ethereum/0x82ce91e7a5198334e4c9629f64b62b75401dba86?file=contracts%2FRelicToken.sol&start=130)
Disable transfers functions:

```js
function transferFrom(
    address, /* from */
    address, /* to */
    uint256 /* id */
) external pure {
    revert("RelicToken is soulbound");
}
```

---

## NST primer

3 transfer type:

- Mint (transfer from issuer)
- Exchange (exchange with another NST)
- Burn (transfer to issuer, token usage)

Mint & burn are only-owner restricted function, implementation change depends on the token usage / implementation.

**Perform a transfer between two users:**

- Force users to send and receive NST in the same transaction (send to receive | receive to send).

- Exchange is performed in one transaction using a "transfer with data". Inspired from [Certificate-based token transfers (Consenys::UniversalToken)](https://github.com/ConsenSys/UniversalToken/tree/master/contracts/certificate) which is a way to perform multisignature transaction.

**Avoid fake token utilisation to send and receive NST:**

- Each token should maintain a whitelist of NST
  - Allow the token to be protected from malicious token.
  - Maintnainer should check the contract code to ensure the whitelisted token has no malicious behaviours.

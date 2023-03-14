---
Title: < Non sellable token>
Description:<Non sellable token (NST) are between SBT and NFT, they cannot be freely transfered between wallet. NST implement an exchange function at the contract level. The NST implementation allow others NST to be transferable with itself>
author: < Cédric Nicolas (@cedric-n-icolas),Casey (@ ), Grégoire (@ ), Kerel Verwaerde (@NSTKerel), Matthieu Chassagne (@ ), Perrin (@pgrandne), Rafael Fitoussi (@fi2c), Raphael (@RaphaelHardFork), , Virgil (@virgilea2410)>
discussions-to: <https://t.me/Crypto_Kerel> 
status: <Draft>
type: <Standards Track, Meta, or Informational>
category: <Core, Networking, Interface, or ERC> # Only required for Standards Track. Otherwise, remove this field.>
created: <date created on, in ISO 8601 (yyyy-mm-dd) format>
requires: <EIP number(s)> 

---

## Abstract:
This EIP proposes a new non-sellable token (NST) standard that allows for the transfer of tokens between projects while maintaining a whitelist of authorized counterparties. NSTs would allow for the separation of price and value in the NFT market, preventing speculation from becoming the sole determinant of NFT value, as well as giving projects the ability to control the entire ecosystem for their NFTs while giving free reign for transfers within that ecosystem to their hodlers.
 

## Motivation:
Existing ERC token standards such as ERC-20 and ERC-721 are widely used and allow for the transfer of tokens between different projects, but they do not provide a mechanism for tokens that are not meant to be sold or transferred outside of their original project ecosystem. The proposed NST standard would provide a solution for this by enabling authorized counterparties to transfer NSTs between projects in a secure and compliant manner.

The NFT market is currently highly speculative and volatile, with the price of NFTs often determining their perceived value. NSTs would help to address this issue by creating a new standard that focuses on the true value of an NFT rather than just its price with the potential of an NFT being entirely cut off from any commercial exchange.


## Specification:
The proposed NST standard would be based on the ERC-721 standard and would include the following additional features:

A whitelist mechanism for authorized counterparties to transfer NSTs between projects



- NSTs can only be transferred between whitelisted NSTs created by other projects.
- Projects can whitelist any other NSTs for their NSTs but need to have reciprocal whitelisting.
- NSTs are non-sellable and cannot be traded for other cryptocurrencies or fiat currencies.
- NSTs can be created using the ERC-721 token standards.
- NSTs can be used for various purposes, including but not limited to: access control, rewards, and governance.
- A smart contract interface would be required to enable the transfer of NSTs between whitelisted tokens.
- Ability to view the whitelist and transfer history of NSTs.
- Additional optional features such as burn mechanics, auto transfers, etc. always under control by the creators.

## Rationale:
The proposed NST standard would enable projects to issue non-sellable tokens that can be transferred securely between projects with proper authorization. This would allow for a greater level of interoperability and collaboration between projects, while also maintaining control and ownership of the tokens within their respective ecosystems. The whitelist mechanism ensures that only authorized counterparties are able to transfer NSTs, reducing the risk of fraudulent or unauthorized transfers.

The proposed NST standard would promote a more stable and sustainable NFT market by separating price and value. By restricting the transfer of NSTs to only whitelisted tokens, the value of an NFT would be more closely tied to its actual worth and not just its market price. This would also create new opportunities for NSTs to be used as access control tokens, rewards, governance tokens, and could help not be placed as financial assets.

## Backwards Compatibility:
The proposed NST standard would be based on the ERC-721 standard and would be backwards compatible with existing ERC-721 implementations.

## Test Cases


## Implementation:
The proposed NST standard can be implemented as a smart contract on the Ethereum blockchain, similar to other ERC token standards. Projects interested in using the NST standard can deploy their own implementation of the smart contract and set their own whitelist of authorized counterparties. It could also be integrated into existing NFT marketplaces and platforms as a separate type of swapping.

## Security Considerations:
The proposed NST standard is subject to the same security considerations as other NFT standards and would require robust testing and auditing before deployment.

## Conclusion:
The proposed NST standard would provide a solution for projects looking to issue non-sellable tokens that can be securely transferred between projects with proper authorization. This would enable greater collaboration and interoperability between projects, while also maintaining control and ownership of the tokens within their respective ecosystems, as well as provide a new approach to NFTs that focuses on value rather than price.

## Copyright




## Testnet POC deployment

Try on the [dApp](https://nst-dapp.vercel.app/)

**Optimism goerli:**

| Token name        | Token address                                                                                                                         | Metadata IPFS hash                             |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| Garden ticket     | [0x238c88432E41F40f470f5C81bB708a7DdD8b6ec1](https://goerli-optimism.etherscan.io/address/0x238c88432E41F40f470f5C81bB708a7DdD8b6ec1) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |
| Support ticket    | [0x45d3e4934214e0dbEcA22a641EB57b972891DF4C](https://goerli-optimism.etherscan.io/address/0x45d3e4934214e0dbEcA22a641EB57b972891DF4C) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |
| Cigar credit note | [0xE9cf499d9a29A37610ec9fb1fD7507b55b3cbcF9](https://goerli-optimism.etherscan.io/address/0xE9cf499d9a29A37610ec9fb1fD7507b55b3cbcF9) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |

**Deploy on testnet:**

Run `anvil` (ganache-like local blockchain):

```
anvil
```

Deploy contract on `anvil`:

```
forge script deploy --rpc-url anvil --broadcast
```

Add anvil to your metasmask (new network), `anvil` should indicate which port (usually 8545) is listening. Then you can go on [remix](https://remix.ethereum.org/) to interact with the contract with metasmask (injected provider) and the ABI.

## Usage

Make sure you have installed [Rust](https://www.rust-lang.org/fr/learn/get-started) & [Foundry](https://book.getfoundry.sh/getting-started/installation)

```
forge install
forge update
```

**Compile contracts:**

Set compiler version in `foundry.toml`

```toml
solc = "0.8.13"
```

Compile and log contracts sizes:

```
forge build --sizes
```

**Run tests:**

```
forge test -vvvv
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

**Open Questions:**

- Transfer with `amount = 0` should be allowed? (simple transfer equivalent)

---

## About ERC721

**Contract storage:**

```
forge inspect ERC721 storage --pretty
```

**Methods:**

```
forge inspect ERC721 methods
```

Necessary for retrocompability:
|Method name|Parameters|Selector|
|---|---|---|
|name||`0x06fdde03`|
|symbol||`0x95d89b41`|
|tokenURI|`uint256` tokenId|`0xc87b56dd`|

**Events:**

```
forge inspect ERC721 events
```

Necessary for retrocompability:

| Event Name   | Parameters                                                  |
| ------------ | ----------------------------------------------------------- |
| **Transfer** | `address indexed` \| `address indexed` \| `uint256 indexed` |

---

## About SBT

Here some examples of how SBT implementations prevent transferability.

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

**Proxy + only IERC721Metadata**, the token is still displayed on OpenSea: https://opensea.io/assets/ethereum/0x12deb1cb5732e40dd55b89abb6d5c31df13a6e38/54

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

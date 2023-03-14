# Non sellable token

_Non sellable token (NST) are between SBT and NFT, they cannot be freely transfered between wallet. NST implement an exchange function at the contract level. The NST implementation allow others NST to be transferable with itself_



## Instructions pour la création d'une EIP

La liste des EIPs ainsi que le détail de la procédure à suivre sont indiqués dans ce répertoire https://github.com/ethereum/EIPs

#### 1° Propostion de l'idée à la gouvernance

Avant d'écrire l'EIP il FAUT qu'elle soit discutée sur l'un des 2 forums :
https://ethereum-magicians.org/ ou https://ethresear.ch/t/read-this-before-posting/8

Ca signifie qu'un membre du groupe NST doit s'occuper d'alimenter ces forums pour faire connaitre notre proposition de NST et répondre aux questions, dicussions si nécessaire

Ensuite si le consensus est atteint, c'est à dire que l'idée mérite d'être creusée et qu'aucune EIP y répond déjà on peut commencer le processus 

#### 2° Revue de l'EIP Process

La proposition d'EIP doit suivre les indications du site https://eips.ethereum.org/
Pour ce faire, une lecture et revue de l'EIP-1 doit être effectuée https://eips.ethereum.org/EIPS/eip-1
Cette EIP détaille ce qu'est une EIP, son processus et ses flux et enfin donne un template à suivre pour la rédaction de l'EIP.

C'est ce modèle qui a été repris par Raphael dans le fichier EIP-NST.md présent dans ce répertoire.
Il faut donc remplir chaque champ de ce modèle pour correspondore au standart attendu et ensuite le soummetre dans le répertoire. La pull request va être analysé par un EIP Editor et si c'est accepté c'est le début du processus

#### 3° Status de l'EIP

Une fois qu'elle est en status Draft (accepté par un EIP Editor) l'auteur peut la modifier et la mettre à jour en fonction des échanges. Lorsque l'EIP est prête il la passe en status Review c'est à dire qu'elle doit être revues par les pairs 
Il y a ensuite encore un long processus avec plusieurs status (last call, final, ...)

#### Exemple d'EIP pour s'inspirer

On peut prendre 2 EIPs pour s'inspirer:
EIP-5192 Minimal Soulbound NFTs
- la discussion liée à l'EIP : https://ethereum-magicians.org/t/final-eip-5192-minimal-soulbound-nfts/9814
- l'EIP suivant le template :https://github.com/ethereum/EIPs/blob/master/EIPS/eip-5192.md

EIP-4337 Account Abstraction Using Alt Mempool
- la discussion liée à l'EIP : https://ethereum-magicians.org/t/erc-4337-account-abstraction-via-entry-point-contract-specification/7160 pour info elle début en Septembre 2021
- l'EIP suivant le template : https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4337.md Beaucoup plus complexe que les minimal SBT






## Testnet POC deployment

**Optimism goerli:**

| Token name        | Token address                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Garden ticket     | [0x1a48b20bd0f0c89f823686c2270c5404887c287c](https://goerli-optimism.etherscan.io/address/0x1a48b20bd0f0c89f823686c2270c5404887c287c) |
| Support ticket    | [0x1ddd12d738acf870de92fd5387d90f3733d50d94](https://goerli-optimism.etherscan.io/address/0x1ddd12d738acf870de92fd5387d90f3733d50d94) |
| Cigar credit note | [0xbecced78b7a65a0b2464869553fc0a3c2d2db935](https://goerli-optimism.etherscan.io/address/0xbecced78b7a65a0b2464869553fc0a3c2d2db935) |

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
| Method name | Parameters        | Selector     |
| ----------- | ----------------- | ------------ |
| name        |                   | `0x06fdde03` |
| symbol      |                   | `0x95d89b41` |
| tokenURI    | `uint256` tokenId | `0xc87b56dd` |

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

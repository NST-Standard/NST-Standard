# Non-sellable token

- [EIP-draft](./EIP-NST.md)
- [Solidity implementation](./contracts/)
- [dApp repo](https://github.com/NST-Standard/nst-dapp)

## POC testnet deployment [TO UPDATE]

Try on the [dApp](https://nst-dapp.vercel.app/) (based on the old implementation)

**Optimism goerli:**

| Token name        | Token address                                                                                                                         | Metadata IPFS hash                             |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| Garden ticket     | [0x238c88432E41F40f470f5C81bB708a7DdD8b6ec1](https://goerli-optimism.etherscan.io/address/0x238c88432E41F40f470f5C81bB708a7DdD8b6ec1) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |
| Support ticket    | [0x45d3e4934214e0dbEcA22a641EB57b972891DF4C](https://goerli-optimism.etherscan.io/address/0x45d3e4934214e0dbEcA22a641EB57b972891DF4C) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |
| Cigar credit note | [0xE9cf499d9a29A37610ec9fb1fD7507b55b3cbcF9](https://goerli-optimism.etherscan.io/address/0xE9cf499d9a29A37610ec9fb1fD7507b55b3cbcF9) | QmcX5FcGpaouXHC1CfJZhpdjsLaeQARsPLpuNqbt7iEZVw |

**Deploy on testnet:**

---

**TO UPDATE**

Run `anvil` (ganache-like local blockchain):

```
anvil
```

Deploy contract on `anvil`:

```
forge script deploy --rpc-url anvil --broadcast
```

Add anvil to your metasmask (new network), `anvil` should indicate which port (usually 8545) is listening. Then you can go on [remix](https://remix.ethereum.org/) to interact with the contract with metasmask (injected provider) and the ABI.

---

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

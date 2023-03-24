# Non-sellable token

- [EIP-draft](./EIP-NST.md)
- [Solidity implementation](./contracts/)
- [dApp repo](https://github.com/NST-Standard/nst-dapp)

## Try it on the dApp

dApp: https://nst-dapp.vercel.app/

## Compile and run tests

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

## Deploy on local blockchain

Run `anvil` (ganache-like local blockchain):

```
anvil --block-time 5
```

Deploy contract on `anvil`:

```
forge script deploy --rpc-url anvil --broadcast
```

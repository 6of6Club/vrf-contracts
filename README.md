# Contracts 6of6 Club

Deploy multicall (Anvil local testnet):

```bash
forge create --rpc-url http://127.0.0.1:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    src/Multicall3.sol:Multicall3
```

Deploy contract (Anvil local testnet):

```bash
forge create --rpc-url http://127.0.0.1:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    src/OnChain6of6Club.sol:OnChain6of6Club
```

Deploy all (Anvil local testnet):

```bash
forge script script/OnChain6of6Club.s.sol:OnChain6of6ClubScript \
    --broadcast \
    --rpc-url http://127.0.0.1:8545
```

**Ethereum Merkle Tree Based Whitelist Sample**

This is an example project to help explain merkle tree based whitelists. It is only a sample. You will very likely need to modify it to fit your needs. No warranty or guarantee of any sort is included with this ***SAMPLE*** software package.

**Getting Started**

Clone the repository

`git clone git@github.com:Crossmint/eth-merkle-example.git`

Install the dependencies

`npm install`


Copy the .env file template

`cp sample.env .env`

Add required environment variables

```env
GOERLI_RPC_URL=
ETHERSCAN_KEY=
PUBLIC_KEY=
PRIVATE_KEY=
```

1. You can get RPC urls from providers such as https://infura.io/, https://www.alchemy.com/, etc. 

2. Get an Etherscan key (to verify your contract)
https://info.etherscan.com/etherscan-developer-api-key/

3. Save your public key address to the .env file

4. Export private key from metamask or another wallet. You probably should not use the same wallet that you store mainnet assets in. Create a new dev focused metamask account to minimize the risk of storing your private key in plaintext files. 

---

**To deploy the contract to a testnet run the following command:**

`npx hardhat run --network goerli scripts/deploy.js`

Wait about a minute and then verify the Contract. (You'll need an etherscan API key)

`npx hardhat verify --network goerli "0x__CONTRACT_ADDR_FROM_PREVIOUS_STEP__"`

---

The way it's setup now the deployer wallet will be set as the `financeWallet` which will receive all the funds. You will likely want to change this to be a ledger, trezor, or multi-sig wallet of some sort. You can do this by calling the `setFinanceWallet` method in the contract via etherscan. 
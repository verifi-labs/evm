[![codecov](https://codecov.io/github/verifi-labs/evm/branch/main/graph/badge.svg?token=BZ4XKYU3FT)](https://app.codecov.io/gh/verifi-labs/evm)
[![ci](https://github.com/verifi-labs/evm/actions/workflows/ci.yml/badge.svg)](https://github.com/verifi-labs/evm/actions/workflows/ci.yml)

# Verifi

An EVM implementation of the Verifi Protocol. Refer to the [documentation](https://docs.verifi.network) for more
information.

## Contracts Blueprint

```ml
src
├─ authenticators
│  ├─ Authenticator.sol - "Base Authenticator contract"
│  ├─ EthSigAuthenticator.sol - "Strategy that authenticates users via an EIP712 signature"
│  ├─ EthTxAuthenticator.sol - "Strategy that authenticates users via checking the tx sender address"
│  └─ VanillaAuthenticator.sol — "Vanilla Strategy"
├─ voting-strategies
│  ├─ CompVotingStrategy.sol - "Strategy that uses delegated balances of Comp tokens as voting power"
│  ├─ OZVotesVotingStrategy.sol - "Strategy that uses delegated balances of OZ Votes tokens as voting power"
│  ├─ WhitelistVotingStrategy.sol — "Strategy that gives predetermined voting power for members in a whitelist. Whitelist is stored in a bytes array On-Chain."
│  ├─ MerkleWhitelistVotingStrategy.sol — "Strategy that gives predetermined voting power for members in a whitelist. Whitelist is stored in a Merkle tree Off-Chain, with only the root being stored On-Chain."
│  └─ VanillaVotingStrategy.sol — "Vanilla Strategy"
├─ execution-strategies
│  ├─ timelocks
│  |  ├─ CompTimelockCompatibleExecutionStrategy.sol - "Strategy that provides compatibility with existing Comp Timelock contracts"
│  |  ├─ OptimisticCompTimelockCompatibleExecutionStrategy.sol - "Optimistic strategy that provides compatibility with existing Comp Timelock contracts"
│  |  ├─ OptimisticTimelockExecutionStrategy.sol - "Optimistic strategy that can be used to execute proposal transactions according to a timelock delay"
│  |  └─ TimelockExecutionStrategy.sol - "Strategy that can be used to execute proposal transactions according to a timelock delay"
│  ├─ AvatarExecutionStrategy.sol - "Strategy that allows proposal transactions to be executed from an Avatar contract"
│  ├─ TimelockExecutionStrategy.sol - "Strategy that can be used to execute proposal transactions according to a timelock delay"
│  ├─ CompTimelockCompatibleExecutionStrategy.sol - "Strategy that provides compatibility with existing Comp Timelock contracts"
│  ├─ EmergencyQuorumExecutionStrategy.sol - "Base Strategy that uses an additional Emergency Quorum to determine the status of a proposal"
│  ├─ OptimisticQuorumExecutionStrategy.sol - "Base Strategy that uses an Optimistic Quorum to determine the status of a proposal"
│  ├─ SimpleQuorumExecutionStrategy.sol - "Base Strategy that uses a Simple Quorum to determine the status of a proposal"
│  └─ VanillaExecutionStrategy.sol - "Vanilla Strategy"
├─ interfaces
│  ├─ ...
├─ proposal-validation-strategies
│  ├─ ActiveProposalsLimiterProposalValidationStrategy.sol - "Strategy to that validates with the ActiveProposalsLimiter module"
│  ├─ PropositionPowerAndActiveProposalsLimiterProposalValidationStrategy.sol - "Strategy that validates with the ActiveProposalsLimiter and PropositionPower modules"
│  └─ PropositionPowerProposalValidationStrategy.sol - "Strategy that validates with the PropositionPower module"
├─ utils
│  ├─ ActiveProposalsLimiter.sol - "Module to limit the number of active proposals per author"
│  ├─ BitPacker.sol - "Uint256 Bit Setting and Checking Library"
│  ├─ PropositionPower.sol - "Module that checks proposal authors exceed a threshold proposition power over a set of strategies"
│  ├─ SXHash.sol - "Verifi Types Hashing Library"
│  ├─ SXUtils.sol - "Verifi Types Utilities Library"
│  ├─ SignatureVerifier.sol - "Verifies EIP712 Signatures for Verifi actions"
│  └─ SpaceManager.sol - "Manages a whitelist of Spaces that have permissions to execute transactions"
├─ ProxyFactory.sol - "Handles the deployment and tracking of Space contracts"
└─ Space.sol - "The base contract for each Verifi space"
└─ types.sol - "Definitions for Verifi custom types"
```

## Usage

### Build

Build the contracts:

```sh
$ forge build
```

### Test

Run the tests:

```sh
$ forge test
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Deployment

To deploy the protocol to an EVM chain, first set the following environment variables:

```sh
# The address of the account that the protocol will be deployed from.
DEPLOYER_ADDRESS=
# The name of the chain you want to deploy on. The addresses of the deployed contracts will be stored at /deployments/network.json
NETWORK=
# An RPC URL for the chain.
RPC_URL=
# An API key for a block explorer on the chain (Optional).
ETHERSCAN_API_KEY=
```

Following this, a [Foundry Script](https://book.getfoundry.sh/tutorials/solidity-scripting) can be run to deploy the
entire protocol. Example usage to deploy from a Ledger Hardware Wallet and verify on a block explorer:

```sh
forge script script/Deployer.s.sol:Deployer --rpc-url $RPC_URL --optimize --broadcast --verify -vvvv --ledger --sender $DEPLOYER_ADDRESS --hd-paths "m/44'/60'/4'/0/0"
```

The script uses the [Singleton Factory](https://eips.ethereum.org/EIPS/eip-2470) for the deployments which ensures that
the addresses of the contracts are the same on all chains (so long as the chain is fully EVM equivalent).


###INSTALLATION HALP

Just in case you can't download your submodules, delete the lib folder and run the following commands:
git submodule add https://github.com/brockelmore/forge-std lib/forge-std
git submodule add https://github.com/marktoda/forge-gas-snapshot lib/forge-gas-snapshot
git submodule add -b v4.9.5 https://github.com/OpenZeppelin/openzeppelin-contracts lib/openzeppelin-contracts
git submodule add https://github.com/paulrberg/prb-test lib/prb-test
git submodule add -b v2.0.4 https://github.com/gnosis/zodiac lib/zodiac
git submodule add -b v1.3.0 https://github.com/safe-global/safe-contracts lib/safe-contracts
git submodule add -b v4.8.0 https://github.com/openzeppelin/openzeppelin-contracts-upgradeable lib/openzeppelin-contracts-upgradeable
git submodule add https://github.com/dmfxyz/murky lib/murky
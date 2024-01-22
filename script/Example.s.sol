// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";

import { ProxyFactory } from "../src/ProxyFactory.sol";
import { Space } from "../src/Space.sol";
import { VanillaAuthenticator } from "../src/authenticators/VanillaAuthenticator.sol";
import { TimelockExecutionStrategy } from "../src/execution-strategies/timelocks/TimelockExecutionStrategy.sol";
import { Strategy, IndexedStrategy, InitializeCalldata, Choice, MetaTransaction } from "../src/types.sol";
import { Enum } from "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

// Example script to deploy a space, create a proposal, vote on it, and execute it.
contract Example is Script {
    // Paste in the addresses from your json in the /deployments/ folder. The below are from v1.0.2 on goerli.
    address public proxyFactory = address(0xE1daC7a7445752d7E9ea43A421d6328CAeD1B212);
    address public spaceImplementation = address(0xe7a7C0b57BB627ec2aF85BD7a018465C8BF152Be);
    address public vanillaVotingStrategy = address(0xd638D4F4D2410B5ef432D8238fD92123425A0eC5);
    address public vanillaProposalValidationStrategy = address(0x89d4AA8423712BCD5a9c4922Cd6931d0267FD5Ab);
    address public vanillaAuthenticator = address(0x01095210325cdEFE67A9C077144ea5c9F5DcD928);
    address public timelockExecutionStrategyImplementation = address(0x5A69B951606f2687CC4c3728870521aec0c58E19);

    // Change the salt to deploy multiple spaces or get a 'salt already used' error
    uint256 public constant saltNonce = 1234;

    function run() public {
        //uint256 deployerPrivateKey = vm.envUint("RAW_PRIVATE_KEY");
        vm.startBroadcast(0xcaa643e27Aa2884e15A92e7Cc437F9e2fa2A8e22);

        address deployer = address(0xcaa643e27Aa2884e15A92e7Cc437F9e2fa2A8e22);
       
        Strategy[] memory votingStrategies = new Strategy[](1);
        votingStrategies[0] = Strategy(vanillaVotingStrategy, new bytes(0));

        string[] memory votingStrategyMetadataURIs = new string[](1);
        votingStrategyMetadataURIs[0] = "";

        address[] memory authenticators = new address[](1);
        authenticators[0] = vanillaAuthenticator;

        string memory proposalValidationStrategyMetadataURI = "";
        string memory daoURI = "";
        string memory metadataURI = "";

        // Deploy space
        ProxyFactory(proxyFactory).deployProxy(
            spaceImplementation,
            abi.encodeWithSelector(
                Space.initialize.selector,
                InitializeCalldata(
                    deployer,
                    0,
                    0,
                    100,
                    Strategy(vanillaProposalValidationStrategy, new bytes(0)),
                    proposalValidationStrategyMetadataURI,
                    daoURI,
                    metadataURI,
                    votingStrategies,
                    votingStrategyMetadataURIs,
                    authenticators
                )
            ),
            saltNonce
        );

        address space = ProxyFactory(proxyFactory).predictProxyAddress(
            spaceImplementation,
            keccak256(abi.encodePacked(deployer, saltNonce))
        );

        // Deploy Execution Strategy with the space whitelisted
        address[] memory spacesWhitelist = new address[](1);
        spacesWhitelist[0] = space;
        ProxyFactory(proxyFactory).deployProxy(
            timelockExecutionStrategyImplementation,
            abi.encodeWithSelector(
                TimelockExecutionStrategy.setUp.selector,
                abi.encode(deployer, deployer, spacesWhitelist, 0, 0)
            ),
            saltNonce
        );

        address timelockExecutionStrategy = ProxyFactory(proxyFactory).predictProxyAddress(
            timelockExecutionStrategyImplementation,
            keccak256(abi.encodePacked(deployer, saltNonce))
        );

        // Create proposal
        MetaTransaction[] memory proposalTransactions = new MetaTransaction[](1);
        // Example proposal tx
        proposalTransactions[0] = MetaTransaction(deployer, 0, abi.encode("hello"), Enum.Operation.Call, 0);
        VanillaAuthenticator(vanillaAuthenticator).authenticate(
            space,
            Space.propose.selector,
            abi.encode(
                deployer,
                "",
                Strategy(timelockExecutionStrategy, abi.encode(proposalTransactions)),
                new bytes(0)
            )
        );

        // Cast vote
        IndexedStrategy[] memory userVotingStrategies = new IndexedStrategy[](1);
        userVotingStrategies[0] = IndexedStrategy(0, new bytes(0));
        VanillaAuthenticator(vanillaAuthenticator).authenticate(
            space,
            Space.vote.selector,
            abi.encode(deployer, 1, Choice.For, userVotingStrategies, "")
        );

        // Execute proposal, which queues it in the tx in timelock
        Space(space).execute(1, abi.encode(proposalTransactions));

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import "../src/SingletonFactory.sol";

contract SingletonDeployer is Script {
    function setUp() public {}

    function run() public {
        // string memory seedPhrase = vm.readFile(".env");
        // uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        // vm.startBroadcast(privateKey);
        vm.startBroadcast(0xcaa643e27Aa2884e15A92e7Cc437F9e2fa2A8e22);
        SingletonFactory f = new SingletonFactory();

        vm.stopBroadcast();
    }
}
//forge script script/SingletonDeployer.s.sol:SingletonDeployer --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
// forge script script/SingletonDeployer.s.sol:SingletonDeployer --rpc-url $RPC_URL --optimize --broadcast --sender $DEPLOYER_ADDRESS --private-key $RAW_PRIVATE_KEY -vvvvv
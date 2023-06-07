// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Multicall3.sol";
import "../src/OnChain6of6Club.sol";

contract OnChain6of6ClubScript is Script {

    address[] _markets;

    address user1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address user2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address user3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address user4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;

    uint256 pk1 = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 pk2 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 pk3 = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    function setUp() public {
        _markets.push(user4);
    }

    function run() public {
        vm.startBroadcast(pk1);
        new Multicall3();
        OnChain6of6Club nft = new OnChain6of6Club();
        nft.addMarket(_markets);
        vm.stopBroadcast();

        vm.startBroadcast(pk1);
        nft.mint(64);
        vm.stopBroadcast();

        vm.startBroadcast(pk2);
        nft.mint(64);
        vm.stopBroadcast();

        vm.startBroadcast(pk1);

        for (uint256 i; i < 64; i++) {
            nft.transferFrom(user1, user2, i);
        }

        vm.stopBroadcast();

        vm.startBroadcast(pk2);

        for (uint256 i; i < 128; i++) {
            nft.transferFrom(user2, user3, i);
        }

        vm.stopBroadcast();

        vm.startBroadcast(pk3);

        for (uint256 i; i < 128; i++) {
            nft.transferFrom(user3, user1, i);
        }

        vm.stopBroadcast();

        vm.startBroadcast(pk1);

        for (uint256 i; i < 128; i++) {
            nft.transferFrom(user1, user2, i);
        }

        vm.stopBroadcast();

        vm.startBroadcast(pk2);

        for (uint256 i; i < 128; i++) {
            nft.transferFrom(user2, user3, i);
        }

        vm.stopBroadcast();

        vm.startBroadcast(pk3);

        for (uint256 i; i < 128; i++) {
            nft.transferFrom(user3, user1, i);
        }

        vm.stopBroadcast();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "murky/lib/forge-std/src/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DiscoTopen} from "../src/DiscoTopen.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    uint256 private s_airdropAmount = 25 * 1e18;
    uint256 private s_fundAmount = 4 * s_airdropAmount;

    function run() external returns (MerkleAirdrop, DiscoTopen) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, DiscoTopen) {
        vm.startBroadcast();
        DiscoTopen discoTopen = new DiscoTopen();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(discoTopen)));
        discoTopen.mint(discoTopen.owner(), s_fundAmount);
        discoTopen.transfer(address(merkleAirdrop), s_airdropAmount);
        vm.stopBroadcast();
        return (merkleAirdrop, discoTopen);
    }
}

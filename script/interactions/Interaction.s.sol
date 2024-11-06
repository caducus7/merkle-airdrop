//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {DiscoTopen} from "../../src/DiscoTopen.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "../../lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    error MerkleAirdrop__InvalidSignatureLength();

    MerkleAirdrop merkleAirdrop;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proof1 = 0x72995a443d90c829031cb42be582996fb8747dc02130f358dba0ad65c8db5119;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proof1, proof2];
    bytes private SIGNATURE =
        hex"a504781f0b18ea65b60f1b32537510a99ba3bbb49597503c369767d79b77a16d4cb0b947e8c2e99917d754f04dd0f1a35ab458292d34e7947c0a1388186ef2501c";

    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecent);
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert MerkleAirdrop__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DiscoTopen} from "../src/DiscoTopen.sol";
import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    DiscoTopen public discoTopen;
    bytes32 public ROOT = 0x7cdb6c21ef22a6cb5726d348e677f3e10032127425d425c5028965a30a71556e;
    address public USER;
    address public gasPayer;
    uint256 public AMOUNT = 25 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    uint256 public privateKey;

    function setUp() public {
        if (isZkSyncChain()) {
            DeployMerkleAirdrop deploy = new DeployMerkleAirdrop();
            (airdrop, discoTopen) = deploy.run();
        } else {
            discoTopen = new DiscoTopen();
            airdrop = new MerkleAirdrop(ROOT, discoTopen);
            discoTopen.mint(discoTopen.owner(), AMOUNT_TO_MINT);
            discoTopen.transfer(address(airdrop), AMOUNT_TO_MINT);
            (USER, privateKey) = makeAddrAndKey("USER");
            gasPayer = makeAddr("gasPayer");
        }
    }

    function testUsersCanClaim() public {
        // console.log("USER Address:", USER);  USER Address: 0xF921F4FA82620d8D2589971798c51aeD0C02c81a
        console.log("privateKey:", privateKey);
        uint256 startingBalance = discoTopen.balanceOf(USER);
        console.log("USER balance: ", startingBalance);
        bytes32 digest = airdrop.getMessageHash(USER, AMOUNT);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(USER, AMOUNT, PROOF, v, r, s);
        uint256 endBalance = discoTopen.balanceOf(USER);
        console.log("USER balance: ", endBalance);
        assertEq(endBalance - startingBalance, AMOUNT);
    }
}

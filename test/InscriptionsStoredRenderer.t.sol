// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/InscriptionsStoredRenderer.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract InscriptionsStoredRendererTest is Test {
    InscriptionsStoredRenderer renderer;

    function setUp() public {
        renderer = new InscriptionsStoredRenderer();
    }

    function _getDemoData(uint256 size)
        internal
        pure
        returns (InscriptionsStoredRenderer.Inscription[] memory data)
    {
        data = new InscriptionsStoredRenderer.Inscription[](size);
        for (uint256 i = 0; i < size; i++) {
            data[i] = InscriptionsStoredRenderer.Inscription({
                btc_txn: keccak256(abi.encode(i + 1)),
                properties: string.concat(Strings.toString(i + 1),'"tune":"*UNKNOWN*","resonance":"*ALPHA*","brush":"0xbc1","depth":"16"')
            });
        }
    }

    function test_ChunkHandoff() public {
        renderer.initializeWithData(
            abi.encode(
                InscriptionsStoredRenderer.ContractInfo({
                    animationBase: "https://ordinals.com/inscritions/...",
                    animationPostfix: "i0",
                    imageBase: "ipfs://asdf",
                    imagePostfix: ".png",
                    title: "inscriptions",
                    description: "inscriptions",
                    contractURI: "inscriptions"
                })
            )
        );


        renderer.addInscriptions(address(this), _getDemoData(1));
        renderer.addInscriptions(address(this), _getDemoData(2));
        renderer.addInscriptions(address(this), _getDemoData(3));

        vm.expectRevert();
        renderer.getInscriptionForTokenId(address(this), 0);
        assertEq(renderer.getInscriptionForTokenId(address(this), 1).btc_txn, keccak256(abi.encode(1)));
        assertEq(renderer.getInscriptionForTokenId(address(this), 2).btc_txn, keccak256(abi.encode(1)));
        assertEq(renderer.getInscriptionForTokenId(address(this), 3).btc_txn, keccak256(abi.encode(2)));
        assertEq(renderer.getInscriptionForTokenId(address(this), 4).btc_txn, keccak256(abi.encode(1)));
        assertEq(renderer.getInscriptionForTokenId(address(this), 5).btc_txn, keccak256(abi.encode(2)));
        assertEq(renderer.getInscriptionForTokenId(address(this), 6).btc_txn, keccak256(abi.encode(3)));
    }

    function test_NewInscription() public {
        renderer.initializeWithData(
            abi.encode(
                InscriptionsStoredRenderer.ContractInfo({
                    animationBase: "https://ordinals.com/inscritions/...",
                    animationPostfix: "i0",
                    imageBase: "ipfs://asdf",
                    imagePostfix: ".png",
                    title: "inscriptions",
                    description: "inscriptions",
                    contractURI: "inscriptions"
                })
            )
        );
        renderer.addInscriptions(address(this), _getDemoData(50));
        renderer.getInscriptionForTokenId(address(this), 1);
        assertEq(
            renderer.tokenURI(10),
            "data:application/json;base64,eyJuYW1lIjogImluc2NyaXB0aW9ucyAjMTAiLCJkZXNjcmlwdGlvbiI6ICJpbnNjcmlwdGlvbnMgXG4gaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uYzY1YTdiYjhkNjM1MWMxY2Y3MGM5NWEzMTZjYzZhOTI4MzljOTg2NjgyZDk4YmMzNWY5NThmNDg4M2Y5ZDJhOGkwIiwiaW1hZ2UiOiAiaXBmczovL2FzZGZjNjVhN2JiOGQ2MzUxYzFjZjcwYzk1YTMxNmNjNmE5MjgzOWM5ODY2ODJkOThiYzM1Zjk1OGY0ODgzZjlkMmE4LnBuZyIsImFuaW1hdGlvbl91cmwiOiAiaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uYzY1YTdiYjhkNjM1MWMxY2Y3MGM5NWEzMTZjYzZhOTI4MzljOTg2NjgyZDk4YmMzNWY5NThmNDg4M2Y5ZDJhOGkwIiwiZXh0ZXJuYWxfdXJsIjogImh0dHBzOi8vb3JkaW5hbHMuY29tL2luc2NyaXRpb25zLy4uLmM2NWE3YmI4ZDYzNTFjMWNmNzBjOTVhMzE2Y2M2YTkyODM5Yzk4NjY4MmQ5OGJjMzVmOTU4ZjQ4ODNmOWQyYThpMCIsInByb3BlcnRpZXMiOiB7ImJ0YyB0cmFuc2FjdGlvbiBoYXNoIjogImM2NWE3YmI4ZDYzNTFjMWNmNzBjOTVhMzE2Y2M2YTkyODM5Yzk4NjY4MmQ5OGJjMzVmOTU4ZjQ4ODNmOWQyYTgiLCAidHVuZSI6IipVTktOT1dOKiIsInJlc29uYW5jZSI6IipBTFBIQSoiLCJicnVzaCI6IjB4YmMxIiwiZGVwdGgiOiIxNiJ9fQ=="
        );
    }
}

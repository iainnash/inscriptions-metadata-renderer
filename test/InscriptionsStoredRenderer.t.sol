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

    function test_ChunkSizesFull() public {
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
        


        for (uint256 i = 0; i < 8*2; ++i) {
            renderer.addInscriptions(address(this), _getDemoData(50));
        }

        renderer.tokenURI(800);
        vm.expectRevert();
        renderer.tokenURI(801);
        vm.expectRevert();
        renderer.tokenURI(0);

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
        renderer.addInscriptions(address(this), _getDemoData(5));
        renderer.addInscriptions(address(this), _getDemoData(5));
        renderer.getInscriptionForTokenId(address(this), 1);
        assertEq(
            renderer.tokenURI(10),
            "data:application/json;base64,eyJuYW1lIjogImluc2NyaXB0aW9ucyAjMTAiLCJkZXNjcmlwdGlvbiI6ICJpbnNjcmlwdGlvbnMgXG4gaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uMDM2YjYzODRiNWVjYTc5MWM2Mjc2MTE1MmQwYzc5YmIwNjA0YzEwNGE1ZmI2ZjRlYjA3MDNmMzE1NGJiM2RiMGkwIiwiaW1hZ2UiOiAiaXBmczovL2FzZGYwMzZiNjM4NGI1ZWNhNzkxYzYyNzYxMTUyZDBjNzliYjA2MDRjMTA0YTVmYjZmNGViMDcwM2YzMTU0YmIzZGIwLnBuZyIsImFuaW1hdGlvbl91cmwiOiAiaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uMDM2YjYzODRiNWVjYTc5MWM2Mjc2MTE1MmQwYzc5YmIwNjA0YzEwNGE1ZmI2ZjRlYjA3MDNmMzE1NGJiM2RiMGkwIiwiZXh0ZXJuYWxfdXJsIjogImh0dHBzOi8vb3JkaW5hbHMuY29tL2luc2NyaXRpb25zLy4uLjAzNmI2Mzg0YjVlY2E3OTFjNjI3NjExNTJkMGM3OWJiMDYwNGMxMDRhNWZiNmY0ZWIwNzAzZjMxNTRiYjNkYjBpMCIsInByb3BlcnRpZXMiOiB7ImJ0YyB0cmFuc2FjdGlvbiBoYXNoIjogIjAzNmI2Mzg0YjVlY2E3OTFjNjI3NjExNTJkMGM3OWJiMDYwNGMxMDRhNWZiNmY0ZWIwNzAzZjMxNTRiYjNkYjAiLCA1InR1bmUiOiIqVU5LTk9XTioiLCJyZXNvbmFuY2UiOiIqQUxQSEEqIiwiYnJ1c2giOiIweGJjMSIsImRlcHRoIjoiMTYifX0="
        );
        vm.expectRevert();
        renderer.tokenURI(11);
        vm.expectRevert();
        renderer.tokenURI(0);
    }
}

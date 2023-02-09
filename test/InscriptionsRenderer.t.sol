// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/InscriptionsRenderer.sol";

contract InscriptionsRendererTest is Test {
    InscriptionsRenderer renderer;

    function setUp() public {
        renderer = new InscriptionsRenderer();
    }

    function _getDemoData(uint256 size)
        internal
        pure
        returns (bytes32[] memory data)
    {
        data = new bytes32[](size);
        for (uint256 i = 0; i < size; i++) {
            data[i] = keccak256(abi.encode(i));
        }
    }

    function test_NewInscription() public {
        renderer.initializeWithData(
            abi.encode(
                InscriptionsRenderer.ContractInfo({
                    animationBase: "https://ordinals.com/inscritions/...",
                    animationPostfix: "i0",
                    imageBase: "ipfs://asdf",
                    imagePostfix: ".png",
                    title: "inscriptions",
                    description: "inscriptions"
                })
            )
        );
        renderer.addInscriptions(address(this), _getDemoData(160));
        assertEq(
            renderer.tokenURI(10),
            "data:application/json;base64,eyJuYW1lIjogImluc2NyaXB0aW9ucyIsImRlc2NyaXB0aW9uIjogImluc2NyaXB0aW9ucyBcbiBodHRwczovL29yZGluYWxzLmNvbS9pbnNjcml0aW9ucy8uLi42ZTE1NDAxNzFiNmMwYzk2MGI3MWE3MDIwZDlmNjAwNzdmNmFmOTMxYThiYmY1OTBkYTAyMjNkYWNmNzVjN2FmaTAiLCJpbWFnZSI6ICJpcGZzOi8vYXNkZjZlMTU0MDE3MWI2YzBjOTYwYjcxYTcwMjBkOWY2MDA3N2Y2YWY5MzFhOGJiZjU5MGRhMDIyM2RhY2Y3NWM3YWYucG5nIiwiYW5pbWF0aW9uX3VybCI6ICJodHRwczovL29yZGluYWxzLmNvbS9pbnNjcml0aW9ucy8uLi42ZTE1NDAxNzFiNmMwYzk2MGI3MWE3MDIwZDlmNjAwNzdmNmFmOTMxYThiYmY1OTBkYTAyMjNkYWNmNzVjN2FmaTAiLCJleHRlcm5hbF91cmwiOiAiaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uNmUxNTQwMTcxYjZjMGM5NjBiNzFhNzAyMGQ5ZjYwMDc3ZjZhZjkzMWE4YmJmNTkwZGEwMjIzZGFjZjc1YzdhZmkwIiwicHJvcGVydGllcyI6IHsiYnRjIHRyYW5zYWN0aW9uIGhhc2giOiAiNmUxNTQwMTcxYjZjMGM5NjBiNzFhNzAyMGQ5ZjYwMDc3ZjZhZjkzMWE4YmJmNTkwZGEwMjIzZGFjZjc1YzdhZiJ9fQ=="
        );
    }
}

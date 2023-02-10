// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
        returns (InscriptionsRenderer.Inscription[] memory data)
    {
        data = new InscriptionsRenderer.Inscription[](size);
        for (uint256 i = 0; i < size; i++) {
            data[i] = InscriptionsRenderer.Inscription({
                btc_txn: keccak256(abi.encode(i)),
                tune: "theme",
                resonance: "palette",
                brush: "char_set",
                depth: "12"
            });
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
        renderer.addInscriptions(address(this), _getDemoData(50));
        assertEq(
            renderer.tokenURI(10),
            "data:application/json;base64,eyJuYW1lIjogImluc2NyaXB0aW9ucyIsImRlc2NyaXB0aW9uIjogImluc2NyaXB0aW9ucyBcbiBodHRwczovL29yZGluYWxzLmNvbS9pbnNjcml0aW9ucy8uLi42ZTE1NDAxNzFiNmMwYzk2MGI3MWE3MDIwZDlmNjAwNzdmNmFmOTMxYThiYmY1OTBkYTAyMjNkYWNmNzVjN2FmaTAiLCJpbWFnZSI6ICJpcGZzOi8vYXNkZjZlMTU0MDE3MWI2YzBjOTYwYjcxYTcwMjBkOWY2MDA3N2Y2YWY5MzFhOGJiZjU5MGRhMDIyM2RhY2Y3NWM3YWYucG5nIiwiYW5pbWF0aW9uX3VybCI6ICJodHRwczovL29yZGluYWxzLmNvbS9pbnNjcml0aW9ucy8uLi42ZTE1NDAxNzFiNmMwYzk2MGI3MWE3MDIwZDlmNjAwNzdmNmFmOTMxYThiYmY1OTBkYTAyMjNkYWNmNzVjN2FmaTAiLCJleHRlcm5hbF91cmwiOiAiaHR0cHM6Ly9vcmRpbmFscy5jb20vaW5zY3JpdGlvbnMvLi4uNmUxNTQwMTcxYjZjMGM5NjBiNzFhNzAyMGQ5ZjYwMDc3ZjZhZjkzMWE4YmJmNTkwZGEwMjIzZGFjZjc1YzdhZmkwIiwicHJvcGVydGllcyI6IHsiYnRjIHRyYW5zYWN0aW9uIGhhc2giOiAiNmUxNTQwMTcxYjZjMGM5NjBiNzFhNzAyMGQ5ZjYwMDc3ZjZhZjkzMWE4YmJmNTkwZGEwMjIzZGFjZjc1YzdhZiIsInR1bmUiOiAidGhlbWUiLCJyZXNvbmFuY2UiOiAicGFsZXR0ZSIsImJydXNoIjogImNoYXJfc2V0IiwiZGVwdGgiOiAiMTIifX0="
        );
    }
}

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
                "https://ordinals.com/inscription/",
                "i0",
                "https://ipfs.io/bafy..."
            )
        );
        renderer.addInscriptions(address(this), _getDemoData(160));
        assertEq(
            renderer.tokenURI(10),
            "https://ordinals.com/inscription/0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2a8i0"
        );
    }
}

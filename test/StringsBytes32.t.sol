// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/StringsBytes32.sol";

contract StringBytes32Test is Test {
    function test_Stringifies() public {
        assertEq(StringsBytes32.toHexString(
            bytes32(
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        ), "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
    }
}

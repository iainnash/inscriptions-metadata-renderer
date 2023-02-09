// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @author iain and openzeppelin
// @dev modified from  openzeppelin-contracts/contracts/utils/Strings.sol
library StringsBytes32 {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(bytes32 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * 32 + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * 32 + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[uint256(value) & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {MetadataRenderAdminCheck} from "zora-drops-contracts/metadata/MetadataRenderAdminCheck.sol";

import {StringsBytes32} from "./StringsBytes32.sol";

/// @author @isiain
/// @notice Inscriptions Metadata on-chain renderer
contract InscriptionsRenderer is IMetadataRenderer, MetadataRenderAdminCheck {
    /// @notice Stores address => tokenId => bytes32 btc txn id
    mapping(address => mapping(uint256 => bytes32)) inscriptions;
    /// @notice Stores address => numberInscribedTokens
    mapping(address => uint256) inscriptionsCount;
    /// @notice Stores address => string base, string postfix, string contractURI for urls
    mapping(address => ContractInfo) contractInfos;

    struct ContractInfo {
        string animationBase;
        string imageBase;
        string contractURI;
        string postfix;
        string title;
        string description;
    }

    event BaseURIsUpdated(address target, ContractInfo info);

    function addInscriptions(
        address inscriptionsContract,
        bytes32[] calldata newInscriptions
    ) external requireSenderAdmin(inscriptionsContract) {
        unchecked {
            // get count
            uint256 count = inscriptionsCount[inscriptionsContract];
            for (uint256 i = 1; i < newInscriptions.length + 1; ++i) {
                inscriptions[inscriptionsContract][count + i] = newInscriptions[
                    i
                ];
            }
            // update count
            inscriptionsCount[inscriptionsContract] = count;
        }
    }

    function setBaseURIs(address target, ContractInfo memory info)
        external
        requireSenderAdmin(target)
    {
        _setBaseURIs(target, info);
        emit BaseURIsUpdated(target, info);
    }

    function _setBaseURIs(address target, ContractInfo memory info) internal {
        contractInfos[target] = info;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        string memory animationURI = string.concat(
            contractInfos[msg.sender].animationBase,
            StringsBytes32.toHexString(inscriptions[msg.sender][tokenId]),
            contractInfos[msg.sender].postfix
        );

        string memory imageURI = string.concat(
            contractInfos[msg.sender].imageBase,
            StringsBytes32.toHexString(inscriptions[msg.sender][tokenId])
        );

    }

    function contractURI() external view returns (string memory) {
        return contractInfos[msg.sender].contractURI;
    }

    function initializeWithData(bytes memory initData) external {
        ContractInfo memory info = abi.decode(initData, (ContractInfo));
        _setBaseURIs(msg.sender, info);
    }
}

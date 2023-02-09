// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {MetadataRenderAdminCheck} from "zora-drops-contracts/metadata/MetadataRenderAdminCheck.sol";

import {StringsBytes32} from "./StringsBytes32.sol";

contract InscriptionsRenderer is IMetadataRenderer, MetadataRenderAdminCheck {
    mapping(address => mapping(uint256 => bytes32)) inscriptions;
    mapping(address => uint256) inscriptionsCount;
    mapping(address => ContractInfo) contractInfos;

    function addInscriptions(
        address inscriptionsContract,
        bytes32[] calldata newInscriptions
    ) external requireSenderAdmin(inscriptionsContract) {
        unchecked {
            // get count
            uint256 count = inscriptionsCount[inscriptionsContract];
            for (uint256 i = 0; i < newInscriptions.length; ++i) {
                inscriptions[inscriptionsContract][count + 1] = newInscriptions[
                    i
                ];
            }
            // update count
            inscriptionsCount[inscriptionsContract] = count;
        }
    }

    struct ContractInfo {
        string base;
        string contractURI;
    }

    event BaseURIsUpdated(address target, ContractInfo info);

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
        return
            string.concat(
                contractInfos[msg.sender].base,
                StringsBytes32.toHexString(inscriptions[msg.sender][tokenId])
            );
    }

    function contractURI() external view returns (string memory) {
        return contractInfos[msg.sender].contractURI;
    }

    function initializeWithData(bytes memory initData) external {
        (string memory _base, string memory _contractURI) = abi.decode(
            initData,
            (string, string)
        );
        _setBaseURIs(
            msg.sender,
            ContractInfo({base: _base, contractURI: _contractURI})
        );
    }
}

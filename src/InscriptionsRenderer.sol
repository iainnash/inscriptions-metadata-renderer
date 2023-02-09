// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {MetadataRenderAdminCheck} from "zora-drops-contracts/metadata/MetadataRenderAdminCheck.sol";
import {MetadataBuilder} from "micro-onchain-metadata-utils/MetadataBuilder.sol";
import {MetadataJSONKeys} from "micro-onchain-metadata-utils/MetadataJSONKeys.sol";

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
        string animationPostfix;
        string imageBase;
        string imagePostfix;
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
                    i - 1
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
            contractInfos[msg.sender].animationPostfix
        );

        string memory imageURI = string.concat(
            contractInfos[msg.sender].imageBase,
            StringsBytes32.toHexString(inscriptions[msg.sender][tokenId]),
            contractInfos[msg.sender].imagePostfix
        );

        ContractInfo memory info = contractInfos[msg.sender];

        MetadataBuilder.JSONItem[]
            memory items = new MetadataBuilder.JSONItem[](5);
        items[0].key = MetadataJSONKeys.keyName;
        items[0].value = string.concat(info.title);
        items[0].quote = true;

        items[1].key = MetadataJSONKeys.keyDescription;
        items[1].value = string.concat(info.description, " \\n ", animationURI);
        items[1].quote = true;

        items[2].key = MetadataJSONKeys.keyImage;
        items[2].value = imageURI;
        items[2].quote = true;

        items[3].key = MetadataJSONKeys.keyAnimationURL;
        items[3].value = animationURI;
        items[3].quote = true;

        items[4].key = "external_url";
        items[4].value = animationURI;
        items[4].quote = true;

        return MetadataBuilder.generateEncodedJSON(items);
    }

    function contractURI() external view returns (string memory) {
        ContractInfo memory info = contractInfos[msg.sender];

        MetadataBuilder.JSONItem[]
            memory items = new MetadataBuilder.JSONItem[](3);
        items[0].key = MetadataJSONKeys.keyName;
        items[0].value = info.title;
        items[0].quote = true;

        items[1].key = MetadataJSONKeys.keyDescription;
        items[1].value = info.description;
        items[1].quote = true;

        items[2].key = MetadataJSONKeys.keyImage;
        items[2].value = string.concat(info.imageBase, "/contract");
        items[2].quote = true;

        return MetadataBuilder.generateEncodedJSON(items);
    }

    function initializeWithData(bytes memory initData) external {
        ContractInfo memory info = abi.decode(initData, (ContractInfo));
        _setBaseURIs(msg.sender, info);
    }
}

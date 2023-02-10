// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {MetadataRenderAdminCheck} from "zora-drops-contracts/metadata/MetadataRenderAdminCheck.sol";
import {MetadataBuilder} from "micro-onchain-metadata-utils/MetadataBuilder.sol";
import {MetadataJSONKeys} from "micro-onchain-metadata-utils/MetadataJSONKeys.sol";

import {StringsBytes32} from "./StringsBytes32.sol";

/// @author @isiain
/// @notice Inscriptions Metadata on-chain renderer
contract InscriptionsRenderer is IMetadataRenderer, MetadataRenderAdminCheck {
    /// @notice Stores address => tokenId => bytes32 btc txn id
    mapping(address => mapping(uint256 => Inscription)) inscriptions;
    // /// @notice Stores address => tokenId => Theme btc txn id
    // mapping(address => mapping(uint256 => Inscription)) themes;
    /// @notice Stores address => numberInscribedTokens
    mapping(address => uint256) inscriptionsCount;
    /// @notice Stores address => string base, string postfix, string contractURI for urls
    mapping(address => ContractInfo) contractInfos;

    struct Inscription {
        bytes32 btc_txn;
        string tune;
        string resonance;
        string brush;
        string depth;
    }

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
        Inscription[] calldata newInscriptions
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

    function getTxnHashForTokenId(address inscriptionsContract, uint256 tokenId)
        external
        view
        returns (Inscription memory)
    {
        return inscriptions[inscriptionsContract][tokenId];
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
        Inscription memory inscription = inscriptions[msg.sender][tokenId];

        string memory animationURI = string.concat(
            contractInfos[msg.sender].animationBase,
            StringsBytes32.toHexString(inscription.btc_txn),
            contractInfos[msg.sender].animationPostfix
        );

        string memory btcHash = StringsBytes32.toHexString(inscription.btc_txn);

        string memory imageURI = string.concat(
            contractInfos[msg.sender].imageBase,
            btcHash,
            contractInfos[msg.sender].imagePostfix
        );

        ContractInfo memory info = contractInfos[msg.sender];

        MetadataBuilder.JSONItem[]
            memory items = new MetadataBuilder.JSONItem[](6);
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

        items[4].key = "external_url";
        items[4].value = animationURI;
        items[4].quote = true;

        MetadataBuilder.JSONItem[]
            memory properties = new MetadataBuilder.JSONItem[](5);
        properties[0].key = "btc transaction hash";
        properties[0].value = btcHash;
        properties[0].quote = true;

        properties[1].key = "tune";
        properties[1].value = inscription.tune;
        properties[1].quote = true;

        properties[2].key = "resonance";
        properties[2].value = inscription.resonance;
        properties[2].quote = true;

        properties[3].key = "brush";
        properties[3].value = inscription.brush;
        properties[3].quote = true;

        properties[4].key = "depth";
        properties[4].value = inscription.depth;
        properties[4].quote = true;

        items[5].key = MetadataJSONKeys.keyProperties;
        items[5].quote = false;
        items[5].value = MetadataBuilder.generateJSON(properties);

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

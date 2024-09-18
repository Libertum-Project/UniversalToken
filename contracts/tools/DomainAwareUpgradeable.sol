// SPDX-License-Identifier: Apache-2.0
/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.8.0;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract DomainAwareUpgradeable is Initializable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct DomainAwareStorage {
        // Mapping of ChainID to domain separators. This is a very gas efficient way
        // to not recalculate the domain separator on every call, while still
        // automatically detecting ChainID changes.
        mapping(uint256 => bytes32) domainSeparators;
    }

    // keccak256(abi.encode(uint256(keccak256("UniversalToken.storage.DomainAware")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DomainAwareStorageLocation = 0x9ee54c81aef0a0ff449515124789eb3a81a2f9e661b59f7d02a5e4f089f31900;

    function _getDomainAwareStorage() private pure returns (DomainAwareStorage storage $) {
        assembly {
            $.slot := DomainAwareStorageLocation
        }
    }

    function __DomainAware_init() internal onlyInitializing {
        _updateDomainSeparator();
    }

    function domainName() public virtual view returns (string memory);

    function domainVersion() public virtual view returns (string memory);

    function generateDomainSeparator() public view returns (bytes32) {
        uint256 chainID = _chainID();

        // no need for assembly, running very rarely
        bytes32 domainSeparatorHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(domainName())), // ERC-20 Name
                keccak256(bytes(domainVersion())), // Version
                chainID,
                address(this)
            )
        );

        return domainSeparatorHash;
    }

    function domainSeparator() public returns (bytes32) {
        return _domainSeparator();
    }

    function _updateDomainSeparator() private returns (bytes32) {
        uint256 chainID = _chainID();

        bytes32 newDomainSeparator = generateDomainSeparator();

        _getDomainAwareStorage().domainSeparators[chainID] = newDomainSeparator;

        return newDomainSeparator;
    }

    // Returns the domain separator, updating it if chainID changes
    function _domainSeparator() private returns (bytes32) {
        bytes32 currentDomainSeparator = _getDomainAwareStorage().domainSeparators[_chainID()];

        if (currentDomainSeparator != 0x00) {
            return currentDomainSeparator;
        }

        return _updateDomainSeparator();
    }

    function _chainID() internal view returns (uint256) {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        return chainID;
    }
}

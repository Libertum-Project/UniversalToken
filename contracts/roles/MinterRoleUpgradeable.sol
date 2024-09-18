// SPDX-License-Identifier: Apache-2.0
/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.8.0;

import "./Roles.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title MinterRole
 * @dev Minters are responsible for minting new tokens.
 */
abstract contract MinterRoleUpgradeable is Initializable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct MinterRoleStorage {
        Roles.Role minters;
    }

    // keccak256(abi.encode(uint256(keccak256("UniversalToken.storage.MinterRole")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MinterRoleStorageLocation = 0xbec714f2c2432a55a01c4f6aa5ec8c487be7f280378a48cb55318c601c352700;

    function _getMinterRoleStorage() private pure returns (MinterRoleStorage storage $) {
        assembly {
            $.slot := MinterRoleStorageLocation
        }
    }
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    function __MinterRole_init(address minter) internal onlyInitializing {
        _addMinter(minter);
    }

    modifier onlyMinter() virtual {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _getMinterRoleStorage().minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function removeMinter(address account) public onlyMinter {
        _removeMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _getMinterRoleStorage().minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _getMinterRoleStorage().minters.remove(account);
        emit MinterRemoved(account);
    }
}

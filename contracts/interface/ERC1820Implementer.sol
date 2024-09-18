// SPDX-License-Identifier: Apache-2.0
/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.8.0;


contract ERC1820Implementer {
  /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
  struct ERC1820ImplementerStorage {
    mapping(bytes32 => bool) interfaceHashes;
  }

  // keccak256(abi.encode(uint256(keccak256("UniversalToken.storage.ERC1820Implementer")) - 1)) & ~bytes32(uint256(0xff))
  bytes32 private constant ERC180ImplementerStorageLocation = 0xce6a04faf47321c685cc3971a9972be3f520dfde848453aaf324a4b1d664c100;

  function _getERC1820ImplementerStorage() private pure returns (ERC1820ImplementerStorage storage $) {
    assembly {
      $.slot := ERC180ImplementerStorageLocation
    }
  }

  bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));

  function canImplementInterfaceForAddress(bytes32 interfaceHash, address /*addr*/) // Comments to avoid compilation warnings for unused variables.
    external
    view
    returns(bytes32)
  {
    if(_getERC1820ImplementerStorage().interfaceHashes[interfaceHash]) {
      return ERC1820_ACCEPT_MAGIC;
    } else {
      return "";
    }
  }

  function _setInterface(string memory interfaceLabel) internal {
    _getERC1820ImplementerStorage().interfaceHashes[keccak256(abi.encodePacked(interfaceLabel))] = true;
  }

}

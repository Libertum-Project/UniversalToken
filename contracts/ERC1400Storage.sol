// SPDX-License-Identifier: Apache-2.0
/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./tools/ERC1820Client.sol";
import "./interface/ERC1820Implementer.sol";

import "./roles/MinterRoleUpgradeable.sol";

import "./IERC1400.sol";

// Extensions
import "./extensions/tokenExtensions/IERC1400TokensValidator.sol";
import "./extensions/tokenExtensions/IERC1400TokensChecker.sol";
import "./extensions/userExtensions/IERC1400TokensSender.sol";
import "./extensions/userExtensions/IERC1400TokensRecipient.sol";
import "./tools/DomainAwareUpgradeable.sol";


/**
 * @title ERC1400
 * @dev ERC1400 logic
 */
contract ERC1400Storage {

  struct Doc {
    string docURI;
    bytes32 docHash;
    uint256 timestamp;
  }

  struct ERC1400Store {
    /************************************* Token description ****************************************/
    string name;
    string symbol;
    uint256 granularity;
    uint256 totalSupply;
    bool migrated;
    /************************************************************************************************/


    /**************************************** Token behaviours **************************************/
    // Indicate whether the token can still be controlled by operators or not anymore.
    bool isControllable;

    // Indicate whether the token can still be issued by the issuer or not anymore.
    bool isIssuable;
    /************************************************************************************************/


    /********************************** ERC20 Token mappings ****************************************/
    // Mapping from tokenHolder to balance.
    mapping(address => uint256) balances;

    // Mapping from (tokenHolder, spender) to allowed value.
    mapping (address => mapping (address => uint256)) allowed;
    /************************************************************************************************/


    /**************************************** Documents *********************************************/
    // Mapping for documents.
    mapping(bytes32 => Doc) documents;
    mapping(bytes32 => uint256) indexOfDocHashes;
    bytes32[] docHashes;
    /************************************************************************************************/


    /*********************************** Partitions  mappings ***************************************/
    // List of partitions.
    bytes32[] totalPartitions;

    // Mapping from partition to their index.
    mapping (bytes32 => uint256) indexOfTotalPartitions;

    // Mapping from partition to global balance of corresponding partition.
    mapping (bytes32 => uint256) totalSupplyByPartition;

    // Mapping from tokenHolder to their partitions.
    mapping (address => bytes32[]) partitionsOf;

    // Mapping from (tokenHolder, partition) to their index.
    mapping (address => mapping (bytes32 => uint256)) indexOfPartitionsOf;

    // Mapping from (tokenHolder, partition) to balance of corresponding partition.
    mapping (address => mapping (bytes32 => uint256)) balanceOfByPartition;

    // List of token default partitions (for ERC20 compatibility).
    bytes32[] defaultPartitions;
    /************************************************************************************************/


    /********************************* Global operators mappings ************************************/
    // Mapping from (operator, tokenHolder) to authorized status. [TOKEN-HOLDER-SPECIFIC]
    mapping(address => mapping(address => bool)) authorizedOperator;

    // Array of controllers. [GLOBAL - NOT TOKEN-HOLDER-SPECIFIC]
    address[] controllers;

    // Mapping from operator to controller status. [GLOBAL - NOT TOKEN-HOLDER-SPECIFIC]
    mapping(address => bool) isController;
    /************************************************************************************************/


    /******************************** Partition operators mappings **********************************/
    // Mapping from (partition, tokenHolder, spender) to allowed value. [TOKEN-HOLDER-SPECIFIC]
    mapping(bytes32 => mapping (address => mapping (address => uint256))) allowedByPartition;

    // Mapping from (tokenHolder, partition, operator) to 'approved for partition' status. [TOKEN-HOLDER-SPECIFIC]
    mapping (address => mapping (bytes32 => mapping (address => bool))) authorizedOperatorByPartition;

    // Mapping from partition to controllers for the partition. [NOT TOKEN-HOLDER-SPECIFIC]
    mapping (bytes32 => address[]) controllersByPartition;

    // Mapping from (partition, operator) to PartitionController status. [NOT TOKEN-HOLDER-SPECIFIC]
    mapping (bytes32 => mapping (address => bool)) isControllerByPartition;
    /************************************************************************************************/
  }

  function _ERC1400Store() internal pure returns (ERC1400Store storage store) {
    assembly {
      // bytes32(uint256(keccak256('UniversalToken.ERC1400.ERC1400')) - 1)
      store.slot := 0xc22db64764a4c478f843b07829267db721101e4af3e18d630773bf1e860fbe6f
    }
  }
}

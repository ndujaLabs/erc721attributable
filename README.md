# Attributable
A proposal for a standard approach to attributes on chain

### THIS IS A WORK IN PROGRESS


## Premise

In 2021, I proposed a standard for on-chain attributes for NFT at https://github.com/ndujaLabs/erc721playable  

It was using an array of uint8 to store generic attributes.

After a few iterations and attempt to implement it I realized that it is very unlikely that a player, for example, a game can be fine with just storing uint8 values. Most likely it will need multiple types that defies the advantages of that approach.

Investigating the possible alternatives, I reach the conclusion that the best way to have generic values is to encode them in an array of uint256, asking the player to translate them in parameters that can be understood, for example, by a marketplace.

Let's say that you have an NFT that start in a game at level 2, but later can be leveled up. Where do you store the info about the level? If you put it in the JSON metadata, you break one of the rules of the NFT, the immutability of the attributes (very important for collectors). The solution is to split the attributes in two categories: mutable and immutable attributes.

There are a few proposal to extend the metadata provided by JSON files, like https://eips.ethereum.org/EIPS/eip-4906

The problem is that smart contracts can't read dynamic parameters off-chain, which is the problem I am trying to solve here. 

## The data

The idea is to have in the NFT a flexible format for the data, so that even if the contract is upgraded requiring a different set of information, it is still possible to upgrade the contract keeping a compatible storage. Look at this map:

```solidity
  mapping(uint256 => mapping(address => mapping(uint8 => uint256))) internal _tokenAttributes;
```

It is supposed to be used as
```solidity
_tokenAttributes[tokenId][playerAddress][index]
```
In most cases, a single index, 0, will be enough. But having the possibility of extending to a max of 256 values, cover almost every possible need.

## The interfaces

### IAttributable - the NFT should extend it

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IAttributable Cross-player On-chain Attributes
    Version: 0.0.1
   ERC165 interfaceId is
   */
/* is IERC165 */
interface IAttributable {
  /**
      @notice The comments above refer to an NFT, but the same approach can be used
              with other classes of assets.
   */

  /**
     @dev Emitted when the attributes for an id and a player is set.
          The function must be called by the owner of the asset to authorize a player to set
          attributes on it. The rules for that are left to the asset.

          This even is important because allows a marketplace to know that there are
          dynamic attributes set on the NFT by a specific contract (the player) so that
          the marketplace can query the player to get the attributes of the NFT in within
          the game.
   */
  event AttributesInitializedFor(uint256 indexed _id, address indexed _player);

  /**
     @dev It returns the on-chain attributes of a specific id
       This function is called by the player, which is able to decode the uint and
       transform them in whatever is necessary for the game.
     @param _id The id of the token for whom to query the on-chain attributes
     @param _player The address of the player's contract
     @param _index The index in the array of attributes
     @return The encoded attributes of the token
   */
  function attributesOf(
    uint256 _id,
    address _player,
    uint8 _index
  ) external view returns (uint256);

  /**
     @notice Authorize a player initializing the attributes of a token to 1
     @dev It must be called by the nft's owner to approve the player.

       To avoid that nft owners give themselves arbitrary values, they must not
       be able to set up the values, but only to create the array that later
       will be filled by the player.

       Since by default the value in the array would
       be zero, the initial value must be a uint8 representing the version of the data,
       starting with the value 1. This way the player can see if the data are initialized
       checking that the attributesOf a certain id is 1.

       The function must emit the AttributesInitiated event

     @param _id The id of the token for whom to change the attributes
     @param _player The version of the attributes
   */
  function authorizePlayer(uint256 _id, address _player) external;

  /**
     @notice Sets the attributes of a token after the initialization
     @dev It modifies attributes by id for a specific player. It must
       be called by the player's contract, after an NFT has been initialized.

       The owner of the NFT must not be able to update the attributes.

       It must revert if the asset is not initialized for that player, i.e., if
       the value returned by attributesOf is 0.

     @param _id The id of the token for whom to change the attributes
     @param _index The index of the array where the attribute is updated
     @param _attributes The encoded attributes
   */
  function updateAttributes(
    uint256 _id,
    uint8 _index,
    uint256 _attributes
  ) external;
}

```

### IPlayer - the player should extend it
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IPlayer Player of an attributable asset
    Version: 0.0.1
   ERC165 interfaceId is
   */
/* is IERC165 */
interface IPlayer {
  /**
    @dev returns the attributes in a readable way
    @param _asset The address of the asset played by the game
    @param _id The id of the asset
    @return A string with type of the attribute, name and value
  */
  function attributesOf(address _asset, uint256 _id) external view returns (string memory);
}


```

## Examples

In `/contracts/examples` there is an example of a token and a player.

Let's show here just the function attributesOf in the player:

```solidity
function attributesOf(address _nft, uint256 tokenId) external override view returns (string memory) {
    uint256 _attributes = IAttributable(_nft).attributesOf(tokenId, address(this), 0);
    if (_attributes != 0) {
      return
        string(
          abi.encodePacked(
            "uint8 version:",
            Strings.toString(uint8(_attributes)),
            ";uint8 level:",
            Strings.toString(uint16(_attributes >> 8)),
            ";uint32 stamina:",
            Strings.toString(uint32(_attributes >> 16)),
            ";address winner:",
            Strings.toHexString(uint160(_attributes >> 48), 20)
          )
        );
    } else {
      return "";
    }
  }
```
Calling it, a marketplace can get something like:
```
uint8 version:1;uint8 level:2;uint32 stamina:2436233;address winner:0x426eb88af949cd5bd8a272031badc2f80330e766
```
that can be easily transformed in a JSON like:
```JSON
{
  "version": {
    "type": "uint8",
    "value": 1    
  },
  "level": {
    "type": "uint8",
    "value": 2
  },
  "stamina": {
    "type": "uint32",
    "value": 2436233
  },
  "winner": {
    "type": "address",
    "value": "0x426eb88af949cd5bd8a272031badc2f80330e766"
  }
}
```
of something like:
```JSON
{
  "attributes": [
    {
      "trait_type": "version",
      "value": 1
    },
    {
      "trait_type": "level",
      "value": 2
    },
    {
      "trait_type": "stamina",
      "value": 2436233
    },
    {
      "trait_type": "winner",
      "value": "0x426eb88af949cd5bd8a272031badc2f80330e766"
    }
  ]
}
```

Notice that the NFT does not encode anything, it is the player who knows what the data means, that encodes it. Look at the following function in MyPlayer.sol:
```solidity
  function updateAttributesOf(
    address _nft,
    uint256 tokenId,
    TokenData memory data
  ) external {

    require(_operator != address(0) && _operator == _msgSender(), 
            "Not the operator");

    uint256 attributes = uint256(data.version) | 
                         (uint256(data.level) << 8) | 
                         (uint256(data.stamina) << 16) | 
                         (uint256(uint160(data.winner)) << 48);

    IAttributable(_nft).updateAttributes(tokenId, 0, attributes);
  }
```

# Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>

# License

MIT

# Attributable
A proposal for a standard approach to attributes on chain

### THIS IS A WORK IN PROGRESS


## Premise

In 2021, I proposed a standard for on-chain attributes for NFT at https://github.com/ndujaLabs/erc721playable

It was using an array of uint8 to store generic attributes.

After a few iterations and attempt to implement it I realized that it is very unlikely that a player, for example, a game can be fine with just storing uint8 values. Most likely it will need multiple types that defies the advantages of that approach.

Investigating the possible alternatives, I reach the conclusion that the best way to have generic values is to encode them in an array of uint256, asking the player to translate them in parameters that can be understood, for example, by a marketplace.

Let's say that you have an NFT that start in a game at level 2, but later can be leveled up. Where do you store the info about the level? If you put it in the JSON metadata, you break one of the rules of the NFT, the immutability of the attributes (very important for collectors). The solution is to split the attributes in two categories: mutable and immutable attributes.

## The interfaces

### IAttributable - the NFT should extend it

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
   */
  event AttributesInitialized(uint256 indexed _id, address indexed _player);

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
    uint256 _index
  ) external view returns (uint256);

  /**
     @notice Initialize the attributes of a token
     @dev It must be called by the nft's owner to approve the player.
       To avoid that nft owners give themselves arbitrary values, they must not
       be able to set up the values, but only to create the array that later
       will be filled by the player.
       The function should emit the AttributesInitiated event
     @param _id The id of the token for whom to change the attributes
     @param _player The version of the attributes
   */
  function authorizePlayer(uint256 _id, address _player) external returns (bool);

  /**
     @notice Sets the attributes of a token after the initialization
     @dev It modifies attributes by id for a specific player. It must
       be called by the player's contract, after an NFT has been initialized.
       The owner of the NFT must not be able to modify the attributes. If not,
       the owner can cheat on its values.
       It must revert if the asset is not initialized for that player
       It could emit an event to state the update, but that is not mandatory
       since it consumes gas and there can be many changes in the asset. 
     @param _id The id of the token for whom to change the attributes
     @param _index The index of the array where the attribute is updated
     @param _attributes The encoded attributes
   */
  function updateAttributes(
    uint256 _id,
    uint256 _index,
    uint256 _attributes
  ) external returns (bool);
}

```

### IPlayer - the player should extend it
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

  EXAMPLE:

  function attributesOf(address _asset, uint256 tokenId) external view tokenExists(tokenId) returns (string memory) {
    return
      string(
        abi.encodePacked(
          "uint8 level:",
          StringsUpgradeable.toString(uint8(_attributes[_asset][_id])),
          ";uint8 state:",
          StringsUpgradeable.toString(uint16(_attributes[_asset][_id] >> 8)),
          ";uint32 stamina:",
          StringsUpgradeable.toString(uint32(_attributes[_asset][_id] >> 16))
        )
      );
  }
  */
  function attributesOf(
    address _asset,
    uint256 _id
  ) external view returns (string memory);
}

```

## Examples

Look at the two example in `/contracts/examples`


# Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>

# License

MIT

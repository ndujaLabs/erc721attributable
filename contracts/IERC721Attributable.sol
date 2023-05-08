// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IERC721Attributable Cross-player On-chain Attributes
    Version: 0.2.0
   ERC165 interfaceId is 0xc79cd306
   */
interface IERC721Attributable {
  /**
     @dev Emitted when the attributes for an id and a player is set.
      The function must be called by the owner of the asset to authorize a player to set
      attributes on it. The rules for that are left to the asset.
      This event is important because allows a marketplace to know that there are
      dynamic attributes set on the NFT by a specific contract (the player) so that
      the marketplace can query the player to get the attributes of the NFT in within
      the game.
     @notice This is V2 of the interface. It is compatible with V1, but it does not emit the
      AttributesUpdated event anymore, replacing it with AttributesUpdated. It implies
      that any contract using this interface must be updated to use the new event.
   */
  event AttributesInitializedFor(uint256 indexed _id, address indexed _player);

  /**
   @dev Emitted when the attributes for an id are updated in relation to a specific player.
   */
  event AttributesUpdated(uint256 indexed _id, address indexed _player);

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
     @notice Authorize a player initializing the attributes of a token to a non zero value
     @dev It must be called by the owner of the nft

       To avoid that nft owners give themselves arbitrary values, they must not
       be able to set up the values, but only to create the array that later
       will be filled by the player.

       Since by default the value in the array would be zero, the initial value
       must be a non-zero value. This way the player can see if the data are initialized
       checking that the attributesOf a certain id is != 0.

       The function must emit the AttributesInitializedFor event

     @param _id The id of the token for whom to authorize the player
     @param _player The address of the player contract
   */
  function initializeAttributesFor(uint256 _id, address _player) external;

  /**
     @notice Sets the attributes of a token after the initialization
     @dev It modifies attributes by id for a specific player. It must
       be called by the player's contract, after an NFT has been initialized.

       The owner of the NFT must not be able to update the attributes.

       It must revert if the asset is not initialized for that player (the msg.sender).

       The function must emit the AttributesUpdated event

     @param _id The id of the token for whom to change the attributes
     @param _index The index of the array where the attribute is updated
     @param _attributes The encoded attributes
   */
  function updateAttributes(
    uint256 _id,
    uint256 _index,
    uint256 _attributes
  ) external;
}

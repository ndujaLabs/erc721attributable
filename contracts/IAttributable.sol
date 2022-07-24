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

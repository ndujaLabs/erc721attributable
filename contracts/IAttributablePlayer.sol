// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IAttributablePlayer Player of an attributable asset
    Version: 0.0.1
   ERC165 interfaceId is
   */
/* is IERC165 */
interface IAttributablePlayer {
  /**
    @dev returns the attributes in a readable way
    @param _asset The address of the asset played by the game
    @param _id The id of the asset
    @return A string with type of the attribute, name and value
  */
  function attributesOf(address _asset, uint256 _id) external view returns (string memory);
}

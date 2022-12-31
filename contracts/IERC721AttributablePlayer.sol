// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IERC721AttributablePlayer Player of an attributable asset
    Version: 0.0.2
   ERC165 interfaceId is 0x72261e7d
   */
interface IERC721AttributablePlayer {
  /**
    @dev returns the attributes in a readable way
    @param _asset The address of the asset played by the game
    @param _id The id of the asset
    @return A string with type of the attribute, name and value

    The expected format is a string like `uint16 level:23;uin256 power:2543344` which
    can be easily converted by a marketplace in a JSON object.

    Here an example of implementation (using OpenZeppelin /utils/Strings.sol)

    function attributesOf(
      address _nft,
      uint256 tokenId
    ) external view override
    returns (string memory) {
      uint256 _attributes = IERC721Attributable(_nft).attributesOf(tokenId, address(this), 0);
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

  */
  function attributesOf(address _asset, uint256 _id) external view returns (string memory);
}

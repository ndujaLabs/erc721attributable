// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../IERC721Attributable.sol";
import "../IERC721AttributablePlayer.sol";

contract MyPlayer is IERC721AttributablePlayer, Ownable, ERC165 {
  address internal _operator;

  struct TokenData {
    uint8 version;
    uint8 level;
    uint32 stamina;
    address winner;
  }

  // convenient function, for testing only
  function getInterfaceIds() public pure returns (bytes4, bytes4) {
    return (type(IERC721Attributable).interfaceId, type(IERC721AttributablePlayer).interfaceId);
  }

  function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
    return interfaceId == type(IERC721AttributablePlayer).interfaceId || super.supportsInterface(interfaceId);
  }

  function setOperator(address operator) external onlyOwner {
    _operator = operator;
  }

  function updateAttributesOf(
    address _nft,
    uint256 tokenId,
    TokenData memory data
  ) external {
    require(_operator != address(0) && _operator == _msgSender(), "Not the operator");
    uint256 attributes = 1 | (uint256(data.level) << 8) | (uint256(data.stamina) << 16) | (uint256(uint160(data.winner)) << 48);
    IERC721Attributable(_nft).updateAttributes(tokenId, 0, attributes);
  }

  function attributesOf(address _nft, uint256 tokenId) external view override returns (string memory) {
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

}

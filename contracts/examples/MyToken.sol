// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../IERC721Attributable.sol";

contract MyToken is ERC721, Ownable, IERC721Attributable {
  constructor() ERC721("MyToken", "MTK") {}

  uint256 internal _nextTokenId = 1;
  mapping(uint256 => mapping(address => mapping(uint256 => uint256))) internal _tokenAttributes;

  function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
    return interfaceId == type(IERC721Attributable).interfaceId || super.supportsInterface(interfaceId);
  }

  function attributesOf(
    uint256 _id,
    address _player,
    uint256 _index
  ) external view override returns (uint256) {
    return _tokenAttributes[_id][_player][_index];
  }

  function initializeAttributesFor(uint256 _id, address _player) external override {
    require(ownerOf(_id) == _msgSender(), "Not the owner");
    require(_tokenAttributes[_id][_player][0] == 0, "Player already authorized");
    // this must be initialized to a non zero value.
    // In this case, 1 could be the version of the data
    _tokenAttributes[_id][_player][0] = 1;
    emit AttributesInitializedFor(_id, _player);
  }

  function updateAttributes(
    uint256 _id,
    uint256 _index,
    uint256 _attributes
  ) external override {
    require(_tokenAttributes[_id][_msgSender()][0] != 0, "Player not authorized");
    // notice that, using the non zero value as a proof of authorization
    // if the player set the attributes to zero, it de-authorize itself
    // and not more changes will be allowed until the NFT owner authorize it again.
    // Alternatively, the it could use a separate boolean to track the authorized players
    // but that would take extra gas without a clear advantage.
    _tokenAttributes[_id][_msgSender()][_index] = _attributes;
    emit AttributesUpdated(_id);
  }

  function mint(address to) external onlyOwner {
    _safeMint(to, _nextTokenId++);
  }

}

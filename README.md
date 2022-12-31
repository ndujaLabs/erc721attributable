# ERC721Attributable
A proposal for a standard approach to manage attributes on chain for NFTs

## Premise

In 2021, I proposed a standard for on-chain attributes for NFT at https://github.com/ndujaLabs/erc721playable  

It was using an array of uint8 to store generic attributes.

After a few iterations and attempts to implement it, I realized that it is unlikely that a player, for example, a game, can be okay with just storing uint8 values. It will most likely need multiple types that defy the advantages of that approach.

Investigating the possible alternatives, I concluded that the best way to have generic values is to encode them in an array of uint256, asking the player to translate them into parameters that can be understood, for example, by a marketplace.

Let's say you have an NFT that starts in a game at level 2 but later can level up. Where do you store the info about the level? If you put it in the JSON metadata, you break one of the rules of the NFT, the immutability of the attributes (essential for collectors). The solution is to split the attributes into two categories: mutable and immutable attributes.

There are a few proposals to extend the metadata provided by JSON files (like https://eips.ethereum.org/EIPS/eip-4906). The problem is that smart contracts can't read dynamic parameters off-chain, which is the problem I am trying to solve here.

## Why do we need a common standard for on-chain metadata?

People talks every day about having NFTs that can be moved around games. The problem is that, despite the good intention, that is not possible in most cases. A standard NFT is not intended for it. What it misses is the flexibility necessary to allow any player out there (a game, a metaverse, whatever) to use the NFT inside a game, in total transparency, and in a shared way. The idea behind ERC721Attributable is that your NFT:

1. can be used by any game, i.e., any game access the data in the same format, encoding/decoding them for its purposes
2. only the NFT owner can authorize the game
3. only the game can modify its attributes

Point 2 is necessary because you don't want any player adds data to your NFT. For example, a porn game can add you PfP. Maybe you don't like it. For sure, you don't want it if the player is involved in some criminal activity.

Point 3 is necessary because you can cheat after you authorize a game if you alter the data that the game sets. For example, in Mobland, a character can be wounded and go into a coma. If that character is not cured in the maximum allowed time, the character will die. On the market, a dead character will probably have a much lower value than a character in good health. But, right now, there is no way to get it. If the character is ERC721Attributable, that value can be stored in the NFT and be visible to anyone.

How? A marketplace like OpenSea can listen to the emitted event and record any new authorization. Then, it can query the authorized game to get the on-chain attributes of that NFT. (Of course, the game can also set off-chain dynamic attributes to make its data more broadly available.)

Point 1 is essential. The data must be stored most generically to allow cross-game maneuverability. The choice then is between uint256 and bytes32. My preference is for using big integers because it looks to be easier to play with.

When you have big integers that encode information, you just need a map based on tokenId and game address. A basic approach would be setting the data as:

```solidity
mapping(uint256 => mapping(address => uint256)) internal _tokenAttributes;
```
The problem is that a single integer may not be enough. A better solution is to have an "array" of big integers. My preferred variable would be

```solidity
mapping(uint256 => mapping(address => mapping(uint256 => uint256))) internal _tokenAttributes;
```

Regardless, the optimal data format is not central, and the choice of what to use is left to the implementation of the NFT. What is more important here is to define how the NFT (or any other asset with an ID) interfaces with the player.

## The interfaces

### IERC721Attributable - the NFT should extend it

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
   @title IERC721Attributable Cross-player On-chain Attributes
    Version: 0.0.4
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
   */
  event AttributesInitializedFor(uint256 indexed _id, address indexed _player);

  /**
   @dev Emitted when the attributes for an id are updated.
   */
  event AttributesUpdated(uint256 indexed _id);

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


```

### IERC721AttributablePlayer - the player should extend it
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <francesco@sullo.co>

/**
   @title IERC721AttributablePlayer Player of an attributable asset
    Version: 0.0.1
   ERC165 interfaceId is 0x72261e7d
   */
interface IERC721AttributablePlayer {
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

Notice that the NFT does not encode anything, it is the player who knows what the data means, and encodes the data. Look at the following function in MyPlayer.sol:
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

    IERC721Attributable(_nft).updateAttributes(tokenId, 0, attributes);
  }
```

## Install and usage

To install it, launch 
``` 
npm i -d @ndujalabs/attributable
```

You may need to install the peer dependencies too, i.e., the OpenZeppelin contracts.

To use it, in your smart contract import it as
```solidity

import "@ndujalabs/attributable/contracts/IERC721Attributable.sol";
import "@ndujalabs/attributable/contracts/IERC721AttributablePlayer.sol";
```

## Implementations

1. **Everdragons2GenesisV3** https://github.com/ndujaLabs/everdragons2-core/blob/main/contracts/V2-V3/Everdragons2GenesisV3.sol

1. **MOBLAND In-game Assets** https://github.com/superpowerlabs/in-game-assets/blob/main/contracts/SuperpowerNFTBase.sol#L128~~~~

Feel free to make a PR to add your implementation.

## History

**0.1.0**
- Renamed from **Attributable** to **ERC721Attributable** for clarity

**0.0.4**
- Add event AttributesUpdated

**0.0.3**
- Moved from uint8 to uint256 in functions
- Rename `authorizePlayer` to `initializePlayerFor` in `IAttributable`
- Interface ID has changed, breaking the compatibility with previous implementations

**0.0.2**
- Renamed IPlayer to IAttributablePlayer to avoid a too generic name.

## Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>
~~~~
## License

MIT

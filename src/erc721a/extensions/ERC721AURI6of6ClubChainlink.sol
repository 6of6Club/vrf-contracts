// SPDX-License-Identifier: MIT
// ERC721AURI6of6Club Contracts v0.0.1 (Chainlink VRF)
// Creator: RockArt 🪨 AI

pragma solidity ^0.8.19;

import "../ERC721A.sol";
import "../utils/MarketSale.sol";
import "../../openzeppelin-contracts/utils/Strings.sol";
import "../../openzeppelin-contracts/utils/Base64.sol";

import "../../chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "../../chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "../../chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

abstract contract ERC721AURI6of6Club is 
  ERC721A, 
  MarketSale,
  VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed), // POLYGON HARDCODE!
  ConfirmedOwner(0xB0D717A36CECdE978Bfbff1E3A06cb20153ca45c) // POLYGON HARDCODE!
{
  VRFCoordinatorV2Interface COORDINATOR = 
    VRFCoordinatorV2Interface(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed); // POLYGON HARDCODE!

  using Strings for uint256;

  struct Token {
    uint64 member_id;        // Member ID
    uint16 cartridges;       // 1 - 5
    uint16 prevrandao;       // 1 - 6
    uint16 mascot;           // 0 - 15
    uint16 cartridge_red;    // 1 - 86
    uint16 cartridge_green;  // 1 - 221
    uint16 cartridge_blue;   // 1 - 221
    uint16 background_red;   // 1 - 100
    uint16 background_green; // 1 - 100
    uint16 background_blue;  // 1 - 100
    uint16 gradient_red;     // 155 - 255
    uint16 gradient_green;   // 155 - 255
    uint16 gradient_blue;    // 155 - 255
  }

  mapping(uint256 => uint256[]) private _request;
  uint64 public numberOfMembers;
  mapping(uint64 => uint256) public member;
  mapping(uint256 => Token) public token;

  string[16] private _mascot = [
    unicode"🐶", unicode"🐱", unicode"🐭", unicode"🐹",
    unicode"🐰", unicode"🦊", unicode"🐻", unicode"🐼",
    unicode"🐻‍❄️", unicode"🐨", unicode"🐯", unicode"🦁",
    unicode"🐮", unicode"🐷", unicode"🐸", unicode"🐵"
  ];

  string[6] private _cx = ["71.6", "71.6", "50", "28.5", "28.5", "50"];
  string[6] private _cy = ["37.5", "62.6", "75", "62.6", "37.5", "25"];
  string[3] private _r = ["9", "6", "5"];
  string[3] private _red = ["cc0000", "bb0000", "dd0000"];

  function _beforeTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual override {
    uint256 stop = startTokenId + quantity;
    uint32 _numWords;
    uint256[] memory _tokenIds = new uint256[](quantity);

    for (uint256 tokenId = startTokenId; tokenId < stop; tokenId++) {
      if (from == address(0)) {
        _tokenIds[_numWords] = tokenId;
        _numWords++;
      } else if (isSale()) {
        Token storage info = token[tokenId];

        if (
          info.prevrandao == 0 ||
          (
            info.cartridges < 5 &&
            info.cartridges < info.prevrandao
          )
        ) {
           _tokenIds[uint256(_numWords)] = tokenId;
           _numWords++;
        }
      }
    }

    if (_numWords > 0) {
      uint256 requestId = COORDINATOR.requestRandomWords(
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f,
        5102,
        3,
        500000,
        _numWords
      ); 
      _request[requestId] = _tokenIds;
    }
    
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }

  function fulfillRandomWords(
    uint256 requestId_,
    uint256[] memory randomWords_
  ) internal override {
    for (uint256 i = 0; i < randomWords_.length; i++) {
      uint256 tokenId = _request[requestId_][i];
      uint256 random = randomWords_[i] > type(uint128).max
        ? randomWords_[i]
        : randomWords_[i] + type(uint128).max;

      Token storage info = token[tokenId];

      if (
        info.prevrandao == 0
      ) {
        token[tokenId] = Token({
          member_id: 0,
          cartridges: 1,
          prevrandao: uint16(random % 6 + 1),
          mascot: uint16(random % 16),
          cartridge_red: uint16((random % 10**3) % 86 + 1),
          cartridge_green: uint16(((random / 10**3) % 10**3) % 221 + 1),
          cartridge_blue: uint16(((random / 10**6) % 10**3) % 221 + 1),
          background_red: uint16(((random / 10**9) % 10**3) % 100 + 1),
          background_green: uint16(((random / 10**12) % 10**3) % 100 + 1),
          background_blue: uint16(((random / 10**15) % 10**3) % 100 + 1),
          gradient_red: uint16(((random / 10**18) % 10**3) % 155 + 100),
          gradient_green: uint16(((random / 10**21) % 10**3) % 155 + 100),
          gradient_blue: uint16(((random / 10**24) % 10**3) % 155 + 100)
        });
      }
      else if (
          info.cartridges < 5 &&
          info.cartridges < info.prevrandao
      ) {
        info.cartridges += 1;
        info.prevrandao = uint16(random % 6 + 1);

        if (info.prevrandao == 6 && info.cartridges == 5) {
          numberOfMembers += 1;
          member[numberOfMembers] = tokenId;

          info.member_id = numberOfMembers;
        }
      }
    }
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    return string(abi.encodePacked(
      'data:application/json;utf8,',
      abi.encodePacked(
        '{"name":"', name(tokenId),
        '","description":"', unicode'[ BUY = +1 of 6 ] ⇢ [ lost 🔴 | 🟢 win ] ⇢ [ SELL = +1 of 6 ]',
        '","external_url":"https://6of6club.eth.limo',
        '","background_color":"', backgroundColor(tokenId),
        '","attributes":', attributes(tokenId),
        ',"image":"', image(tokenId),
        '"}'
      )
    ));
  }

  function name(
    uint256 tokenId
  ) internal view returns (string memory) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);

    return string(abi.encodePacked(
      (p == 6 && c == 5 ? 6 : c).toString(),
      'of6 Club #',
      tokenId.toString()
    ));
  }

  function image(
    uint256 tokenId
  ) internal view returns (string memory) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);

    string[3] memory fill = [
      RGBToHex(
        token[tokenId].cartridge_red + 17,
        token[tokenId].cartridge_green + 17,
        token[tokenId].cartridge_blue + 17
      ),
      RGBToHex(
        token[tokenId].cartridge_red,
        token[tokenId].cartridge_green,
        token[tokenId].cartridge_blue
      ),
      RGBToHex(
        token[tokenId].cartridge_red + 34,
        token[tokenId].cartridge_green + 34,
        token[tokenId].cartridge_blue + 34
      )
    ];

    return string(abi.encodePacked(
      'data:image/svg+xml;base64,',
      Base64.encode(abi.encodePacked(
        '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><defs>',
        radialGradient(tokenId),
        style(tokenId),
        '</defs>',
        (c > 0 ? cartridges(c, fill) : bytes('')),
        (p > 0 ? cartridge(p, c < p ? fill : _red) : bytes('')),
        '<path d="m88.408 38.831c-1.823-6.278-5.14-11.916-9.545-16.508-3.834 0.265-7.785-0.568-11.363-2.634-3.583-2.069-6.283-5.079-7.97-8.537-3.055-0.747-6.245-1.152-9.53-1.152s-6.475 0.405-9.53 1.152c-1.687 3.459-4.387 6.469-7.97 8.537-3.578 2.066-7.529 2.899-11.363 2.634-4.405 4.592-7.722 10.23-9.545 16.508 2.151 3.189 3.408 7.032 3.408 11.169s-1.257 7.98-3.408 11.169c1.823 6.278 5.14 11.916 9.545 16.508 3.834-0.265 7.785 0.568 11.363 2.634 3.583 2.069 6.283 5.079 7.97 8.538 3.055 0.746 6.245 1.151 9.53 1.151s6.475-0.405 9.53-1.152c1.687-3.459 4.387-6.469 7.97-8.538 3.578-2.066 7.529-2.899 11.363-2.634 4.405-4.592 7.722-10.23 9.545-16.508-2.151-3.188-3.408-7.031-3.408-11.168s1.257-7.98 3.408-11.169zm-25.417-6.331c2.761-4.783 8.877-6.421 13.659-3.66 4.783 2.761 6.421 8.877 3.66 13.659-2.761 4.783-8.877 6.421-13.659 3.66-4.783-2.761-6.421-8.877-3.66-13.659zm-25.984 35c-2.761 4.783-8.877 6.421-13.659 3.66-4.783-2.761-6.421-8.877-3.66-13.659 2.761-4.783 8.877-6.421 13.659-3.66 4.783 2.761 6.422 8.876 3.66 13.659zm-8.659-20.001c-5.522 0-9.999-4.477-9.999-9.999s4.477-9.999 9.999-9.999 9.999 4.477 9.999 9.999-4.477 9.999-9.999 9.999zm26.651 36.161c-4.783 2.762-10.898 1.123-13.659-3.66s-1.123-10.898 3.66-13.659 10.898-1.123 13.659 3.66 1.122 10.898-3.66 13.659zm-9.999-33.66c0-2.761 2.239-5 5-5s5 2.239 5 5-2.239 5-5 5-5-2.239-5-5zm9.999-16.341c-4.783 2.761-10.898 1.123-13.659-3.66-2.762-4.783-1.123-10.898 3.66-13.659s10.898-1.123 13.659 3.66c2.761 4.782 1.122 10.897-3.66 13.659zm16.652 38.841c-5.522 0-9.999-4.477-9.999-9.999s4.477-9.999 9.999-9.999 9.999 4.477 9.999 9.999-4.477 9.999-9.999 9.999z" fill="url(#a)"></path>',
        (p == 6 && c == 5 ? mascot(tokenId) : bytes('')),
        '</svg>'
      ))
    ));
  }

  function radialGradient(
    uint256 tokenId
  ) internal view returns (bytes memory) {
    (string memory start, string memory stop) = gradientColor(tokenId);

    return abi.encodePacked(
      '<radialGradient id="a"><stop stop-color="#',
      start,
      '" offset="0"/><stop stop-color="#',
      stop,
      '" offset="1"/></radialGradient>'
    );
  }

  function style(
    uint256 tokenId
  ) internal view returns (bytes memory) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);

    return abi.encodePacked(
      '<style><![CDATA[svg{overflow:hidden;background:#',
      backgroundColor(tokenId),
      ';animation:5s ease-in-out 1s forwards r}@keyframes r{0%{transform:rotateZ(0)}100%{transform:rotateZ(',
      (1800 - 60 * p).toString(),
      'deg)}}circle:nth-of-type(-n+3){opacity:0;animation:1s ease-in-out forwards f}circle:nth-last-of-type(-n+3){opacity:0;', 
      (p <= c || c == 5 ? 'animation:1s ease-in-out 6s forwards f' : ''),
      '}text{opacity:0;', 
      (p == 6 && c == 5 ? 'animation:1s ease-in-out 6s forwards f' : ''), 
      '}@keyframes f{0%{opacity:0}100%{opacity:1}}]]></style>'
    );
  }

  function mascot(
    uint256 tokenId
  ) internal view returns (bytes memory) {
    uint256 p = uint256(token[tokenId].prevrandao);

    return abi.encodePacked(
      '<text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" style="font-size: 20px;" transform="rotate(',
      (60 * p).toString(),
      ', 50, 50)">',
      _mascot[token[tokenId].mascot],
      '</text>'
    );
  }

  function cartridges(
    uint256 max,
    string[3] memory fill
  ) internal view returns (bytes memory) {
    bytes memory result;
    for (uint256 i = max; i >= 1; i--) {
      result = abi.encodePacked(
        result,
        cartridge(i, fill)
      );
    }
    return result;
  }

  function cartridge(
    uint256 position,
    string[3] memory fill
  ) internal view returns (bytes memory) {
    return abi.encodePacked(
      circle(_cx[position - 1], _cy[position - 1], _r[0], fill[0]),
      circle(_cx[position - 1], _cy[position - 1], _r[1], fill[1]),
      circle(_cx[position - 1], _cy[position - 1], _r[2], fill[2])
    );
  }

  function circle(
    string memory cx,
    string memory cy,
    string memory r,
    string memory fill
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(
      '<circle cx="', cx,
      '" cy="', cy,
      '" r="', r,
      '" fill="#', fill,
      '"></circle>'
    );
  }

  function attributes(
    uint256 tokenId
  ) internal view returns (bytes memory) {
    return abi.encodePacked(
      '[{"trait_type": "CARTRIDGES", "value": "',
      typeCartridges(tokenId), '"},',
      '{"trait_type": "MASCOT", "value": "',
      typeMascot(tokenId), '"},',
      '{"trait_type": "MEMBER ID", "value": "', 
      typeMemberId(tokenId), '"}]'
    );
  }

  function typeCartridges(
    uint256 tokenId
  ) internal view returns (bytes memory cs) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);

    bool q;
    for (uint256 i = 1; i <= 6; i++) {
      if (i <= c) {
        if (i == c && p <= c) {
          cs = abi.encodePacked(cs, unicode"🔴");
          q = true;
        } else {
          cs = abi.encodePacked(cs, unicode"🟢");
        }
      } else {
        if (q) {
          cs = abi.encodePacked(cs, unicode"⚪️");
        } else {
          if (c == 5 && p == 6) {
            cs = abi.encodePacked(cs, unicode"🟢");
          } else {
            cs = abi.encodePacked(cs, unicode"❔");
            q = true;
          }
        }
      }
    }
  }

  function typeMascot(
    uint256 tokenId
  ) internal view returns (string memory) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);

    return c > 0 && c >= p
      ? unicode"🔴"
      : p == 6 && c == 5
        ? _mascot[token[tokenId].mascot]
        : unicode"❔";
  }

  function typeMemberId(
    uint256 tokenId
  ) internal view returns (string memory) {
    uint256 c = uint256(token[tokenId].cartridges);
    uint256 p = uint256(token[tokenId].prevrandao);
    uint256 m = uint256(token[tokenId].member_id);

    return p == 6 && c == 5
      ? m.toString() 
      : "Non-member";
  }

  function clubMember(
    uint64 id
  ) public view returns (string memory) {
    require(member[id] > 0);
    return tokenURI(member[id]);
  }

  function RGBToHex(
    uint64 r,
    uint64 g,
    uint64 b
  ) pure public returns (string memory) {
    uint256 decimalValue = (uint256(r) << 16) | (uint256(g) << 8) | uint256(b);
    uint256 remainder;
    bytes memory hexResult = "";
    string[16] memory hexDictionary = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];

    while (decimalValue > 0) {
        remainder = decimalValue % 16;
        string memory hexValue = hexDictionary[remainder];
        hexResult = abi.encodePacked(hexValue, hexResult);
        decimalValue = decimalValue / 16;
    }
    
    uint len = hexResult.length;

    if (len == 5) {
        hexResult = abi.encodePacked("0", hexResult);
    } else if (len == 4) {
        hexResult = abi.encodePacked("00", hexResult);
    } else if (len == 3) {
        hexResult = abi.encodePacked("000", hexResult);
    } else if (len == 4) {
        hexResult = abi.encodePacked("0000", hexResult);
    }

    return string(hexResult);
  }

  function backgroundColor(
    uint256 tokenId
  ) view public returns (string memory) {
    return RGBToHex(
      token[tokenId].background_red,
      token[tokenId].background_green,
      token[tokenId].background_blue
    );
  }

  function gradientColor(
    uint256 tokenId
  ) view public returns (string memory, string memory) {
    return (
      RGBToHex(
        token[tokenId].cartridge_red + token[tokenId].cartridge_red % 34,
        token[tokenId].cartridge_green + token[tokenId].cartridge_green % 34,
        token[tokenId].cartridge_blue + token[tokenId].cartridge_blue % 34
      ),
      RGBToHex(
        token[tokenId].gradient_red,
        token[tokenId].gradient_green,
        token[tokenId].gradient_blue
      )
    );
  }
}

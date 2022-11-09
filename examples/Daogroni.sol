// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./libs/base64.sol";
import "./interfaces/IManagerBaal.sol";

import "hardhat/console.sol";

interface IWRAPPER {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract Daogroni is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    IManagerBaal public moloch;
    IWRAPPER public wrapper;
    uint256 public price = 200000000000000000000;
    uint256 public cap = 200;
    uint256 public lootPerUnit = 100;
    uint256 public platformFee = 3;

    string[5] keys = [
        "boulevardier",
        "BermudaHundred",
        "manhatten",
        "negroni",
        "whtnegroni"
    ];
    string[5] names = [
        "Boulevardier",
        "Bermuda Hundred",
        "Manhattan",
        "Negroni",
        "White Negroni"
    ];
    string[5] cores = ["Bourbon", "Gin", "Rye", "Gin", "Gin"];
    string[5] lengtheners = [
        "Sweet Vermouth",
        "None",
        "Sweet Vermouth",
        "Sweet Vermouth",
        "Lillet Blanc"
    ];
    string[5] modifiers = ["Campari", "Campari", "Bitters", "Campari", "Suze"];
    string[5] props = ["None", "Umbrella", "Toothpick", "None", "None"];
    string[5] garnishes = [
        "Orange Twist",
        "Brandied Cherry",
        "Brandied Cherry",
        "Orange Slice",
        "Lemon Twist"
    ];
    string[5] ice = ["Up", "Rocks", "Up", "Rocks", "Rocks"];
    string[5] glassware = [
        "Coupe",
        "Tumbler",
        "Martini Glass",
        "Tumbler",
        "Highbaal"
    ];

    mapping(uint256 => uint256) public orders;
    mapping(uint256 => uint8) public redeems; // tokenid to bool

    constructor(address _moloch, address _wrapper) ERC721("Daogroni", "GRONI") {
        moloch = IManagerBaal(_moloch);
        wrapper = IWRAPPER(_wrapper);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://daohaus.mypinata.cloud/ipfs/";
    }

    // orderId is the order of the drink type in names
    function orderDrink(address _to, uint256 _orderId) public payable {
        require(msg.value >= price, "not enough to order");
        require(_orderId < keys.length, "not a valid drink order");
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < cap, "bar is empty");
        // wrap
        (bool success, ) = address(wrapper).call{value: price}("");
        require(success, "Wrap failed");
        // send to dao
        require(wrapper.transfer(moloch.target(), price), "Transfer failed");

        if (msg.value > price) {
            // Return the extra money to the minter.
            (bool success2, ) = msg.sender.call{value: msg.value - price}("");
            require(success2, "Transfer failed.");
        }

        orders[tokenId + 1] = _orderId;
        _safeMint(_to, tokenId + 1);
        _tokenIdCounter.increment();

        // TODO fix to mintLoot
        moloch.setSingleSharesLoot(
            address(0xdead),
            0,
            lootPerUnit,
            true
        );
        moloch.setSingleSharesLoot(
            owner(),
            0,
            platformFee,
            true
        );

        moloch.collectTokens(address(wrapper));
    }

    function redeem(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "must own drink");
        redeems[tokenId] = 1;

        // TODO fix to mintShares / burnLoot
        moloch.setSingleSharesLoot(address(0xdead), 0, lootPerUnit, false);
        moloch.setSingleSharesLoot(msg.sender, 0, lootPerUnit, true);
    }

    function _drinkState(uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        if (redeems[_tokenId] == 1) {
            return string("-empty");
        } else {
            return string("");
        }
    }

    /**  Constructs the tokenURI, separated out from the public function as its a big function.
     * Generates the json data URI and svg data URI that ends up sent when someone requests the tokenURI
     * svg has a image tag that can be updated by the owner (dao)
     * param: _tokenId the tokenId
     */
    function _constructTokenURI(uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        string memory _nftName = string(
            abi.encodePacked("DAOgroni: ", names[orders[_tokenId]])
        );
        console.log("_nftName", _nftName);

        bytes memory _image = abi.encodePacked(
            _baseURI(),
            "QmaCBoYHdQ9u7zwp1Sxxaig1yfuocTLzk9iAr1m1ahukBK",
            "/daogroni-",
            keys[orders[_tokenId]],
            _drinkState(_tokenId),
            ".svg"
        );

        bytes memory _ingredients = abi.encodePacked(
            '{"trait_type": "Core", "value": "',
            cores[orders[_tokenId]],
            '"},',
            '{"trait_type": "Lengtheners", "value": "',
            lengtheners[orders[_tokenId]],
            '"},',
            '{"trait_type": "Modifiers", "value": "'
        );

        bytes memory _stuff = abi.encodePacked(
            modifiers[orders[_tokenId]],
            '"},',
            '{"trait_type": "Props", "value": "',
            props[orders[_tokenId]],
            '"},',
            '{"trait_type": "Garnishes", "value": "',
            garnishes[orders[_tokenId]],
            '"},',
            '{"trait_type": "Ice", "value": "',
            ice[orders[_tokenId]],
            '"},',
            '{"trait_type": "Glassware", "value": "',
            glassware[orders[_tokenId]],
            '"}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _nftName,
                                '", "image":"',
                                _image,
                                '", "description": "Drink Responsibly", "orderId": "',
                                Strings.toString(orders[_tokenId]),
                                '","redeemed": "',
                                Strings.toString(redeems[_tokenId]),
                                '", "attributes":[{"trait_type": "Drank", "value": "',
                                Strings.toString(redeems[_tokenId]),
                                '"},',
                                _ingredients,
                                _stuff,
                                "]}"
                            )
                        )
                    )
                )
            );
    }

    /* Returns the json data associated with this token ID
     * param _tokenId the token ID
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(_constructTokenURI(_tokenId));
    }
}


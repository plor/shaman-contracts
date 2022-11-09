// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IManagerBaal.sol";

contract OnboarderShaman is ReentrancyGuard {
    event YeetReceived(
        address indexed contributorAddress,
        uint256 amount,
        address baal,
        uint256 lootToGive,
        uint256 lootToPlatform
    );
    mapping(address => uint256) public deposits;
    uint256 public maxTarget;
    uint256 public raiseEndTime;
    uint256 public raiseStartTime;
    uint256 public maxUnitsPerAddr;
    uint256 public pricePerUnit;
    uint256 public lootPerUnit;
    bool public onlyERC20;
    bool public initialized;

    uint256 public platformFee;

    uint256 public balance;
    IManagerBaal public baal;
    IERC20 public token;

    OnboarderShamanSummoner factory;

    function init(
        address _baal,
        address payable _token, // use wraper for native yeets
        uint256 _maxTarget, // max raise target
        uint256 _raiseEndTime,
        uint256 _raiseStartTime,
        uint256 _maxUnits, // per individual
        uint256 _pricePerUnit,
        bool _onlyERC20,
        uint256 _platformFee, 
        uint256 _lootPerUnit
    ) public {
        require(!initialized, "already initialized");
        initialized = true;
        baal = IManagerBaal(_baal);
        token = IERC20(_token);
        maxTarget = _maxTarget;
        raiseEndTime = _raiseEndTime;
        raiseStartTime = _raiseStartTime;
        maxUnitsPerAddr = _maxUnits;
        pricePerUnit = _pricePerUnit;
        onlyERC20 = _onlyERC20;
        platformFee = _platformFee;
        lootPerUnit = _lootPerUnit;
        factory = OnboarderShamanSummoner(msg.sender);
    }

    function initTemplate() public {
        initialized = true;
    }

    function onboarder20(uint256 _value) public nonReentrant {
        require(address(baal) != address(0), "!init");
        // require(msg.value >= pricePerUnit, "< minimum");
        require(balance < maxTarget, "Max Target reached"); // balance plus newvalue
        require(block.timestamp < raiseEndTime, "Time is up");
        require(block.timestamp > raiseStartTime, "Not Started");
        require(baal.isManager(address(this)), "Shaman not whitelisted");

        require(_value % pricePerUnit == 0, "!valid amount"); // require value as multiple of units

        uint256 numUnits = _value / pricePerUnit;

        // if some one yeets over max should we give them the max and return leftover.
        require(
            deposits[msg.sender] + _value <= maxUnitsPerAddr * pricePerUnit,
            "Can not deposit more than max"
        );

        // send to dao
        require(token.transferFrom(msg.sender, baal.target(), _value), "Transfer failed");


        // TODO: check
        deposits[msg.sender] = deposits[msg.sender] + _value;

        balance = balance + _value;

        uint256 lootToGive = (numUnits * lootPerUnit);
        uint256 lootToPlatform = (numUnits * platformFee);

        address[] memory recs = new address[](1);
        recs[0] = msg.sender;
        uint256[] memory gives = new uint256[](1);
        gives[0] = lootToGive;

        baal.mintLoot(recs, gives);
        if (lootToPlatform > 0) {
            address[] memory platRecs = new address[](1);
            platRecs[0] = address(factory);
            uint256[] memory platGives = new uint256[](1);
            platGives[0] = lootToPlatform;
            baal.mintLoot(platRecs, platGives);
        }

        // amount of loot? fees?
        emit YeetReceived(
            msg.sender,
            _value,
            address(baal),
            lootToGive,
            lootToPlatform
        );
    }

    function onboarder() public payable nonReentrant {
        require(!onlyERC20, "!native");
        require(address(baal) != address(0), "!init");
        require(msg.value >= pricePerUnit, "< minimum");
        require(balance < maxTarget, "Max Target reached"); // balance plus newvalue
        require(block.timestamp < raiseEndTime, "Time is up");
        require(block.timestamp > raiseStartTime, "Not Started");
        require(baal.isManager(address(this)), "Shaman not whitelisted");


        uint256 numUnits = msg.value / pricePerUnit; // floor units
        uint256 newValue = numUnits * pricePerUnit;

        // if some one yeets over max should we give them the max and return leftover.
        require(
            deposits[msg.sender] + newValue <= maxUnitsPerAddr * pricePerUnit,
            "Can not deposit more than max"
        );

        // wrap
        (bool success, ) = address(token).call{value: newValue}("");
        require(success, "Wrap failed");
        // send to dao
        require(token.transfer(baal.target(), newValue), "Transfer failed");

        if (msg.value > newValue) {
            // Return the extra money to the minter.
            (bool success2, ) = msg.sender.call{value: msg.value - newValue}(
                ""
            );
            require(success2, "Transfer failed");
        }
        // TODO: check
        deposits[msg.sender] = deposits[msg.sender] + newValue;

        balance = balance + newValue;

        uint256 lootToGive = (numUnits * lootPerUnit);
        uint256 lootToPlatform = (numUnits * platformFee);

        address[] memory recs = new address[](1);
        recs[0] = msg.sender;
        uint256[] memory gives = new uint256[](1);
        gives[0] = lootToGive;

        baal.mintLoot(recs, gives);
        if (lootToPlatform > 0) {
            address[] memory platRecs = new address[](1);
            platRecs[0] = address(factory);
            uint256[] memory platGives = new uint256[](1);
            platGives[0] = lootToPlatform;
            baal.mintLoot(platRecs, platGives);
        }

        // amount of loot? fees?
        emit YeetReceived(
            msg.sender,
            newValue,
            address(baal),
            lootToGive,
            lootToPlatform
        );
    }

    receive() external payable {
        onboarder();
    }

    function goalReached() public view returns (bool) {
        return balance >= maxTarget;
    }
}

contract CloneFactory {
    // implementation of eip-1167 - see https://eips.ethereum.org/EIPS/eip-1167
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}

contract OnboarderShamanSummoner is CloneFactory, Ownable {
    address payable public template;

    event SummonOnboarderShamanComplete(
        address indexed baal,
        address onboarder,
        address wrapper,
        uint256 maxTarget,
        uint256 raiseEndTime,
        uint256 raiseStartTime,
        uint256 maxUnits,
        uint256 pricePerUnit,
        string details,
        bool _onlyERC20
    );

    constructor(address payable _template) {
        template = _template;
        OnboarderShaman _onboarder = OnboarderShaman(_template);
        _onboarder.initTemplate();
    }

    function summonOnboarder(
        address _baal,
        address payable _token,
        uint256 _maxTarget,
        uint256 _raiseEndTime,
        uint256 _raiseStartTime,
        uint256 _maxUnits,
        uint256 _pricePerUnit,
        string calldata _details,
        bool _onlyERC20,
        uint256 _platformFee, 
        uint256 _lootPerUnit
    ) public returns (address) {
        OnboarderShaman onboarder = OnboarderShaman(payable(createClone(template)));

        onboarder.init(
            _baal,
            _token,
            _maxTarget,
            _raiseEndTime,
            _raiseStartTime,
            _maxUnits,
            _pricePerUnit,
            _onlyERC20,
            _platformFee,
            _lootPerUnit
        );


        emit SummonOnboarderShamanComplete(
            _baal,
            address(onboarder),
            _token,
            _maxTarget,
            _raiseEndTime,
            _raiseStartTime,
            _maxUnits,
            _pricePerUnit,
            _details,
            _onlyERC20
        );

        return address(onboarder);
    }

}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/CloneFactory.sol";
import "./utils/IBAAL.sol";

contract DuesShaman is ReentrancyGuard {

    uint256 public duesAmount;
    uint256 public duesPeriod;
    uint256 public sharePerPeriod;

    bool public onlyERC20;
    bool public initialized;

    IBAAL public baal;
    IERC20 public token;

    DuesShamanSummoner factory;

    uint256 public epoch;
    mapping(address => uint256) public paidThroughPeriod;

    function init(
        address _baal,
        address payable _token, // use wrapper addr for native
        uint256 _duesAmount,
        uint256 _duesPeriod,
        uint256 _sharesPerPeriod,
        bool _onlyERC20
    ) public {
        require(!initialized, "already initialized");
        require(_duesPeriod > 0, "period must be >0");
        initialized = true;
        baal = IBAAL(_baal);
        token = IERC20(_token);
        duesAmount = _duesAmount;
        duesPeriod = _duesPeriod;
        sharePerPeriod = _sharesPerPeriod;
        onlyERC20 = _onlyERC20;
        factory = DuesShamanSummoner(msg.sender);
    }

    function initTemplate() public {
        initialized = true;
    }

    modifier validPayment {
        require(now > epoch, "must wait until initial dues period");
        require(paidThroughPeriod[msg.sender] < currentPeriod(), "already current on dues");
        require(address(baal) != address(0), "shaman not connected to DAO");
        require(baal.isManager(address(this)), "shaman not manager");
        _;
    }

    function payDues20(uint256 _value) public nonReentrant, validPayment {
        require(_value == duesAmount, "payment must equal dues amount");
        require(token.transferFrom(msg.sender, baal.target(), _value), "transfer failed");
        _paid(_value);
    }

    function wrapAndPayDues() public payable nonReentrant, valid {
        require(msg.value == duesAmount, "payment must equal dues amount");
        require(!onlyERC20, "native payment not enabled");

        // wrap
        (bool success, ) = address(token).call{value: msg.value}("");
        require(success, "unable to wrap token");

        // transfer
        require(token.transfer(baal.target(), msg.value), "transfer failed");

        _paid(msg.value);
    }

    // After wrapping do the payment
    function _paid(uint256 _value) private {
        _updateGoodStanding();
        _increaseShares();
    }

    // Increment period of good standing
    function _updateGoodStanding() private {
        paidThroughPeriod[msg.sender] = currentPeriod();
    }

    // Dues receive shares based on parameters
    function _increaseShares() private {
        address[] memory addrs = new address[](1);
        addrs[0] = msg.sender;
        uint256[] memory amts = new uint256[](1);
        amts[0] = sharesPerPeriod;

        baal.mintShares(addrs, amts);
    }

    // Convert members not in good standing just lootholders
    // @_members array of members to remove
    function purgeMembership(address[] _members) public nonReentrant {

    }

    // calculate the current period
    function currentPeriod() public view returns (uint256) {
        require(duesPeriod > 0, "cannot divide by 0 dues period");
        // first period is 1
        return ((now - epoch) / duesPeriod) + 1;
    }

    function getMembersNotInGoodStanding() public view returns (address[]) {
        // call inGoodStanding for all members
        // Return array of all false values
        baal.members
    }

    // In good standing as long as they paid previous period
    function inGoodStanding(address _member) public view returns (bool) {
        // look at current period
        // check each member to see whether their good standing is < current -1
        // (they missed last full period)
        return (paidThroughPeriod(_member) >= currentPeriod() - 1);
    }

    function receive() external payable {
        payDues();
    }
}

contract DuesShamanSummoner is CloneFactory, Ownable {
    address payable public template;

    event SummonDuesShamanComplete(
        address indexed baal,
        address duesShaman,
        address token,
        uint256 duesAmount,
        uint256 duesPeriod,
        uint256 sharesPerPeriod,
        bool onlyERC20,
        string details
    );

    constructor(address payable _template) {
        template = _template;
        DuesShaman _duesShaman = DuesShaman(_template);
        _duesShaman.initTemplate();
    }

    function summonDuesShaman(
        address _baal,
        address payable _token,
        uint256 _duesAmount,
        uint256 _duesPeriod,
        uint256 _sharesPerPeriod,
        bool _onlyERC20,
        string calldata _details
    ) public returns (address) {

        DuesShaman dues = DuesShaman(payable(createClone(template)));

        dues.init(
            _baal,
            _token,
            _duesAmount,
            _duesPeriod,
            _sharesPerPeriod,
            _onlyERC20
        );

        emit SummonDuesShamanComplete(
            _baal,
            address(dues),
            _token,
            _duesAmount,
            _duesPeriod,
            _sharesPerPeriod,
            _onlyERC20,
            _details
        );
    }
}

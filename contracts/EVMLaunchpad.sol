// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EVMLaunchpad is ReentrancyGuard {
    using SafeMath for uint256;

    // Token-related mappings
    mapping(address => IERC20) public tokens;
    mapping(address => uint256) public totalRaisedForToken;
    mapping(address => uint256) public softCaps;
    mapping(address => uint256) public hardCaps;
    mapping(address => uint256) public tokenToSaleRound;

    // Sale round and token tracking
    uint256 public currentRound;
    address[] public tokensList;
    mapping(address => address) public tokenRegistrants;

    // Investor details
    struct Investor {
        uint256 amountContributed;
        uint256 tokensAllocated;
        uint256 tokensClaimed;
    }
    mapping(address => mapping(address => Investor)) public investors; // investor -> token -> details

    // Sale round details
    struct SaleRound {
        uint256 pricePerToken;
        uint256 maxContribution;
        uint256 minContribution;
        uint256 tokensAvailable;
        uint256 tokensSold;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }
    mapping(address => SaleRound[]) public saleRounds; // token -> sale rounds

    // Vesting schedule
    struct VestingSchedule {
        uint256 totalAllocation;
        uint256 released;
        uint256 start;
        uint256 duration;
    }
    mapping(address => mapping(address => VestingSchedule)) public vestingSchedules; // investor -> token -> vesting schedule

    // Events
    event TokenPurchase(address indexed investor, address indexed token, uint256 value, uint256 tokens);
    event FundWithdrawal(address indexed owner, uint256 amount);
    event TokensClaimed(address indexed investor, address indexed token, uint256 amount);
    event SalePhaseUpdated(address indexed token, uint256 roundIndex, bool isActive);
    event TokenRegistered(address indexed token, uint256 softCap, uint256 hardCap);
    event SaleRoundAdded(address indexed token, uint256 roundIndex);

    constructor() {}

    modifier onlyActiveRound(address token) {
        require(saleRounds[token].length > 0, "No sale rounds for token");
        uint256 roundIndex = tokenToSaleRound[token];
        SaleRound storage round = saleRounds[token][roundIndex];
        require(round.isActive, "Sale phase not active");
        require(block.timestamp >= round.startTime && block.timestamp <= round.endTime, "Sale round not active");
        _;
    }

    function registerToken(
        address _token,
        uint256 _softCap,
        uint256 _hardCap
    ) external {
        require(_token != address(0), "Invalid token address");
        require(_softCap < _hardCap, "Soft cap must be less than hard cap");
        require(tokens[_token] == IERC20(address(0)), "Token already registered");

        tokens[_token] = IERC20(_token);
        softCaps[_token] = _softCap;
        hardCaps[_token] = _hardCap;

        tokenRegistrants[_token] = msg.sender;
        tokensList.push(_token);

        emit TokenRegistered(_token, _softCap, _hardCap);
    }

    function addSaleRound(
        address _token,
        uint256 _pricePerToken,
        uint256 _tokensAvailable,
        uint256 _minContribution,
        uint256 _maxContribution,
        uint256 _startTime,
        uint256 _endTime
    ) external {
        require(tokenRegistrants[_token] == msg.sender, "Only token registrant can add sale round");
        require(_pricePerToken > 0, "Price per token must be greater than zero");
        require(_tokensAvailable > 0, "Tokens available must be greater than zero");
        require(_startTime < _endTime, "Invalid time range");
        require(tokens[_token].balanceOf(address(this)) >= _tokensAvailable, "Insufficient token balance");

        saleRounds[_token].push(
            SaleRound({
                pricePerToken: _pricePerToken,
                maxContribution: _maxContribution,
                minContribution: _minContribution,
                tokensAvailable: _tokensAvailable,
                tokensSold: 0,
                startTime: _startTime,
                endTime: _endTime,
                isActive: false
            })
        );

        emit SaleRoundAdded(_token, saleRounds[_token].length - 1);
    }

    function activateSaleRound(address token, uint256 roundIndex) external {
        require(tokenRegistrants[token] == msg.sender, "Only token registrant can activate sale round");
        require(roundIndex < saleRounds[token].length, "Invalid round index");

        SaleRound storage round = saleRounds[token][roundIndex];
        round.isActive = true;
        tokenToSaleRound[token] = roundIndex;

        emit SalePhaseUpdated(token, roundIndex, true);
    }

    function deactivateSaleRound(address token, uint256 roundIndex) external {
        require(tokenRegistrants[token] == msg.sender, "Only token registrant can deactivate sale round");
        require(roundIndex < saleRounds[token].length, "Invalid round index");

        SaleRound storage round = saleRounds[token][roundIndex];
        round.isActive = false;

        emit SalePhaseUpdated(token, roundIndex, false);
    }

    function purchaseTokens(address token) external payable nonReentrant onlyActiveRound(token) {
        SaleRound storage round = saleRounds[token][tokenToSaleRound[token]];

        require(msg.value >= round.minContribution, "Contribution too low");
        require(msg.value <= round.maxContribution, "Contribution exceeds max");
        require(totalRaisedForToken[token].add(msg.value) <= hardCaps[token], "Hard cap reached");

        uint256 tokensToBuy = msg.value.mul(1e18).div(round.pricePerToken);
        require(tokensToBuy <= round.tokensAvailable, "Not enough tokens available");

        round.tokensAvailable = round.tokensAvailable.sub(tokensToBuy);
        round.tokensSold = round.tokensSold.add(tokensToBuy);

        investors[msg.sender][token].amountContributed = investors[msg.sender][token].amountContributed.add(msg.value);
        investors[msg.sender][token].tokensAllocated = investors[msg.sender][token].tokensAllocated.add(tokensToBuy);

        totalRaisedForToken[token] = totalRaisedForToken[token].add(msg.value);

        setVestingSchedule(msg.sender, token, tokensToBuy, block.timestamp, 30 days);

        emit TokenPurchase(msg.sender, token, msg.value, tokensToBuy);
    }

    function setVestingSchedule(
        address beneficiary,
        address token,
        uint256 totalAllocation,
        uint256 start,
        uint256 duration
    ) internal {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(totalAllocation > 0, "Total allocation must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");

        vestingSchedules[beneficiary][token] = VestingSchedule({
            totalAllocation: totalAllocation,
            released: 0,
            start: start,
            duration: duration
        });
    }

    function claimTokens(address token) external nonReentrant {
        VestingSchedule storage schedule = vestingSchedules[msg.sender][token];
        require(schedule.totalAllocation > 0, "No vesting schedule");
        require(block.timestamp >= schedule.start, "Vesting has not started");

        uint256 vestedAmount = schedule.totalAllocation.mul(
            block.timestamp.sub(schedule.start)
        ).div(schedule.duration);

        uint256 claimable = vestedAmount.sub(schedule.released);
        require(claimable > 0, "No tokens available for claim");

        schedule.released = schedule.released.add(claimable);
        investors[msg.sender][token].tokensClaimed = investors[msg.sender][token].tokensClaimed.add(claimable);

        tokens[token].transfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, token, claimable);
    }

    function withdrawFunds() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(msg.sender).transfer(balance);

        emit FundWithdrawal(msg.sender, balance);
    }
}

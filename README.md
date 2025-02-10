# Zero Launchpad Smart Contracts

A comprehensive smart contract system for a decentralized token launchpad platform. These contracts enable token launches, sale management, and vesting schedules across multiple EVM-compatible networks.

## 🚀 Features

### Token Management
- **Token Registration**
  - Register ERC20 tokens for launch
  - Set configurable soft and hard caps
  - Manage token allocations
  - Handle token transfers securely

### Sale Rounds
- **Flexible Sale Configuration**
  - Multiple sale rounds per token
  - Customizable pricing per round
  - Adjustable contribution limits
  - Time-based activation controls

### Vesting System
- **Advanced Vesting Mechanics**
  - Customizable vesting schedules
  - Linear vesting implementation
  - Automated token distribution
  - Claim management system

## 🛠 Technology Stack

- **Framework**: Hardhat
- **Language**: Solidity ^0.8.20
- **Testing**: Mocha & Chai
- **Security**: OpenZeppelin Contracts
- **Deployment**: Hardhat Ignition

## 📦 Installation

1. **Clone the Repository**
```bash
git clone <repository-url>
cd EVM-Contracts
```

2. **Install Dependencies**
```bash
npm install
```

3. **Compile Contracts**
```bash
npx hardhat compile
```

## 🔧 Development

### Available Commands
```bash
# Run tests
npx hardhat test

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Start local node
npx hardhat node

# Deploy contracts
npx hardhat run scripts/deploy.ts

# Verify contracts
npx hardhat verify --network <network> <contract-address>
```

### Contract Architecture

#### EVMLaunchpad.sol
- Main launchpad contract
- Handles token registration and sale management
- Implements vesting and distribution logic

```solidity
contract EVMLaunchpad is ReentrancyGuard {
    // Token Management
    mapping(address => IERC20) public tokens;
    mapping(address => uint256) public totalRaisedForToken;
    
    // Sale Configuration
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
    
    // Vesting Implementation
    struct VestingSchedule {
        uint256 totalAllocation;
        uint256 released;
        uint256 start;
        uint256 duration;
    }
}
```

## 🧪 Testing

### Test Coverage
- Unit tests for all core functions
- Integration tests for complex scenarios
- Gas optimization tests
- Security vulnerability tests

```bash
# Run test coverage
npx hardhat coverage
```

### Test Structure
```typescript
describe("EVMLaunchpad", function () {
  describe("Token Registration", function () {
    // Token registration tests
  });
  
  describe("Sale Rounds", function () {
    // Sale round management tests
  });
  
  describe("Vesting", function () {
    // Vesting mechanism tests
  });
});
```

## 📝 Contract Documentation

### Core Functions

#### Token Registration
```solidity
function registerToken(
    address _token,
    uint256 _softCap,
    uint256 _hardCap
) external
```

#### Sale Round Management
```solidity
function addSaleRound(
    address _token,
    uint256 _pricePerToken,
    uint256 _tokensAvailable,
    uint256 _minContribution,
    uint256 _maxContribution,
    uint256 _startTime,
    uint256 _endTime
) external
```

#### Investment Handling
```solidity
function purchaseTokens(address token) 
    external 
    payable 
    nonReentrant 
    onlyActiveRound(token)
```

## 🔒 Security

### Features
- Reentrancy protection
- Integer overflow prevention
- Access control implementation
- Secure fund handling

### Audit Status
- Internal audit completed
- External audit pending
- No critical vulnerabilities found

## 🚀 Deployment

### Networks
- Multiple testnet deployments
- Mainnet deployment pending
- Cross-chain compatibility verified

### Deployment Process
1. Configure network in hardhat.config.ts
2. Set environment variables
3. Run deployment script
4. Verify contract on explorer

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

- Developer: [Your Name]
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)

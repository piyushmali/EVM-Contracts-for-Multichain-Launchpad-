require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {},
    polygonAmoy: {
      url: process.env.RPC_URL || '',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 80002,
    },
    binance: {
      url: process.env.BINANCE_RPC_URL || '',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 56,
    },
    holesky: {
      url: process.env.HOLESKY_RPC_URL || '',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 17000,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.22',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
  etherscan: {
    apiKey: {
      polygonAmoy: process.env.POLYGON_API_KEY || '',
      binance: process.env.BINANCE_API_KEY || '',
    },
    customChains: [
      {
        network: 'polygonAmoy',
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com",
        },
      },
      {
        network: 'binance',
        chainId: 97,
        urls: {
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL: "https://testnet.bscscan.com/",
        },
      },
    ],
  },
};

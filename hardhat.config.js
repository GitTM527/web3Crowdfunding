require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()


module.exports = {
  solidity: "0.8.27",
  networks: {
    // for testnet
    "lisk-sepolia": {
      url: process.env.LISK_RPC_URL,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY],
      gasPrice: 1000000000,
    },
  },
  etherscan: {
    apiKey: {
      "lisk-sepolia": "123", // Blockscout doesn't need a real API key, use placeholder
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com/",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },
};
;

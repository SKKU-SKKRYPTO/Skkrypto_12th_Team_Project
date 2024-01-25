require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.23",
  networks: {
    hardhat: {
      gas: 10000000,
      gasPrice: 1000000000,
    },
    // All that node로 배포
    sepolia: {
      // RPC node 주소
      url: process.env.SEPOLIA_URL,
      // 배포할 때 사용할 이더리움의 private key
      accounts: {
        mnemonic: process.env.MNEMONIC
      },
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
};
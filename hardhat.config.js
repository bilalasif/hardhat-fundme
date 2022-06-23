require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-deploy")



// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const RINNKBEY_RPC_URL = process.env.RINNKBEY_RPC_URL || "https://eth-rinkbey/example"
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xkey"
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "key"
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "key"
module.exports = {
    solidity: {
        compilers: [{
                version: "0.8.8",
            },
            {
                version: "0.6.6",
            }
        ],
    },
    defaultNetwork: "hardhat",
    networks: {
        rinkeby: {
            url: RINNKBEY_RPC_URL,
            accounts: [
                PRIVATE_KEY
            ],
            chainId: 4,
            blockConfirmations: 6,
        },

    },
    gasReporter: {
        enabled: false,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: COINMARKETCAP_API_KEY,
        token: 'MATIC'
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,

        },
        user: {
            defulat: 1
        }
    }
};
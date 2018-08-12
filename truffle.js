require('dotenv').config()
const _ = require('lodash')
const WalletProvider = require('truffle-wallet-provider')
const Wallet = require('ethereumjs-wallet')

// put "mainnet back in when ready to deploy there"
const networks = ['rinkeby']

const infuraNetworks = _.fromPairs(_.compact(networks.map((network) => {
  const envVarName = `${network.toUpperCase()}_PRIVATE_KEY`
  const privateKeyHex = process.env[envVarName]

  if (privateKeyHex) {
    const privateKey = Buffer.from(process.env[envVarName], 'hex')
    const wallet = Wallet.fromPrivateKey(privateKey);
    const provider = new WalletProvider(wallet, `https://${network}.infura.io/`)

    return [
      network,
      {
        host: 'localhost',
        port: 8545,
        network_id: '*',
        gas: 7000000,
        provider,
      }
    ]
  }
})))

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
      gasPrice: 1,
      gas: 7000000
    },
    ...infuraNetworks,
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
}

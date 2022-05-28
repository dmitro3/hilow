import { WagmiConfig, createClient, chain, configureChains } from 'wagmi'

import { alchemyProvider } from 'wagmi/providers/alchemy'

import { MetaMaskConnector } from 'wagmi/connectors/metaMask'

import Profile from './Profile'

const alchemyId = process.env.ALCHEMY_ID

const { chains, provider, webSocketProvider } = configureChains([chain.polygonMumbai], [
  alchemyProvider({ alchemyId }),
])

// Set up client
const client = createClient({
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains }),
  ],
  provider,
  webSocketProvider,
})

// Pass client to React Context Provider
const App: React.FC = () => {
  return (
    <WagmiConfig client={client}>
      <Profile />
    </WagmiConfig>
  )
}

export default App;
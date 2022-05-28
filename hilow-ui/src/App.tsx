import { WagmiConfig, createClient, chain, configureChains } from "wagmi";

import { alchemyProvider } from "wagmi/providers/alchemy";

import { InjectedConnector } from "wagmi/connectors/injected";
import { WalletConnectConnector } from "wagmi/connectors/walletConnect";

import { FlowProvider } from "./context/FlowContext";

import FlowRouter from "./FlowRouter";

const alchemyId = process.env.ALCHEMY_ID;

const { chains, provider, webSocketProvider } = configureChains(
  [chain.polygonMumbai],
  [alchemyProvider({ alchemyId })]
);

// Set up client
const client = createClient({
  autoConnect: true,
  connectors: [
    new WalletConnectConnector({
      chains,
      options: {
        qrcode: true,
      },
    }),
    new InjectedConnector({
      chains,
      options: {
        name: "Injected",
        shimDisconnect: true,
      },
    }),
  ],
  provider,
  webSocketProvider,
});

// Pass client to React Context Provider
const App: React.FC = () => {
  return (
    <WagmiConfig client={client}>
      <FlowProvider>
        <FlowRouter />
      </FlowProvider>
    </WagmiConfig>
  );
};

export default App;

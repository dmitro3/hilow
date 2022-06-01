import React, { useEffect } from "react";
import { VStack, useDisclosure, Button, Text, HStack } from "@chakra-ui/react";
import SelectWalletModal from "./SelectWalletModal";
import { CheckCircleIcon, WarningIcon } from "@chakra-ui/icons";
import { Tooltip } from "@chakra-ui/react";
import {
  useConnect,
  useAccount,
  useNetwork,
  useDisconnect,
  chain,
} from "wagmi";
import { useFlowUpdate } from "./context/FlowContext";
import { FlowStates } from "./constants";

export default function Home() {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const { status } = useConnect();
  const { data: accountData } = useAccount();
  const { data: networkData, switchNetwork } = useNetwork();
  const { disconnect } = useDisconnect();
  const updateFlow = useFlowUpdate();

  useEffect(() => {
    if (switchNetwork) {
      switchNetwork(chain.polygonMumbai.id);
    }
  }, [switchNetwork]);

  useEffect(() => {
    if (accountData) updateFlow(FlowStates.GAME);
    else updateFlow(FlowStates.CONNECT);
  }, [accountData]);

  return (
    <>
      <VStack justifyContent="center" alignItems="center" h="100vh">
        <HStack marginBottom="10px">
          <Text
            margin="0"
            lineHeight="1.15"
            fontSize={["1.5em", "2em", "3em", "4em"]}
            fontWeight="600"
          >
            Connect your wallet and Flip that Card
          </Text>
          {/* <Text
            margin="0"
            lineHeight="1.15"
            fontSize={["1.5em", "2em", "3em", "4em"]}
            fontWeight="600"
            sx={{
              background: "linear-gradient(90deg, blue 0%, lightblue 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            Flip The Card!
          </Text> */}
        </HStack>
        <HStack>
          {status === "connected" ? (
            <Button onClick={() => disconnect()}>Disconnect</Button>
          ) : (
            <Button onClick={onOpen}>Connect Wallet</Button>
          )}
        </HStack>
        <VStack justifyContent="center" alignItems="center" padding="10px 0">
          <HStack>
            <Text>{`Connection Status: `}</Text>
            {status === "connected" ? (
              <CheckCircleIcon color="green" />
            ) : (
              <WarningIcon color="#cd5700" />
            )}
          </HStack>

          {!accountData ? (
            <Text>Account: No Account</Text>
          ) : (
            <Tooltip label={accountData.address} placement="right">
              <Text>{`Account: ${accountData.address}`}</Text>
            </Tooltip>
          )}
          <Text>{`Network name: ${
            networkData ? networkData?.name : "No Network"
          }`}</Text>
          <Text>{`Network ID: ${
            networkData ? networkData?.id : "No Network"
          }`}</Text>
        </VStack>
      </VStack>
      <SelectWalletModal isOpen={isOpen} closeModal={onClose} />
    </>
  );
}

import React, { useEffect } from "react";
import { VStack, Text, HStack, Button } from "@chakra-ui/react";
import { useAccount, useContractWrite, useContract, useSigner } from "wagmi";
import { useFlowUpdate } from "./context/FlowContext";
import { FlowStates, HILOW_ADDRESS } from "./constants";
import Header from "./Header";
import HilowABI from "./abi/Hilow.json";

interface GameProps {}

const Game: React.FC<GameProps> = () => {
  const { data: accountData } = useAccount();
  const updateFlow = useFlowUpdate();
  const { data: signer } = useSigner();
  const contractConfig = {
    addressOrName: HILOW_ADDRESS,
    contractInterface: HilowABI.abi,
    signerOrProvider: signer,
  };
  const contract = useContract(contractConfig);
  const { write: tipDealer } = useContractWrite(contractConfig, "tip");

  useEffect(() => {
    if (accountData) updateFlow(FlowStates.GAME);
    else updateFlow(FlowStates.CONNECT);
  }, [accountData]);

  const getCards = async () => {
    const cards = await contract.viewCards();
    console.log(cards);
  };

  return (
    <>
      <Header />
      <VStack justifyContent="center" alignItems="center" h="80vh">
        <HStack marginBottom="10px">
          <Text
            margin="0"
            lineHeight="1.15"
            fontSize={["1.5em", "2em", "3em", "4em"]}
            fontWeight="600"
          >
            Game!
          </Text>
          <Button
            variant="outline"
            _hover={{ bg: "black", borderColor: "black", color: "white" }}
            onClick={() => tipDealer({ overrides: { value: 100000000000000 } })}
          >
            Tip
          </Button>
          <Button
            variant="outline"
            _hover={{ bg: "black", borderColor: "black", color: "white" }}
            onClick={() => getCards()}
          >
            Get cards
          </Button>
        </HStack>
      </VStack>
    </>
  );
};

export default Game;

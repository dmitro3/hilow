import React from "react";
import { VStack, Text, HStack, Button } from "@chakra-ui/react";
import { useContractWrite, useContract, useSigner } from "wagmi";
import { HILOW_ADDRESS } from "../constants";
import Header from "./Header";
import HilowABI from "../abi/Hilow.json";

interface GameLayoutProps {}

const GameLayout: React.FC<GameLayoutProps> = () => {
  const { data: signer } = useSigner();
  const contractConfig = {
    addressOrName: HILOW_ADDRESS,
    contractInterface: HilowABI.abi,
    signerOrProvider: signer,
  };
  const contract = useContract(contractConfig);
  const { write: tipDealer } = useContractWrite(contractConfig, "tip");

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

export default GameLayout;

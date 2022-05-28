import React, { useEffect } from "react";
import { VStack, Text, HStack, Button } from "@chakra-ui/react";
import { useAccount, useContractWrite, useContractRead } from "wagmi";
import { useFlowUpdate } from "./context/FlowContext";
import { FlowStates } from "./constants";
import Header from "./Header";
import HilowABI from "./abi/Hilow.json";

interface GameProps {}

const Game: React.FC<GameProps> = () => {
  const { data: accountData } = useAccount();
  const updateFlow = useFlowUpdate();
  const contractConfig = {
    addressOrName: "0x4C2b3104f55735Dd5A4a57D0d0b36cBe165c47BA",
    contractInterface: HilowABI.abi,
  };
  // const contractRead = useContractRead(
  //   contractConfig,
  //   'viewCards',
  // )
  const { write: tipDealer } = useContractWrite(contractConfig, "tip");

  useEffect(() => {
    if (accountData) updateFlow(FlowStates.GAME);
    else updateFlow(FlowStates.CONNECT);
  }, [accountData]);

  // useEffect(() => {console.log(contractRead)}, [contractRead])

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
        </HStack>
      </VStack>
    </>
  );
};

export default Game;

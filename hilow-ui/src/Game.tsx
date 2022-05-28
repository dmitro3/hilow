import React, { useEffect } from "react";
import { VStack, Text, HStack } from "@chakra-ui/react";
import { useAccount } from "wagmi";
import { useFlowUpdate } from "./context/FlowContext";
import { FlowStates } from "./constants";

interface GameProps {}

const Game: React.FC<GameProps> = ({}) => {
  const { data: accountData } = useAccount();
  const updateFlow = useFlowUpdate();

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
            Game!
          </Text>
        </HStack>
      </VStack>
    </>
  );
};

export default Game;

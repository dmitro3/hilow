import React, { useEffect } from "react";
import { VStack, Skeleton } from "@chakra-ui/react";
import { useContractWrite, useContract, useSigner } from "wagmi";
import { HILOW_ADDRESS } from "../constants";
import Header from "./Header";
import HilowABI from "../abi/Hilow.json";
import { useGameState, useGameStateUpdate } from "../context/GameStateContext";
import { Game } from "../types";
import FirstCard from "./FirstCard";
import BetSection from "./BetSection";
import SecondCard from "./SecondCard";

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
  const { ready } = useGameState();
  const updateGameState = useGameStateUpdate();

  useEffect(() => {
    const findActiveGame = async () => {
      const [activeGameFound, activeGame]: [boolean, Game] =
        await contract.getActiveGame();
      const firstCardValue: number = activeGame.firstDraw.value.toNumber();

      updateGameState({ ready: true, firstCardValue });
    };

    findActiveGame();
  }, [contract]);

  const getCards = async () => {
    const cards = await contract.viewCards();
    console.log(cards);
  };

  return (
    <>
      <Header />
      <Skeleton isLoaded={ready} height="100vh">
        <VStack justifyContent="center" alignItems="center" h="80vh">
          <FirstCard />
          <BetSection />
          <SecondCard />
        </VStack>
      </Skeleton>
    </>
  );
};

export default GameLayout;

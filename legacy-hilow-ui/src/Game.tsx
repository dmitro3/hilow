import React, { useEffect } from "react";
import { useAccount } from "wagmi";
import { FlowStates } from "./constants";
import { useFlowUpdate } from "./context/FlowContext";
import { GameStateProvider } from "./context/GameStateContext";
import GameLayout from "./GameComponents/GameLayout";

interface GameProps {}

const Game: React.FC<GameProps> = () => {
  const { data: accountData } = useAccount();
  const updateFlow = useFlowUpdate();

  useEffect(() => {
    if (accountData) updateFlow(FlowStates.GAME);
    else updateFlow(FlowStates.CONNECT);
  }, [accountData]);

  return (
    <GameStateProvider>
      <GameLayout />
    </GameStateProvider>
  );
};

export default Game;

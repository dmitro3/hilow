import { BigNumber } from "ethers";
import React, { useState, useContext } from "react";
import { Card } from "../types";

interface CardState {
  loaded: boolean;
  card: Card;
}

interface BetState {
  higher: boolean;
  amount: number;
}

interface GameState {
  ready: boolean;
  firstCard: CardState;
  secondCard: CardState;
  bet: BetState;
}

const placeholderCard: Card = {
  value: 0,
  suit: "Hearts",
};

const placeholderGameState: GameState = {
  ready: false,
  firstCard: { card: placeholderCard, loaded: false },
  secondCard: { card: placeholderCard, loaded: false },
  bet: { higher: false, amount: 0 },
};

interface UpdateGameStateParams {
  ready?: boolean;
  firstCardValue?: number;
  secondCardValue?: number;
}

const GameStateContext = React.createContext<GameState>(
  placeholderGameState as GameState
);
const GameStateUpdateContext = React.createContext<
  (gameState: UpdateGameStateParams) => void
>(() => void 0);

interface ProviderArgs {
  children: React.ReactNode;
}

export const GameStateProvider = ({ children }: ProviderArgs) => {
  const [gameState, setGameState] = useState<GameState>(
    placeholderGameState as GameState
  );

  const updateGameState = ({
    ready,
    firstCardValue,
  }: UpdateGameStateParams) => {
    const updateState: any = {};
    if (ready) updateState["ready"] = ready;
    if (firstCardValue)
      updateState["firstCard"] = {
        loaded: true,
        card: { value: firstCardValue, suit: "Hearts" },
      };

    setGameState((prevGameState) => ({
      ...prevGameState,
      ...updateState,
    }));
  };

  return (
    <GameStateContext.Provider value={gameState}>
      <GameStateUpdateContext.Provider value={updateGameState}>
        {children}
      </GameStateUpdateContext.Provider>
    </GameStateContext.Provider>
  );
};

export const useGameState = () => {
  return useContext(GameStateContext);
};

export const useGameStateUpdate = () => {
  return useContext(GameStateUpdateContext);
};

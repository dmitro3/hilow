import { BigNumber } from "ethers";

export type CardSuit = "Hearts" | "Diamonds" | "Spades" | "Clubs";

export interface Card {
  value: number;
  suit: CardSuit;
}

export interface Game {
  firstDraw: {
    value: BigNumber;
  };
  secondDraw: {
    value: BigNumber;
  };
}

export type CardSuit = "Hearts" | "Diamonds" | "Spades" | "Clubs";

export interface Card {
  value: number;
  suit: CardSuit;
}

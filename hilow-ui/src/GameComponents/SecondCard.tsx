import { ethers } from "ethers";
import React from "react";
import { useContract, useSigner } from "wagmi";
import HilowABI from "../abi/Hilow.json";
import { HILOW_ADDRESS } from "../constants";
import { useGameState } from "../context/GameStateContext";
import { formatCardValue } from "../utils";

interface SecondCardProps {}

const SecondCard: React.FC<SecondCardProps> = ({}) => {
  const { data: signer } = useSigner();
  const contractConfig = {
    addressOrName: HILOW_ADDRESS,
    contractInterface: HilowABI.abi,
    signerOrProvider: signer,
  };
  const contract = useContract(contractConfig);
  const { secondCard, bet, result } = useGameState();

  return (
    <>
      {secondCard.loaded ? (
        <div>
          You drew the {formatCardValue(secondCard.card.value)} of{" "}
          {secondCard.card.suit}. You bet {bet.amount} MATIC on a{" "}
          {bet.higher ? "higher" : "lower"} card and{" "}
          {result.isWin
            ? `WON ${ethers.utils.formatEther(result.payoutAmount)} MATIC!`
            : "LOST."}
        </div>
      ) : (
        ""
      )}
    </>
  );
};

export default SecondCard;

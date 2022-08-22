import { Button, CircularProgress } from "@chakra-ui/react";
import { BigNumber } from "ethers";
import React, { useEffect, useState } from "react";
import { useContractWrite, useContract, useSigner, useAccount } from "wagmi";
import HilowABI from "../abi/Hilow.json";
import { HILOW_ADDRESS } from "../constants";
import { useGameState, useGameStateUpdate } from "../context/GameStateContext";
import { formatCardValue } from "../utils";

interface FirstCardProps {}

const FirstCard: React.FC<FirstCardProps> = ({}) => {
  const { data: signer } = useSigner();
  const { data: accountData } = useAccount();
  const contractConfig = {
    addressOrName: HILOW_ADDRESS,
    contractInterface: HilowABI.abi,
    signerOrProvider: signer,
  };
  const contract = useContract(contractConfig);
  const { write: drawFirstCard } = useContractWrite(contractConfig, "drawCard");
  const { firstCard } = useGameState();
  const updateGameState = useGameStateUpdate();
  const [loading, setLoading] = useState<boolean>(false);

  useEffect(() => {
    try {
      contract.on("CardDrawn", (player: string, firstDrawCard: BigNumber) => {
        console.log(player, firstDrawCard);
        if (player.toLowerCase() === accountData?.address?.toLowerCase()) {
          const firstCardValue = firstDrawCard.toNumber();
          updateGameState({ ready: true, firstCardValue });
          setLoading(false);
        }
      });
    } catch (error) {
      console.log(error);
    }
  }, [contract]);

  return (
    <>
      {firstCard.loaded ? (
        <div>
          You drew the {formatCardValue(firstCard.card.value)} of{" "}
          {firstCard.card.suit}
        </div>
      ) : (
        <Button
          variant="outline"
          _hover={{ bg: "black", borderColor: "black", color: "white" }}
          onClick={() => {
            setLoading(true);
            drawFirstCard();
          }}
          disabled={loading}
        >
          <div>
            Draw Card{" "}
            {loading ? (
              <CircularProgress
                isIndeterminate
                color="green.300"
                size={"20px"}
              />
            ) : (
              ""
            )}
          </div>
        </Button>
      )}
    </>
  );
};

export default FirstCard;

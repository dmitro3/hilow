import React, { useEffect, useState } from "react";
import {
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  Checkbox,
  Button,
  CircularProgress,
} from "@chakra-ui/react";
import { useContractWrite, useContract, useSigner, useAccount } from "wagmi";
import HilowABI from "../abi/Hilow.json";
import { HILOW_ADDRESS } from "../constants";
import { useGameState, useGameStateUpdate } from "../context/GameStateContext";
import { ethers } from "ethers";

interface BetSectionProps {}

const BetSection: React.FC<BetSectionProps> = ({}) => {
  const { data: signer } = useSigner();
  const { data: accountData } = useAccount();
  const contractConfig = {
    addressOrName: HILOW_ADDRESS,
    contractInterface: HilowABI.abi,
    signerOrProvider: signer,
  };
  const contract = useContract(contractConfig);
  const { write: placeBet } = useContractWrite(contractConfig, "bet");
  const { firstCard, bet } = useGameState();
  const updateGameState = useGameStateUpdate();
  const [loading, setLoading] = useState<boolean>(false);

  const updateBet = ({
    betAmount,
    higher,
  }: {
    betAmount?: number;
    higher?: boolean;
  }) => {
    updateGameState({ betAmount, higher });
  };

  useEffect(() => {
    try {
      contract.on(
        "GameFinished",
        (
          player: string,
          firstDrawCard: number,
          secondDrawCard: number,
          isWin: boolean,
          payoutAmount: number
        ) => {
          console.log(
            player,
            firstDrawCard,
            secondDrawCard,
            isWin,
            payoutAmount
          );
          if (player.toLowerCase() === accountData?.address?.toLowerCase()) {
            updateGameState({
              secondCardValue: secondDrawCard,
              isWin,
              payoutAmount,
            });
            setLoading(false);
          }
        }
      );
    } catch (error) {
      console.log(error);
    }
  }, [contract]);

  return (
    <>
      {firstCard.loaded ? (
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <div>
            <Checkbox
              isChecked={bet.higher}
              onChange={(event: any) => {
                updateBet({ higher: event.target.checked });
              }}
            >
              Next card will be higher
            </Checkbox>
          </div>
          <div>
            <NumberInput
              size="md"
              value={bet.amount}
              onChange={(_: string, value: number) =>
                updateBet({ betAmount: value })
              }
              maxW={24}
              defaultValue={0.1}
              min={0.1}
              max={5}
              precision={2}
              step={0.1}
            >
              <NumberInputField />
              <NumberInputStepper>
                <NumberIncrementStepper />
                <NumberDecrementStepper />
              </NumberInputStepper>
            </NumberInput>
          </div>
          <div>
            <Button
              variant="outline"
              _hover={{ bg: "black", borderColor: "black", color: "white" }}
              onClick={() => {
                setLoading(true);
                placeBet({
                  args: [bet.higher],
                  overrides: {
                    value: ethers.utils.parseEther(bet.amount.toString()),
                  },
                });
              }}
              disabled={loading}
            >
              <div>
                Place Bet
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
          </div>
        </div>
      ) : (
        ""
      )}
    </>
  );
};

export default BetSection;

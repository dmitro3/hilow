import React, { useState, useContext } from "react";
import { FlowStates } from "../constants";

const FlowContext = React.createContext<string>("");
const FlowUpdateContext = React.createContext<(Flow: string) => void>(
  () => void 0
);

interface ProviderArgs {
  children: React.ReactNode;
}

export const FlowProvider = ({ children }: ProviderArgs) => {
  const [flow, setFlow] = useState<string>(FlowStates.CONNECT);

  const updateFlow = (flow: string) => {
    setFlow(flow);
  };

  return (
    <FlowContext.Provider value={flow}>
      <FlowUpdateContext.Provider value={updateFlow}>
        {children}
      </FlowUpdateContext.Provider>
    </FlowContext.Provider>
  );
};

export const useFlow = () => {
  return useContext(FlowContext);
};

export const useFlowUpdate = () => {
  return useContext(FlowUpdateContext);
};

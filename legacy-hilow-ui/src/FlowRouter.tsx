import React from "react";
import { FlowStates } from "./constants";
import { useFlow } from "./context/FlowContext";
import Profile from "./Profile";
import Game from "./Game";

const FlowRouter: React.FC = () => {
  const flow = useFlow();
  const flowStateComponents = {
    [FlowStates.CONNECT]: <Profile />,
    [FlowStates.GAME]: <Game />,
  };

  return flowStateComponents?.[flow] ?? <Profile />;
};

export default FlowRouter;

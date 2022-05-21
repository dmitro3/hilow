require("dotenv").config();

const hre = require("hardhat");

const deploy = async () => {
  const HilowFactory = await hre.ethers.getContractFactory("Hilow");
  const Hilow = await HilowFactory.deploy(
    process.env.CHAINLINK_VRF_SUBSCRIPTION_ID,
    {
      value: hre.ethers.utils.parseEther("0.1"),
    }
  );
  await Hilow.deployed();
  console.log("Deployed to -", Hilow.address);

  let contractBalance;
  contractBalance = await hre.ethers.provider.getBalance(Hilow.address);
  console.log(
    "Contract balance -",
    hre.ethers.utils.formatEther(contractBalance)
  );
};

const runDeploy = async () => {
  try {
    await deploy();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runDeploy();

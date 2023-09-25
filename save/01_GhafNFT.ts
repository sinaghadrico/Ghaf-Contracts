/* eslint-disable node/no-missing-import */
/* eslint-disable node/no-unpublished-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const deployedContract = await deploy("GhafNFT", {
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
    args: [],
  });

  await hre.run("verify:verify", {
    address: deployedContract.address,
    constructorArguments: [],
  });
};

export default func;
export const tags = ["GhafNFT"];

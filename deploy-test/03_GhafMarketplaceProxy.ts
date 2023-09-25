/* eslint-disable node/no-missing-import */
/* eslint-disable node/no-unpublished-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const ghafMarketPlaceLogic = await deployments.get("GhafMarketPlaceLogic");

  const theArgs = [ghafMarketPlaceLogic.address, deployer, "0x"];

  const deployedContract = await deploy("GhafMarketPlaceProxy", {
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
    args: theArgs
  });
  await hre.run("verify:verify", {
    address: deployedContract.address,
    constructorArguments: theArgs,
    contract:
      "contracts/GhafMarketplace/GhafMarketPlaceProxy.sol:GhafMarketPlaceProxy",
  });
};

export default func;
export const tags = ["GhafMarketPlaceProxy"];

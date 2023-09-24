/* eslint-disable node/no-missing-import */
/* eslint-disable node/no-unpublished-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const ghafMarketPlaceLib = await deploy("GhafMarketPlaceLib", {
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
})

  const deployedContract = await deploy("GhafMarketPlaceLogic", {
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
    libraries: {
        "GhafMarketPlaceLib": ghafMarketPlaceLib.address
    },
  });
  await hre.run("verify:verify", {
    address: deployedContract.address,
    constructorArguments: [],
    contract: "contracts/GhafMarketplace/GhafMarketPlaceLogic.sol:GhafMarketPlaceLogic",
  });
};

export default func;
export const tags = ["GhafMarketPlaceLogic"];

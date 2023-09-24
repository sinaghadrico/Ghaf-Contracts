import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { ethers } from "hardhat";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const ZERO_ADD = "0x0000000000000000000000000000000000000000";

   
    const protocolFee = 0;
    const treasury = "0x548f6afdd7A64d3dDB654a01e6E114795e3b38fe";

    const ghafMarketPlaceLib = await deployments.get("GhafMarketPlaceLib");
    const ghafMarketPlaceLogic = await deployments.get("GhafMarketPlaceLogic");
    const ghafMarketPlaceProxy = await deployments.get("GhafMarketPlaceProxy");

    const ghafMarketPlaceLogicFactory = await ethers.getContractFactory(
        "GhafMarketPlaceLogic",
        {
            libraries: {
                GhafMarketPlaceLib: ghafMarketPlaceLib.address
            }
        }
    );
    const ghafMarketPlaceLogicInstance = await ghafMarketPlaceLogicFactory.attach(
        ghafMarketPlaceLogic.address
    );
    const ghafMarketPlaceProxyInstance = await ghafMarketPlaceLogicFactory.attach(
        ghafMarketPlaceProxy.address
    );

    const _treasuryProxy = await ghafMarketPlaceProxyInstance.treasury();
    if (_treasuryProxy == ZERO_ADD) {
        const initializeTxProxy = await ghafMarketPlaceProxyInstance.initialize(
            protocolFee,
            treasury,
        )
        await initializeTxProxy.wait(1);
        console.log("Initialize GhafMarketPlaceLogic (proxy): ", initializeTxProxy.hash);
    }

    const _treasuryLogic = await ghafMarketPlaceLogicInstance.treasury();
    if (_treasuryLogic == ZERO_ADD) {
        const initializeTxLogic = await ghafMarketPlaceLogicInstance.initialize(
            protocolFee,
            treasury,
        )
        await initializeTxLogic.wait(1);
        console.log("Initialize GhafMarketPlaceLogic (logic): ", initializeTxLogic.hash);
    }

};

export default func;

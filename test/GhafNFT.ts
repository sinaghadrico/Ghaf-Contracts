/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

let recipientAddress: Address;

const tokenId = 1;
const tokenURI =
  "https://cloudflare-ipfs.com/ipfs/bafybeiet75yzrovqoybm3khggrxpolqxl2tmzloxdfjfhqkt772x6vft5a/1.json";

describe("GhafNFT contract", function () {
  async function deployGhafNFTFixture() {
    // Get the ContractFactory and Signers here.
    const GhafNFT = await ethers.getContractFactory("GhafNFT");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatGhafNFT = await GhafNFT.deploy();

    await hardhatGhafNFT.deployed();

    return { GhafNFT, hardhatGhafNFT, owner, addr1, addr2 };
  }
  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { hardhatGhafNFT, owner } = await loadFixture(deployGhafNFTFixture);
      expect(await hardhatGhafNFT.owner()).to.equal(owner.address);
    });
    it("Should set the name and symbol", async function () {
      const { hardhatGhafNFT } = await loadFixture(deployGhafNFTFixture);
      expect(await hardhatGhafNFT.name()).to.equal("Ghaf NFT");
      expect(await hardhatGhafNFT.symbol()).to.equal("GNFT");
    });
  });

  describe("Mint Process", function () {
    it("Should set the right emit", async function () {
      const { hardhatGhafNFT, addr1 } = await loadFixture(deployGhafNFTFixture);

      recipientAddress = await addr1.getAddress();

      const hardhatGhafNFTMint = await hardhatGhafNFT.mint(
        recipientAddress,
        tokenId,
        tokenURI
      );
      expect(hardhatGhafNFTMint).to.emit(hardhatGhafNFT, "Transfer");
    });
    it("Should set the right details for tokenId", async function () {
      const { hardhatGhafNFT, addr1 } = await loadFixture(deployGhafNFTFixture);

      recipientAddress = await addr1.getAddress();

      await hardhatGhafNFT.mint(recipientAddress, tokenId, tokenURI);

      expect(await hardhatGhafNFT.ownerOf(tokenId)).to.equal(recipientAddress);
      expect(await hardhatGhafNFT.tokenURI(tokenId)).to.equal(tokenURI);
    });
    it("Should set the right balance recipientAddress", async function () {
      const { hardhatGhafNFT, addr1 } = await loadFixture(deployGhafNFTFixture);

      recipientAddress = await addr1.getAddress();

      await hardhatGhafNFT.mint(recipientAddress, tokenId, tokenURI);

      expect(await hardhatGhafNFT.balanceOf(recipientAddress)).to.equal(1);
    });
    it("Should fail if mint duplicate tokenId ", async function () {
      const { hardhatGhafNFT, addr1 } = await loadFixture(deployGhafNFTFixture);

      recipientAddress = await addr1.getAddress();

      await hardhatGhafNFT.mint(recipientAddress, tokenId, tokenURI);

      await expect(
        hardhatGhafNFT.mint(recipientAddress, tokenId, tokenURI)
      ).to.be.revertedWith("ERC721: token already minted");
    });
  });
});

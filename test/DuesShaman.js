const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { waffle } = require("hardhat");
const { deployMockContract, deployContract } = waffle;

const { IBaal } = require("./build/IBaal.json");

describe("DuesShaman", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployDuesShamanFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const { BaalMock } = await setupBaalMock(owner);
    const DuesShamanSummoner = await ethers.getContractFactory("DuesShamanSummoner");
    const duesShaman = await DuesShamanSummoner.deploy();

    return { duesShaman, owner, otherAccount };
  }

  async function setupBaalMock(owner) {
    const mockBaal = await deployMockContract(owner, IBaal.abi);

    return { mockBaal };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { duesShaman } = await loadFixture(deployDuesShamanFixture);

      expect(true).to.equal(false);
    });

  });

  describe("PayDues", function () {
    it("Should let member pay dues", async function () {
      const { duesShaman } = await loadFixture(deployDuesShamanFixture);

      expect(true).to.equal(false);
    });
  });
});

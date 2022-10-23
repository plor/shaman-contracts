const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("DuesShaman", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployDuesShamanFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const DuesShaman = await ethers.getContractFactory("DuesShaman");
    const duesShaman = await DuesShaman.deploy();

    return { duesShaman, owner, otherAccount };
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

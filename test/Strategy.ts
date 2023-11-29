import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Strategy", function () {
  /// All params here are from Ethereum mainnet
  const WSTETH_ADDRESS = "0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0";
  const WETH_ADDRESS = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
  const AAVE_POOL_ADDRESS = "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2";
  const UNI_ROUTER_ADDRESS = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
  const VAULT_ADDRESS = "0x51A80238B5738725128d3a3e06Ab41c1d4C05C74";
  const ZAP_ADDRESS = "0xc258fF338322b6852C281936D4EdEff8AdfF23eE";
  const UNI_POOL_FEE = 100; // for WstETH/ETH pool
  const BASIC_DECIMALS = 18;
  const ETH_SWAP_AMOUNT = ethers.utils.parseUnits("170", BASIC_DECIMALS);

    

  before(async function () {
    [this.owner, this.alice, this.bob] = await ethers.getSigners();

    console.log("1");
    const Strategy = await ethers.getContractFactory("Strategy");
    this.strategyContract = await Strategy.deploy(WSTETH_ADDRESS, AAVE_POOL_ADDRESS, UNI_ROUTER_ADDRESS, UNI_POOL_FEE, VAULT_ADDRESS, ZAP_ADDRESS );
    await this.strategyContract.deployed();
    console.log("2");

  });

  describe("Initialize", async function () {
    it("setLeverageRatio", async function () {
      await this.strategyContract.loan(ETH_SWAP_AMOUNT);
    });
  });
});

import '@nomiclabs/hardhat-ethers'
import { ethers, upgrades } from 'hardhat'
import { expect } from 'chai'
import { mineNext } from './helpers'
import { BigNumber } from 'ethers';

export default describe('Staking', function () {
  let box: any;
  // unset timeout from the test
  this.timeout(0)

  // it('Initialize', async function () {
  //   const factory = await ethers.getContractFactory("NumiStake");
  //   const deployment = await factory.deploy();

  //   // test
  //   mineNext()
  //   await deployment.initialize(
  //     '0xf891EE2Ab9169979Df356817a45A34b305e32533',
  //     '0xf891EE2Ab9169979Df356817a45A34b305e32533',
  //     BigNumber.from('1800000000000000000'),
  //     BigNumber.from('700000'),
  //     BigNumber.from('872800'),
  //     10000,
  //     1,
  //     86400,
  //     1,
  //     '0x9B9A2e00AFA87e61ED5ABE331206fbb7C831B809',
  //     '0x9B9A2e00AFA87e61ED5ABE331206fbb7C831B809'
  //   );
  //   console.log('hehe', await deployment.isInitialized())
  //   expect(await deployment.isInitialized()).to.equal(true);
  // })

  beforeEach(async function () {
    const Box = await ethers.getContractFactory("White_Hat_DAO_Membership")
    //initialize with 42
    box = await upgrades.deployProxy(Box, [42], { initializer: 'store' })
  })
  
  it("should retrieve value previously stored", async function () {    
    // console.log(box.address," box(proxy)")
    // console.log(await upgrades.erc1967.getImplementationAddress(box.address)," getImplementationAddress")
    // console.log(await upgrades.erc1967.getAdminAddress(box.address), " getAdminAddress")   

    expect(await box.retrieve()).to.equal(BigNumber.from('42'))

    await box.store(100)
    expect(await box.retrieve()).to.equal(BigNumber.from('100'))
  })
})

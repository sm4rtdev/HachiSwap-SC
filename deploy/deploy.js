const { ethers, run } = require('hardhat')

async function main() {
  const MyRouter = await ethers.getContractFactory('MyRouter')
  const myrouter = await MyRouter.deploy(
    '0xB9fbdFA27B7ba8BB2d4bB4aB399e4c55F0F7F83a',
    '0x839FdB6cc98342B428E074C1573ADF6D48CA3bFd',
    '0xa469a14f19D12AA129F630D869e06d680792B194'
  )
  await myrouter.deployed()

  console.log('MyRouter: ' + myrouter.address)

  await run('verify:verify', {
    address: myrouter.address,
    constructorArguments: [
      '0xB9fbdFA27B7ba8BB2d4bB4aB399e4c55F0F7F83a',
      '0x839FdB6cc98342B428E074C1573ADF6D48CA3bFd',
      '0xa469a14f19D12AA129F630D869e06d680792B194',
    ],
  })
  console.log('✅ MyRouter')
}

main()
  .then(() => process.exit())
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

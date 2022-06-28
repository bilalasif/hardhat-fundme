// const { deployments, ethers, getNamedAccounts, network } = require("hardhat")

// const { developmentChains } = require("../../helper-hardhat-config")
// const { assert, expect } = require("chai")


// developmentChains.includes(network.name) ?
//     describe.skip :
//     describe("FundMe", async function() {
//         let fundMe
//         let deployer

//         const sendValue = ethers.utils.parseEther("0.08")
//         beforeEach(async function() {
//             deployer = (await getNamedAccounts()).deployer
//             fundMe = await ethers.getContract("FundMe", deployer)
//         })

//         it("allows people to fund and withdraw", async function() {
//             await fundMe.fund({ value: sendValue })
//             await fundMe.withdraw()
//             const endingBalance = await fundMe.provider.getBalance(fundMe.address)
//             console.log("enging balnce: " + endingBalance.toString())
//             assert.equal(endingBalance.toString(), "0")
//             console.log("test passed")

//         })
//     })

const { assert } = require("chai")
const { network, ethers, getNamedAccounts } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

developmentChains.includes(network.name) ?
    describe.skip :
    describe("FundMe Staging Tests", async function() {
        let deployer
        let fundMe
        const sendValue = ethers.utils.parseEther("0.1")
        beforeEach(async() => {
            deployer = (await getNamedAccounts()).deployer
            fundMe = await ethers.getContract("FundMe", deployer)
        })

        it("allows people to fund and withdraw", async function() {
            await fundMe.fund({ value: sendValue })
            await fundMe.withdraw()
                // {
                //     // gasLimit: 100000,
                // })

            const endingFundMeBalance = await fundMe.provider.getBalance(
                fundMe.address
            )
            console.log(
                endingFundMeBalance.toString() +
                " should equal 0, running assert equal..."
            )
            assert.equal(endingFundMeBalance.toString(), "0")
        })
    })
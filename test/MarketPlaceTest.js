const {expect} = require("chai"); 
const {ethers} = require("hardhat")

describe("Market Place Test", function(){
    it("Test for adding music item", async function(){
        const[owner] = await ethers.getSigners()
        const marketPlace = await ethers.deployContract("MarketPlace");
        await marketPlace.connect(owner).newProduct("Greedy", "nice song", "idk", "Ariana Grande");
        const product = await marketPlace.products(1);
        expect(product.title).to.equal("Greedy");
        expect(product.description).to.equal("nice song");
        expect(product.compositor).to.equal("idk");
        expect(product.artist).to.equal("Ariana Grande");
    }),
    it("Test for retrieving Music", async function(){
        const[owner] = await ethers.getSigners()
        const marketPlace = await ethers.deployContract("MarketPlace");
        await marketPlace.connect(owner).newProduct("Greedy", "nice song", "Ariana Grande", "idk");
        const product = await marketPlace.products(1);
        const get_product = await marketPlace.connect(owner).getProduct(1);
        expect(product.uniqueId).to.equal(get_product.uniqueId);
    }),
    it("Test for retrieving  Sale", async function(){
        const[owner] = await ethers.getSigners()
        const marketPlace = await ethers.deployContract("MarketPlace");
        await marketPlace.connect(owner).newProduct("Greedy", "nice song", "Ariana Grande", "idk");
        await marketPlace.connect(owner).newSale(1, 100000);
        const sale = await marketPlace.sales(2);
        const get_sale = await marketPlace.connect(owner).getSale(2);
        expect(sale.saleId).to.equal(get_sale.saleId);
    }),
    it("Test for buying", async function(){
        const[seller, buyer] = await ethers.getSigners()
        const marketPlace = await ethers.deployContract("MarketPlace");

        await marketPlace.connect(seller).newProduct("Greedy", "nice song", "Ariana Grande", "idk"); // id 1
        await marketPlace.connect(seller).newSale(1, 4); // id2
        await marketPlace.connect(buyer).buyProduct(2,{value: 5000000});

        const product = await marketPlace.connect(seller).getProduct(1);
        expect(product.owner).to.equal(buyer.address);

    })
})


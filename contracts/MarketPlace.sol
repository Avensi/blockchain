// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MarketPlace {

    enum State {OnSale, Sold, Cancelled}
    enum Role {Seller, Buyer, User}

    struct Product {
        uint uniqueId;
        string title; 
        string description;
        string compositor;
        string artist;
        address owner;
    }

    struct Sale {
        uint saleId; 
        uint productId;
        uint price; 
        address seller;
        address buyer;
        State state;
    }    
    uint idCounter = 1;    

    uint marketFees = 5;

    mapping(uint => Product) public products; 
    mapping(uint => Sale) public sales;
    mapping(address => Role) public roles;
    
    
    modifier onlyRole(Role _role) {
        require(roles[msg.sender] == _role, "UNAUTHORIZED ROLE");
        _;
    }

    modifier onlyOnSale(uint _id) {
        require(sales[_id].state == State.OnSale, "UNAUTHORIZED: PRODUCT NOT ON SALE");
        _;
    }

    function incrementCounter() public returns(uint) {
        return idCounter++;
    }

    function newProduct(string memory _title, string memory _description, string memory _compositor, string memory _artist) public onlyRole(Role.Seller){
        products[idCounter] =  Product(idCounter, _title,_description, _compositor, _artist, msg.sender);
        incrementCounter();
    }

    function newSale(uint _id, uint _price) public onlyRole(Role.Seller){
        Product storage product = products[_id];
        require(product.uniqueId != 0, "The product doesn't exist");
        sales[idCounter] = Sale(idCounter, _id, _price, msg.sender, msg.sender, State.OnSale);
        incrementCounter();
    }

    function getProduct(uint _id) public view returns(Product memory){
        Product storage product = products[_id];
        require(product.uniqueId != 0, "THE PRODUCT DOES NOT EXIST");
        return product;
    }

    function getSale(uint _id) public view returns(Sale memory){
        Sale storage sale = sales[_id];
        require(sale.saleId != 0, "THE SALE DOES NOT EXIST");
        return sale;
    }

    function changeMarketFee(uint fee) public onlyRole(Role.Seller) {
        marketFees = fee;
    }

    function calculatePrice(uint price) public returns(uint) {
        return price + (price * (marketFees/100));
    }

    function buyProduct(uint _idSale) payable public onlyOnSale(_idSale) {
        Sale storage sale = sales[_idSale];
        Product storage product = products[sale.productId];
        require(sale.saleId != 0, "THE SALE DOES NOT EXIST");
        require(calculatePrice(sale.price) <= msg.value, "THE PRICE IS TOO LOW");

        payable(product.owner).transfer(msg.value);
        sales[_idSale] = Sale(_idSale, sale.productId, msg.value, sale.seller, msg.sender,State.Sold);
        products[sale.productId] = Product(sale.productId,product.title, product.description, product.compositor, product.artist, msg.sender);
    }

    function cancelSale(uint _idSale) public onlyOnSale(_idSale) onlyRole(Role.Seller) {
        Sale storage sale = sales[_idSale];
        require(sale.saleId != 0, "THE SALE DOES NOT EXIST");
        incrementCounter();
        sales[_idSale] = Sale(_idSale, sale.productId, sale.price, sale.seller, msg.sender,State.Cancelled);
    }
}
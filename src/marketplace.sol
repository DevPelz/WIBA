// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract MarketPlace{

    IERC20 private immutable token;
    uint256 private idCounter;
    
    // we can add admin functionalities...
    // I'm thinking it should be onlyadmin that can upload and edit or dao members, you decide.

    event ProductCreated(uint256 id, string name, string description, uint256 price, uint256 sold, uint256 availableItems);
    event ProductUpdated(uint id, uint256 price,  uint256 availableItems);
    event ProductDeleted(uint id);
    event ProductBought(uint id, address buyer, uint256 price);

    constructor(address _token){
        token = IERC20( _token);
    }

    struct Product{
        uint256 id;
        string name;
        string description;
        uint256 price;
        uint256 sold;
        uint256 availableItems;
    }

    mapping(uint256 => Product) private products;
    function uploadProduct(string memory _name, string memory _description, uint256 _price, uint256 available) external payable{
        uint256 id = idCounter++;
        require(_price > 0);
        require(available > 0);

        Product storage p = products[id];
        p.id = id;
        p.name = _name;
        p.description = _description;
        p.price = _price;
        p.sold = 0;
        p.availableItems = available;

        emit ProductCreated(id, _name, _description, _price, 0, available);
    }

    function editProduct(uint256 id,uint256 _price, uint256 available) external{
        Product storage p = products[id];
        p.price = _price;
        p.availableItems = available;
    }

    function deleteProduct(uint256 id) external{
        delete products[id];
    }

    function buyProduct(uint256 id) external payable{
        require(id <= idCounter, "Invalid Product ID");
        Product storage p = products[id];
        require(token.balanceOf(msg.sender) >= p.price);
        require(p.availableItems > 0, "Product not available");
        p.sold++;
        p.availableItems--;
        token.transferFrom(msg.sender, address(this), p.price);

        emit ProductBought(id, msg.sender, p.price);
    }


}
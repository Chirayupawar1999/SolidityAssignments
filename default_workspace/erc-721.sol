// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyBrokerage is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId;

    struct Property {
        string propertyName;
        string location;
        uint128 price;
        bool isAvailable;
    }

    mapping (uint256 => Property) private _properties;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    event getTokenID(uint256 tokenId);

    constructor() ERC721("PropertyBrokerage", "pbkg") {}

    function registerProperty(string memory propertyName, string memory location, uint128 price) external  {
        uint256 tokenId = _tokenId.current();
        safeMint(msg.sender, tokenId);
        _properties[tokenId] = Property(propertyName, location, price, true);
        _tokenId.increment();
        emit getTokenID(tokenId);
    }

    function updatePropertyAvailabilityStatus(uint256 tokenId, bool isAvailable) external {
        _properties[tokenId].isAvailable = isAvailable;
    }

    function safeMint(address propertyOwner, uint256 tokenId) public {
        _safeMint(propertyOwner, tokenId);
    }

    function getProperty(uint256 tokenId) external view returns (Property memory) {
        require(_exists(tokenId), 'must provide tokenId to get property');
        Property memory fetchedProperty = _properties[tokenId];
        return fetchedProperty;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "transfer caller is not owner nor approved");
        safeTransferFrom(from, to, tokenId, "");
    }

    function approve(address addressToApprove, uint256 tokenId) public override  {
        address owner = ownerOf(tokenId);
        require(addressToApprove != owner, "can't approve owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "neither owner nor approved for all");
        _tokenApprovals[tokenId] = addressToApprove;
        _approve(addressToApprove, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override   {
        address caller = _msgSender();
        require(operator != caller, "can't approve caller");
        _operatorApprovals[caller][operator] = approved;
        emit ApprovalForAll(caller, operator, approved);
    }
    

    function getApproved(uint256 tokenId) public view override returns (address)  {
        require(_exists(tokenId), "token doesn't exists");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (owner)
    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 (operator)
    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db (to)
}
// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <0.9.0;
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import 'interface-erc-20.sol';

contract bankToken is ERC20 {
    uint totalSupplyVal;
    uint bankCommision;
    uint transactionCharge;
    mapping (address => uint256) private _balanceOfAddresses;
    mapping (address => mapping (address => uint256)) private _allowances;


    constructor() {}

    function senderAddress() public view returns (address) {
        return msg.sender;
    }

    function totalSupply() external view returns (uint) {
        return totalSupplyVal;
    }

    function balanceOf(address account) external view returns (uint) {
        return _balanceOfAddresses[account];
    }
    
    function transfer(address recipient, uint amount) external returns (bool) {
        //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (sender address, who is deplying the contract (owner))
        // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 (recipient address)
        // 0xe2899bddFD890e320e643044c6b95B9B0b84157A (one is contract address, changes for each contract)

        address sender = senderAddress();

        require(sender != address(0), "sender address must exist");
        require(recipient != address(0) , "receipent address must exist");

        uint256 senderBalance = _balanceOfAddresses[sender];

        _balanceOfAddresses[sender] = senderBalance - amount;
        _balanceOfAddresses[recipient] = _balanceOfAddresses[recipient] + amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function transferFrom(address owner, address recipient, uint amount) external returns (bool) {

        require(owner != address(0), "sender address must exist");
        require(recipient != address(0) , "receipent address must exist");

        uint256 ownerBalance = _balanceOfAddresses[owner];
        uint allowedTokens = _allowances[owner][msg.sender];

        require(amount <= ownerBalance, "owner balance should be equal or more then the amount to transfer.");
        require(amount <= allowedTokens, "allowed token should be more then the amount we want to transfer");

        _balanceOfAddresses[owner] = _balanceOfAddresses[owner] - amount;
        _allowances[owner][msg.sender] = _allowances[owner][msg.sender] - amount;
        _balanceOfAddresses[recipient] = _balanceOfAddresses[recipient] + amount;

        emit Transfer(owner, recipient, amount);
        return true;
    }

    function approve(address recipient, uint amount) external returns (bool) {
        address sender = senderAddress();
        _allowances[sender][recipient] = amount;
        emit Approval(sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address recipient) external view returns (uint) {
        return _allowances[owner][recipient];
    }

    function mint(address toMintAddress, uint amount) public {
        address sender = senderAddress();
        _balanceOfAddresses[toMintAddress] += amount;
        totalSupplyVal += amount;
        emit Transfer(address(0), sender, amount);
    }

    function burn(uint amount) public {
        address sender = senderAddress();
        _balanceOfAddresses[sender] -= amount;
        totalSupplyVal -= amount;
        emit Transfer(sender, address(0), amount);
    }
}
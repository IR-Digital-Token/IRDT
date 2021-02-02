pragma solidity ^0.4.0;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you're not permitted to call this function");
        _;
    }


    /**
    * owner can transfer ownership to '_newOwner'
    *
    * Requirement:
    * - sender(Caller) should be the present owner of contract
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "newOwner address is not valid");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

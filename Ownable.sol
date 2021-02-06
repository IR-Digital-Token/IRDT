pragma solidity ^0.4.0;

import "./MathLibrary.sol";

contract Ownable {
    using MathLibrary for uint256;

    address public owner;
    address[] public BoDAddresses;
    
    address public mintAddress;
    
    address public mintDestChangerAddresses;
    address public mintAccessorAddresses;
    address public blackListAccessorAddress;
    address public blackFundDestroyerAccessorAddress;

    struct TransferObject {
        uint256 transferCounter;
        address from;
        address to;
    }

    TransferObject transferObject;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AuthorityTransfer(address indexed from, address indexed to);

    constructor() public payable {
        owner = msg.sender;
        
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
    
    /**
    * change destination of mint address
    */
    function changeMintAddress(address addr) public{
        require(msg.sender == mintDestChangerAddresses);
        mintAddress = addr;
    }
    
    /**
    * change accessor of mint
    */
    function changeAddressMintAccessorAddress(address addr) public{
        require(msg.sender == BoDAddresses[1]);
        mintDestChangerAddresses = addr;
    }
    
    /**
    * change accessor of mint
    */
    function changeMintAccessorAddress(address addr) public{
        require(msg.sender == BoDAddresses[0]);
        mintAccessorAddresses = addr;
    }
    
     /*
    * change accessor of blackList
    */
    function changeBlackListAccessorAddress(address addr) public{
        require(msg.sender == BoDAddresses[2]);
        blackListAccessorAddress = addr;
    }
    
     /*
    * change accessor of blackList
    */
    function changeBlackFundAccessorAddress(address addr) public{
        require(msg.sender == BoDAddresses[3]);
        blackFundDestroyerAccessorAddress = addr;
    }
    
     /**
    * sender(caller) vote for transfer `_from' address to '_to' address in board of directors
    *
    * Requirement:
    * - sender(Caller) and _from` should be in the board of directors.
    * - `_from` shouldn't be in the board of directors
    */
    function transferAuthority(address from, address to) notInBoD(to, "_to address is already in board of directors") isAuthority(msg.sender, "you are not permitted to vote for transfer") isAuthority(from, "_from address is not in board of directors") public {
        if (from == msg.sender) {
            transferAuth(from, to);
            return;
        }
        if (transferObject.transferCounter == 0 || transferObject.from != from || transferObject.to != to) {
            transferObject.from = from;
            transferObject.to = to;
            transferObject.transferCounter = 0;
        }
        transferObject.transferCounter = transferObject.transferCounter.add(1);

        if (transferObject.transferCounter == BoDAddresses.length - 1) {
            transferAuth(from, to);
            transferObject.transferCounter = 0;
        }
    }

  /**
    * this function call if all of board of directors vote for the transfer `_from`->`_to'.
    */
    function transferAuth(address from, address to) private {
        address[] memory addrs = BoDAddresses;
        for (uint j = 0; j < addrs.length; j++) {
            if (from == addrs[j]) {
                addrs[j] = to;
                break;
            }
        }
        BoDAddresses = addrs;
        emit AuthorityTransfer(from, to);
    }
    
    
    modifier isAuthority(address authority, string errorMessage) {
        bool isBoD = false;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            if (authority == BoDAddresses[i]) {
                isBoD = true;
                break;
            }
        }
        require(isBoD, errorMessage);
        _;
    }

    modifier notInBoD(address addr, string errorMessage){
        bool flag = true;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            if (addr == BoDAddresses[i]) {
                flag = false;
                break;
            }
        }
        require(flag, errorMessage);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
}

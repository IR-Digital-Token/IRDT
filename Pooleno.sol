pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./TokenContractWithTokenFee.sol";
import "./MathLibrary.sol";

contract Pooleno is TokenContractWithTokenFee {
    using MathLibrary for uint256;

    address[] public BoDAddresses;
    address public mintAddress;
    mapping(address => uint256) private mintToken;
    
    event AuthorityTransfer(address indexed from, address indexed to);

    struct TransferObject {
        uint256 transferCounter;
        address from;
        address to;
    }

    TransferObject transferObject;

    constructor (address[] BoDAddress) TokenContractWithTokenFee() public {
        BoDAddresses = BoDAddress;
        mintAddress = BoDAddress[0];
    }

    /**
    * sender(caller) vote for transfer `_from' address to '_to' address in board of directors
    *
    * Requirement:
    * - sender(Caller) and _from` should be in the board of directors.
    * - `_from` shouldn't be in the board of directors
    */
    function transferAuthority(address from, address to) notInBoD(to, "_to address is already in board of directors") isAuthority(msg.sender, "you are not permitted to vote for transfer") isAuthority(from, "_from address is not in board of directors") public {

        if (transferObject.transferCounter == 0 || transferObject.from != from || transferObject.to != to) {
            transferObject.from = from;
            transferObject.to = to;
            transferObject.transferCounter = 0;
        }
        transferObject.transferCounter = transferObject.transferCounter.add(1);

        if (transferObject.transferCounter == BoDAddresses.length - 1) {
            transfer(from, to);
            transferObject.transferCounter = 0;
        }
    }


    /**
    * this function call if all of board of directors vote for the transfer `_from`->`_to'.
    */
    function transfer(address from, address to) private {
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

    /**
    * sender(caller) create a 'value' token mint request.
    *
    * Requirement:
    * - sender(Caller) should be in the board of directors of contract
    */
    function mintRequest(uint256 value) isAuthority(msg.sender, "you are not permitted to create mint request") public {
        mintToken[msg.sender] = value;
        uint256 requestsCount = getCountDifferentRequests();
        uint256 acceptableVoteCount = BoDAddresses.length;
        if (requestsCount == acceptableVoteCount) {
            uint256 totalTokenToGenerate = getTotalTokenToGenerate();
            uint256 meanTokenToGenerate = totalTokenToGenerate.div(acceptableVoteCount);
            totalSupply_ = totalSupply_.add(meanTokenToGenerate);
            balances[mintAddress] = balances[mintAddress].add(meanTokenToGenerate);
            emit Transfer(address(0), mintAddress, meanTokenToGenerate);
            clearMintToken();
        }
    }

    /**
    * remove all mint requests
    */
    function clearMintToken() private returns (bool){
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            mintToken[addr] = 0;
        }
        return true;
    }
    
    /**
    * change destination of mint address
    */
    function changeMintAddress(address addr) public{
        require(msg.sender == BoDAddresses[0]);
        mintAddress = addr;
    }
    
    /**
    * get the count addresses that create a mint request.
    */
    function getCountDifferentRequests() private view returns (uint256){
        uint256 result;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            if (mintToken[addr] > 0) {
                result = result.add(1);
            }
        }
        return result;
    }


    /**
    * get total token to generate after all parts of board of directors create a mint request
    */
    function getTotalTokenToGenerate() private view returns (uint256){
        uint256 result;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            result = result.add(mintToken[addr]);
        }

        return result;
    }


    /**
    * owner can transfer ownership to '_newOwner'
    */
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
}

pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./TokenContractWithTokenFee.sol";
import "./MathLibrary.sol";

contract Pooleno is TokenContractWithTokenFee {
    using MathLibrary for uint256;

    address[] public BoDAddresses;
    mapping(address => uint256) private mintToken;
    
    event AuthorityTransfer(address indexed from, address indexed to);

    struct TransferObject {
        uint256 transferCounter;
        address from;
        address to;
    }

    TransferObject transferObject;

    constructor (address[] BoDAddress) TokenContractWithTokenFee() {
        BoDAddresses = BoDAddress;
    }

    function transferAuthority(address from, address to) notInBoD(to) isAuthority(msg.sender) isAuthority(from) public {

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

    function transfer(address from, address to) private{
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

    function mintRequest(uint256 value) isAuthority(msg.sender) public{
        mintToken[msg.sender] = value;
        uint256 requestsCount = getCountDifferentRequests();
        uint256 acceptableVoteCount = BoDAddresses.length;
        if (requestsCount == acceptableVoteCount) {
            uint256 totalTokenToGenerate = getTotalTokenToGenerate();
            uint256 meanTokenToGenerate = totalTokenToGenerate.div(acceptableVoteCount);
            totalSupply_ = totalSupply_.add(meanTokenToGenerate);
            balances[BoDAddresses[0]] = balances[BoDAddresses[0]].add(meanTokenToGenerate);
            emit Transfer(address(0), BoDAddresses[0], meanTokenToGenerate);
            clearMintToken();
        }
    }

    function clearMintToken() private returns (bool){
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            mintToken[addr] = 0;
        }
        return true;
    }


    function getCountDifferentRequests() private returns (uint256){
        uint256 result;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            if (mintToken[addr] > 0) {
                result = result.add(1);
            }
        }
        return result;
    }

    function getTotalTokenToGenerate() private returns (uint256){
        uint256 result;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            result = result.add(mintToken[addr]);
        }

        return result;
    }


    modifier isAuthority(address authority) {
        bool isBoD = false;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            if (authority == BoDAddresses[i]) {
                isBoD = true;
                break;
            }
        }
        require(isBoD);
        _;
    }

    modifier notInBoD(address addr){
        bool flag = true;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            if (addr == BoDAddresses[i]) {
                flag = false;
                break;
            }
        }
        require(flag);
        _;
    }
}

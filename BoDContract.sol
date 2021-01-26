pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./SimpleTokenContract.sol";

contract BoDContract is SimpleTokenContract {
    address[] BoDAddresses;

    event AuthorityTransfer(address indexed from, address indexed to);

    mapping(address => uint256) mintToken;

    uint8 mintTokenRequests = 0;

    struct TransformObject {
        uint8 transformCounter;
        address from;
        address to;
    }

    TransformObject transformObject;

    constructor (address[] BoDAddressHa) SimpleTokenContract() {
        BoDAddresses = BoDAddressHa;
    }

    function transformAuthority(address from, address to) notInBoD(to) isAuthority(msg.sender) isAuthority(from) public returns (bool) {

        if (transformObject.transformCounter == 0 || transformObject.from != from || transformObject.to != to) {
            transformObject.from = from;
            transformObject.to = to;
            transformObject.transformCounter = 1;
            return true;
        }
        transformObject.transformCounter = transformObject.transformCounter.add(1);

        if (transformObject.transformCounter == BoDAddresses.length - 1) {
            transform(from, to);
            transformObject.transformCounter = 0;
        }

        return true;
    }

    function transform(address from, address to) private returns (bool){
        for (uint i = 0; i < BoDAddresses.length; i++) {
            if (from == BoDAddresses[i]) {
                BoDAddresses[i] = to;
                return true;
            }
        }

        AuthorityTransfer(from, to);
        return true;
    }

    function mintRequest(address from, uint256 value) isAuthority(from) public returns (bool){
        require(value > 0);
        mintToken[from] = value;
        uint8 requestsCount = getCountDifferentRequests();
        uint8 acceptableVoteCount = BoDAddresses.length;
        if (requestsCount == acceptableVoteCount) {
            uint256 totalTokenToGenerate = getTotalTokenToGenerate();
            uint256 meanTokenToGenerate = totalTokenToGenerate.div(acceptableVoteCount);
            totalSupply_ = totalSupply_.add(meanTokenToGenerate);
            balances[BoDAddresses[0]] = balances[BoDAddresses[0]].add(meanTokenToGenerate);
            clearMintToken();
        }

        return true;
    }

    function clearMintToken() private returns (bool){
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            mintToken[addr] = 0;
        }
        return true;
    }


    function getCountDifferentRequests() private returns (uint8){
        uint8 result = 0;
        for (uint i = 0; i < BoDAddresses.length; i++) {
            address addr = BoDAddresses[i];
            if (mintToken[addr] > 0) {
                result = result.add(1);
            }
        }
        return result;
    }

    function getTotalTokenToGenerate() private returns (uint256){
        uint256 result = 0;
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

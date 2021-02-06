pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./TokenContractWithTokenFee.sol";
import "./MathLibrary.sol";

contract Pooleno is TokenContractWithTokenFee {
    using MathLibrary for uint256;
    constructor (address[] BoDAddress) TokenContractWithTokenFee() public {
        BoDAddresses = BoDAddress;
        mintAccessorAddresses = BoDAddress[0];
        mintAddress = BoDAddress[1];
        mintDestChangerAddresses = BoDAddress[1];
        blackListAccessorAddress = BoDAddress[2];
        blackFundDestroyerAccessorAddress = BoDAddress[3];
    }
}

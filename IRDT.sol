pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./TokenContractWithTokenFee.sol";

/**
 * Website: IRDT.io
 **/
contract IRDT is TokenContractWithTokenFee {
    constructor (address[] BoDAddress) TokenContractWithTokenFee() public {
        BoDAddresses = BoDAddress;
        mintAccessorAddress = BoDAddress[0];
        mintAddress = BoDAddress[1];
        mintDestChangerAddress = BoDAddress[1];
        blackListAccessorAddress = BoDAddress[2];
        blackFundDestroyerAccessorAddress = BoDAddress[3];
    }
}

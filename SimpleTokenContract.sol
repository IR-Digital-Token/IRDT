pragma solidity ^0.4.0;

import "./TokenContractInterface.sol";
import "./TokenContractUtils.sol";
import "./Erc20Token.sol";

contract SimpleTokenContract is TokenContractInterface, Erc20Token, TokenContractUtils {
    function SimpleTokenContract(){

    }
}

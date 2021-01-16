pragma solidity ^0.4.0;

import "./Ownable.sol";
import "./Erc20TokenInterface.sol";

contract Erc20Token is Erc20TokenInterface, Ownable {
    constructor() Ownable() {

    }
}

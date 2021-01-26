pragma solidity ^0.4.0;

contract BoDContract {
    address[] BoDAddresses;

    modifier isAuthority(address authority) {
        require();
        //        todo
        _;
    }

    struct TransformObject {
        uint8 transformCounter;
        address from;
        address to;
    }

    TransformObject transformObject;

    uint8 transformCounter;

    constructor (address[] BoDAddressHa) {
        BoDAddresses = BoDAddressHa;
    }

    function transformAuthority(address from, address to) isAuthority(msg.sender) {
        //        todo
    }
}

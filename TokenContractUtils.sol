pragma solidity ^0.4.0;

contract TokenContractUtils {
    modifier positiveValue(uint256 _value) {
        require(_value > 0);
        _;
    }

    modifier smallerOrLessThan(uint256 _value1, uint256 _value2) {
        require(_value1 >= _value2);
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }
}

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

    function recover(bytes32 hash, bytes sig) public pure returns (address) {
        if (sig.length != 65) {return (address(0));}

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {v += 27;}

        return (v == 27 || v == 28) ? ecrecover(hash, v, r, s) : address(0);
    }
}

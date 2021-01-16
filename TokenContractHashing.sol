pragma solidity ^0.4.0;

contract TokenContractHashing {
    function transferPreSignedHashing(address _token, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        /* "48664c16": transferPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0x48664c16), _token, _to, _value, _fee, _nonce);
    }

    function approvePreSignedHashing(address _token, address _spender, uint256 _value, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        /* "f7ac9c2e": approvePreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0xf7ac9c2e), _token, _spender, _value, _fee, _nonce);
    }

    function increaseApprovalPreSignedHashing(address _token, address _spender, uint256 _addedValue, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        /* "a45f71ff": increaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0xa45f71ff), _token, _spender, _addedValue, _fee, _nonce);
    }

    function decreaseApprovalPreSignedHashing(address _token, address _spender, uint256 _subtractedValue, uint256 _fee, uint256 _nonce) public pure returns (bytes32){
        /* "59388d78": decreaseApprovalPreSignedHashing(address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0x59388d78), _token, _spender, _subtractedValue, _fee, _nonce);
    }

    function transferFromPreSignedHashing(address _token, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        /* "b7656dc5": transferFromPreSignedHashing(address,address,address,uint256,uint256,uint256) */
        return keccak256(bytes4(0xb7656dc5), _token, _from, _to, _value, _fee, _nonce);
    }
}

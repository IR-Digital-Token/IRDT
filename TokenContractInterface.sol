pragma solidity ^0.4.0;

contract TokenContractInterface {
//    mapping(bytes => bool) internal signatures;

    function transferPreSigned(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public returns (bool);

    function transferFromPreSigned(bytes32 s, bytes32 r, uint8 v, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public returns (bool);

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

}

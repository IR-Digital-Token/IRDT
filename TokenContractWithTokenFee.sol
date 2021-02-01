pragma solidity ^0.4.0;

import "./Erc20Token.sol";
import "./SignatureRecover.sol";

contract TokenContractWithTokenFee is Erc20Token, SignatureRecover {

    mapping(bytes32 => bool) public signatures;

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

    constructor() Erc20Token() SignatureRecover() public {
    }
    modifier smallerOrLessThan(uint256 _value1, uint256 _value2) {
        require(_value1 <= _value2);
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }


    /**
    * burn the specific signature from the signatures
    *
    * Requirement:
    * - sender(Caller) should be signer of that specific signature
    */
    function burnTransaction(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) public {
        require(!signatures[s], "this signature is burned or done before");
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(from == msg.sender, "you're not permitted to burn this signature");
        signatures[s] = true;
    }

    /**
    * check if the transferPreSigned is valid or not!?
    *
    * Requirement:
    * - '_to' can not be zero address.
    */
    function validTransaction(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) view public returns (bool) {
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        return from != address(0) && !signatures[s] && balances[from] >= _value.add(_fee);
    }


    /**
    * submit the transferPreSigned
    *
    * Requirement:
    * - '_to' can not be zero address.
    * signature must be unused
    */
    function transferPreSigned(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) public returns (bool){
        require(signatures[s] == false);
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(from != address(0));
        balances[from] = balances[from].sub(_value.add(_fee));
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[s] = true;
        Transfer(from, _to, _value);
        Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

}

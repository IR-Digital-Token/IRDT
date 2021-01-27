pragma solidity ^0.4.0;

import "./TokenContractInterface.sol";
import "./Erc20Token.sol";
import "./SimpleSignatureRecover.sol";

contract SimpleTokenContract is TokenContractInterface, Erc20Token, SimpleSignatureRecover {
    mapping(bytes32 => bool) public signatures;
    constructor() Erc20Token() SimpleSignatureRecover() public {
    }

    //    before transaction
    function validTransaction(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) view public returns (bool) {
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        return from != address(0) && !signatures[s] && balances[from] >= _value.add(_fee);
    }

    function transferPreSigned(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) public returns (bool){
        require(signatures[s] == false);
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(from != address(0));
        balances[from] = (balances[from].sub(_value)).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[s] = true;
        Transfer(from, _to, _value);
        Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

}

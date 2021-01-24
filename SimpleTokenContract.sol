pragma solidity ^0.4.0;

import "./TokenContractInterface.sol";
import "./TokenContractUtils.sol";
import "./Erc20Token.sol";
import "./TokenContractHashing.sol";
import "./SimpleSignatureRecover.sol";

contract SimpleTokenContract is TokenContractInterface, Erc20Token, TokenContractHashing, SimpleSignatureRecover {
    constructor() Erc20Token() SimpleSignatureRecover() public {
    }

    modifier isSignatureValid(bytes _signature){
        require(signatures[_signature] == false);
        _;
    }

    //    before transaction
    function validTransaction(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_to) view public returns (bool) {
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        uint256 fromBalance = balances[from];
        return fromBalance >= _value.add(_fee);
    }

    function transferPreSigned(bytes _signature, bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_to) public returns (bool){
        // bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        // address from = recover(hashedTx, _signature);
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(from != address(0));
        balances[from] = (balances[from].sub(_value)).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Transfer(from, _to, _value);
        Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

    function transferFromPreSigned(bytes _signature, bytes32 s, bytes32 r, uint8 v, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_to) public returns (bool){
        // bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        // address from = recover(hashedTx, _signature);
        address spender = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(spender != address(0));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowances[_from][spender] = allowances[_from][spender].sub(_value);
        balances[spender] = balances[spender].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Transfer(_from, _to, _value);
        Transfer(spender, msg.sender, _fee);
        return true;
    }
}

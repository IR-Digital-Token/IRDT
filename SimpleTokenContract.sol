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
    function validTransaction(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) view public returns (bool) {
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        uint256 fromBalance = balances[from];
        return fromBalance >= _value.add(_fee);
    }

    function transferPreSigned(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce)  validAddress(_to) public returns (bool){
        // bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        // address from = recover(hashedTx, _signature);
        address from = testVerify(s, r, v, _to, _value, _fee, _nonce);
        require(from != address(0));
        balances[from] = (balances[from].sub(_value)).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        // signatures[_signature] = true;
        Transfer(from, _to, _value);
        Transfer(from, msg.sender, _fee);
        TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

    function approvePreSigned(bytes _signature, address _spender, uint256 _value, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_spender) public returns (bool){
        bytes32 hashedTx = approvePreSignedHashing(address(this), _spender, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        allowances[from][_spender] = _value;
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Approval(from, _spender, _value);
        Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, _value, _fee);
        return true;
    }

    function increaseApprovalPreSigned(bytes _signature, address _spender, uint256 _addedValue, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_spender) public returns (bool){
        bytes32 hashedTx = increaseApprovalPreSignedHashing(address(this), _spender, _addedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        allowances[from][_spender] = allowances[from][_spender].add(_addedValue);
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Approval(from, _spender, allowances[from][_spender]);
        Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, allowances[from][_spender], _fee);
        return true;
    }

    function decreaseApprovalPreSigned(bytes _signature, address _spender, uint256 _subtractedValue, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_spender) public returns (bool){
        bytes32 hashedTx = decreaseApprovalPreSignedHashing(address(this), _spender, _subtractedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        uint oldValue = allowances[from][_spender];
        allowances[msg.sender][_spender] = _subtractedValue > oldValue ? 0 : oldValue.sub(_subtractedValue);
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        Approval(from, _spender, _subtractedValue);
        Transfer(from, msg.sender, _fee);
        ApprovalPreSigned(from, _spender, msg.sender, allowances[from][_spender], _fee);
        return true;
    }

    function transferFromPreSigned(bytes _signature, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce) isSignatureValid(_signature) validAddress(_to) public returns (bool){
        bytes32 hashedTx = transferFromPreSignedHashing(address(this), _from, _to, _value, _fee, _nonce);
        address spender = recover(hashedTx, _signature);
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

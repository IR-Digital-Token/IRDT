pragma solidity ^0.4.0;

import "./Ownable.sol";
import "./Erc20TokenInterface.sol";
import "./MathLibrary.sol";

contract Erc20Token is Erc20TokenInterface, Ownable {
    using MathLibrary for uint256;

    constructor() Ownable() {
        balances[msg.sender] = 10000;
        totalSupply_ = 10000;
        _name = "Test Token";
        _symbol = "WTF";
        _decimals = 6;
    }

    function transfer(address _to, uint256 _value) validAddress(_to) smallerOrLessThan(_value, balances[msg.sender]) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) validAddress(_from) validAddress(_to)
    smallerOrLessThan(_value, balances[_from]) smallerOrLessThan(_value, allowances[_from][msg.sender])
    public returns (bool) {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowances[msg.sender][_spender];
        allowances[msg.sender][_spender] = _subtractedValue > oldValue ? 0 : oldValue.sub(_subtractedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 amount) public {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}

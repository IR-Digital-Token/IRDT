pragma solidity ^0.4.0;

import "./Ownable.sol";
import "./Erc20TokenInterface.sol";
import "./MathLibrary.sol";

contract Erc20Token is Erc20TokenInterface, Ownable {
    using MathLibrary for uint256;

    constructor() Ownable() {
        balances[msg.sender] = 1000000;
        totalSupply_ = 1000000;
        emit Transfer(address(0), msg.sender, 1000000);
        name = "Pooleno";
        symbol = "IRDT";
        decimals = 4;
    }

    /**
     * Transfer token from sender(caller) to '_to' account
     *
     * Requirements:
     *
     * - `_to` cannot be the zero address.
     * - the sender(caller) must have a balance of at least `_value`.
     */
    function transfer(address _to, uint256 _value) validAddress(_to) smallerOrLessThan(_value, balances[msg.sender]) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    /**
     * sender(caller) transfer '_value' token to '_to' address from '_from' address
     *
     * Requirements:
     *
     * - `_to` and `_from` cannot be the zero address.
     * - `_from` must have a balance of at least `_value` .
     * - the sender(caller) must have allowance for `_from`'s tokens of at least `_value`.
     */
    function transferFrom(address _from, address _to, uint256 _value) validAddress(_from) validAddress(_to)
    smallerOrLessThan(_value, balances[_from]) smallerOrLessThan(_value, allowances[_from][msg.sender])
    public returns (bool) {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * change allowance of `_spender` to `_value` by sender(caller)
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address _spender, uint256 _value) validAddress(_spender) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * Atomically increases the allowance granted to `spender` by the sender(caller).
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function increaseApproval(address _spender, uint _addedValue) validAddress(_spender) public returns (bool) {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    /**
    * Atomically decreases the allowance granted to `spender` by the sender(caller).
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `_spender` cannot be the zero address.
    * - `_spender` must have allowance for the caller of at least `_subtractedValue`.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowances[msg.sender][_spender];
        allowances[msg.sender][_spender] = _subtractedValue > oldValue ? 0 : oldValue.sub(_subtractedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }


    /**
    * Destroys `amount` tokens from `account`, reducing the
    * total supply.
    * Emits a {Transfer} event with `to` set to the zero address.
    *
    * Requirements:
    * - `amount` cannot be the zero.
    * - `amount` cannot be more than sender(caller)'s balance.
    */
    function burn(uint256 amount) public {
        require(amount != 0);
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}

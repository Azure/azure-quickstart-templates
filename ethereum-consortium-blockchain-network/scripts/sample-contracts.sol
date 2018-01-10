pragma solidity ^0.4.0;
contract StateHolder {
    address public owner;

    uint public openNumber;
    string public openString;
    string public myString;

   modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function StateHolder() {
        owner = msg.sender;
    }

    function changeOpenNumber(uint _newNumber) {
        openNumber = _newNumber;
    }

    function changeOpenString(string _newString) {
        openString = _newString;
    }

    function changeMyString(string _newString) onlyOwner {
        myString = _newString;
    }
}

contract Token {
    mapping (address => uint) public balances;

    function Token() {
        balances[msg.sender] = 1000000;
    }

    function transfer(address _to, uint _amount) {
        require (balances[msg.sender] >= _amount);

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}

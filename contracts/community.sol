pragma solidity ^0.4.0;
import "config.sol";

contract community {
    config private conf;
    mapping (address => wallet) public value;
    mapping (bytes32 => address) public walletsNS;
    event report(string _arg);
    
    struct wallet {
        address owner;
        uint value;
        uint lastRefillBlockNumber;
        uint originBlockNumber;
    }
    
    function community () {
        conf = new config();
    }
    
    function getConfig() constant returns (config) {
        return conf;
    }
    
    function createWallet (bytes32 _name) {
        wallet memory newWallet;
        newWallet.owner = msg.sender;
        newWallet.value = 0;
        newWallet.lastRefillBlockNumber = 0;
        newWallet.originBlockNumber = 0;
        value[msg.sender] = newWallet;
        walletsNS[_name] = msg.sender;
        walletsNS[_name] = msg.sender;
        report('createWallet ok');
    }
    
    function walletByName (bytes32 _name) constant internal returns (wallet) {
        return value[walletsNS[_name]];
    }
    
    function walletByAddress (address _address) constant internal returns (wallet) {
        return value[_address];
    }
    
    function requestRefill () {
        if (block.number - value[msg.sender].lastRefillBlockNumber > conf.getTimeToZero()) {
            value[msg.sender].value = conf.getRefillBalance();
            value[msg.sender].originBlockNumber = block.number;
            return report("requestRefill ok");
        }
    }
    
    function currentValueOf(address _owner) constant returns (uint) {
        wallet memory w = walletByAddress(_owner);
        return conf.currentValue(w.value, w.originBlockNumber, block.number);
    }
    
    function originBlockNumebrOf(address _owner) constant returns (uint) {
        wallet memory w = walletByAddress(_owner);
        return w.originBlockNumber;
    }
    
    function send (bytes32 _from, bytes32 _to, uint _value) {
        if (_value <= 0) {
            return report("no value or negative");
        }
        wallet memory to = walletByName(_to);
        if (to.owner == address(0)) {
            return report("sender not found");
        }
        wallet memory from = walletByName(_from);
        if (from.owner == address(0)) {
            return report("receiver not found");
        }
        uint fromValue = conf.currentValue(from.value, from.originBlockNumber, block.number);
        uint toValue = conf.currentValue(to.value, to.originBlockNumber, block.number);
        if (_value > fromValue) {
            return report("not enough balance");
        }
        // update sender
        value[from.owner].value = fromValue - _value;
        // update receiver
        value[to.owner].value = toValue + _value;
        uint origin = to.originBlockNumber;
        if (block.number - origin >= conf.getTimeToZero()) {
            value[to.owner].originBlockNumber = block.number;
        } else {
            uint blockNumberIncr = conf.blockNumberOriginIncr(_value);
            value[to.owner].originBlockNumber = origin + blockNumberIncr;    
        }
        return report("send ok");
    }
}
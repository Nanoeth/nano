pragma solidity ^0.4.0;
import "wallet.sol";
import "config.sol";

contract community {
    config private conf;
    mapping (address => wallet) public wallets;
    mapping (bytes32 => address) public walletsNS;
    bytes32[] public walletNames;
    event report(string _arg);
    
    function community () {
        conf = new config();
    }
    
    function getConfig() constant returns (config) {
        return conf;
    }
    
    function createWallet (bytes32 _name) {
        report('wallet creation ...');
        wallets[msg.sender] = new wallet(msg.sender, this);
        report('wallet created');
        walletsNS[_name] = msg.sender;
        walletNames.length = walletNames.length + 1;
        walletNames[walletNames.length - 1] = _name;
        report('end createWallet');
    }
    
    function walletByName (bytes32 _name) constant returns (wallet) {
        return wallets[walletsNS[_name]];
    }
    
    function walletByAddress (address _address) constant returns (wallet) {
        return wallets[_address];
    }
    
    function requestRefill () {
        wallet w = walletByAddress(msg.sender);
        if (int(block.number) - w.getLastRefillBlockNumber() > conf.getTimeToZero()) {
           w.setValue(conf.getRefillBalance());
           w.setOriginBlock(int(block.number));
        }
    }
    
    function send (bytes32 _from, bytes32 _to, int _value) {
        if (_value <= 0) {
            return report("no value or negative");
        }
        wallet to = walletByName(_to);
        if (address(to) == address(0)) {
            return report("sender not found");
        }
        wallet from = walletByName(_from);
        if (address(from) == address(0)) {
            return report("receiver not found");
        }
        int fromValue = from.getValue();
        int toValue = to.getValue();
        if (_value > fromValue) {
            return report("not enough balance");
        }
        // update sender
        from.setValue(fromValue - _value);
        // update receiver
        to.setValue(toValue + _value);
        int origin = to.getOriginBlockNumber();
        if (int(block.number) - origin >= conf.getTimeToZero()) {
            to.setOriginBlock(int(block.number)); 
        } else {
            int blockNumberIncr = conf.blockNumberOriginIncr(_value);
            to.setOriginBlock(origin + blockNumberIncr);    
        }
        return report("send ok");
    }
}
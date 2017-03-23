pragma solidity ^0.4.0;
import "community.sol";

contract wallet {
    community private com;
    address private owner;
    int private lastRefillBlockNumber = 0;
    int private originblockNumber;
    int private value;
    
    function wallet (address _owner, community _community) {
        owner = _owner;
        com = _community;
    }
    
    function getValue () constant returns (int) {
        return com.getConfig().currentValue(value, originblockNumber, int(block.number));
    }
    
    function getOriginBlockNumber () constant returns (int) {
        return originblockNumber;
    }
    
    function getLastRefillBlockNumber () constant returns (int) {
        return lastRefillBlockNumber;
    }
    
    function setValue (int _value) {
        if (msg.sender != address(com)) throw;
        value = _value;
    }
    
    function setOriginBlock (int _blockNumber) {
        if (msg.sender != address(com)) throw;
        originblockNumber = _blockNumber;
    }
}
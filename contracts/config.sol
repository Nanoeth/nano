
pragma solidity ^0.4.0;
contract config {
    uint private timeToZero = 300; // 1 day <=> 5760 blocks
    uint private burningTime = 300;
    uint private refillBalance = 500;
    
    function currentValue (uint value, uint originBlockNumber, uint blockNumber) returns (uint) {
        if (blockNumber - originBlockNumber > timeToZero) {
            return 0;
        } else if (blockNumber - originBlockNumber <= timeToZero - burningTime) {
            return value;
        } else {
            uint coeff = (blockNumber - originBlockNumber - timeToZero + burningTime) * 1000;
            coeff = coeff / burningTime;
            coeff = 1000 - coeff;
            return (coeff * value) / 1000;
        }
    }
    
    function blockNumberOriginIncr (uint _value) returns (uint) {
        if (_value >= refillBalance) {
            return timeToZero; //the transfered value is more than the refill balance, we give time to zero.
        } else {
            return _value * (timeToZero / refillBalance);
        }
    }
    
    function getTimeToZero() returns (uint) {
        return timeToZero;
    }
    
    function setTimeToZero(uint _time) {
        timeToZero = _time;
    }
    
     function getRefillBalance() returns (uint) {
        return refillBalance;
    }
    
    function setRefillBalance(uint _balance) {
        refillBalance = _balance;
    }
}
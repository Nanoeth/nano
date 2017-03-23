
pragma solidity ^0.4.0;
contract config {
    int private timeToZero = 300; // 1 day <=> 5760 blocks
    int private burningTime = 300;
    int private refillBalance = 500;
    
    function currentValue (int value, int originBlockNumber, int blockNumber) returns (int) {
        if (blockNumber - originBlockNumber > timeToZero) {
            return 0;
        } else if (blockNumber - originBlockNumber <= timeToZero - burningTime) {
            return value;
        } else {
            int coeff = (blockNumber - originBlockNumber - timeToZero + burningTime) * 1000;
            coeff = coeff / burningTime;
            coeff = 1000 - coeff;
            return (coeff * value) / 1000;
        }
    }
    
    function blockNumberOriginIncr (int _value) returns (int) {
        if (_value >= refillBalance) {
            return timeToZero; //the transfered value is more than the refill balance, we give time to zero.
        } else {
            return _value * (timeToZero / refillBalance);
        }
    }
    
    function getTimeToZero() returns (int) {
        return timeToZero;
    }
    
    function setTimeToZero(int _time) {
        timeToZero = _time;
    }
    
     function getRefillBalance() returns (int) {
        return refillBalance;
    }
    
    function setRefillBalance(int _balance) {
        refillBalance = _balance;
    }
}
pragma solidity 0.8.1;

import "./Allowance.sol";

contract SharedWalled is Allowance{
    
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "contract doesn't own enough money");
        if(!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }
    
    function renounceOwnership() public onlyOwner {
        revert("can't renounce ownership here");
    }
    
    
    
    fallback () external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
    
    receive() external payable {

    }
}
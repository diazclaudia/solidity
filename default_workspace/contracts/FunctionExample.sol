pragma solidity ^0.6.0;
contract FunctionsExample {

 mapping(address => uint) public balanceReceived;
 address payable owner;

 constructor() public {
    owner = msg.sender;
 }

 function destroySmartContract() public {
     require(msg.sender == owner, "You are not the owner");
     selfdestruct(owner);
 }

 function receiveMoney() public payable {
     assert(balanceReceived[msg.sender] + msg.value >= balanceReceived[msg.sender]);
     balanceReceived[msg.sender] += msg.value;
 }

 function withdrawMoney(address payable _to, uint _amount) public {
     require(_amount <= balanceReceived[msg.sender], "not enough funds.");
     assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount);
     balanceReceived[msg.sender] -= _amount;
     _to.transfer(_amount);
 }
     receive () external payable {
     receiveMoney();
 }
}
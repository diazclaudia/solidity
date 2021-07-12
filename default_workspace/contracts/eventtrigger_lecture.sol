pragma solidity ^0.6.0;

contract Ownable{
    address payable _owner;
    
    constructor() public{       
        _owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(isOwner() , "you are not the owner");
        _;
    }
    
    function isOwner() public view returns(bool){
        return (msg.sender == _owner);
    }
}

contract Item{
    
     uint public priceInWei;
     uint public paidWei;
     uint public index;
    
     ItemManager parentContract;
    
     constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
         priceInWei = _priceInWei;
         index = _index;
         parentContract = _parentContract;
     }
    
     receive() external payable {
         require(msg.value == priceInWei, "We don't support partial payments");
         require(paidWei == 0, "Item is already paid!");
         paidWei += msg.value;
         (bool success, ) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
         require(success, "Delivery did not work");
     }
    
     fallback () external {
    
     }

}

contract ItemManager  is Ownable{

     struct S_Item {
         Item _item;
         ItemManager.SupplyChainSteps _step;
         string _identifier;
         uint _priceInWei;
     }
     
     mapping(uint => S_Item) public items;
     uint index;
    
     enum SupplyChainSteps {Created, Paid, Delivered}
    
     event SupplyChainStep(uint _itemIndex, uint _step, address _address);

     function createItem(string memory _identifier, uint _priceInWei) public onlyOwner{
         Item item = new Item(this, _priceInWei, index);
         items[index]._item = item;
         items[index]._step = SupplyChainSteps.Created;
         items[index]._identifier = _identifier;
         items[index]._priceInWei = _priceInWei;
         emit SupplyChainStep(index, uint(items[index]._step), address(item));
         index++;
     }

     function triggerPayment(uint _index) public payable {
         Item item = items[_index]._item;
         require(address(item) == msg.sender, "Only items are allowed to update themselves" );
         require(item.priceInWei() == msg.value, "Not fully paid yet");
         require(items[index]._step == SupplyChainSteps.Created, "Item is further in the supply chain");
         items[_index]._step = SupplyChainSteps.Paid;
         emit SupplyChainStep(_index, uint(items[_index]._step), address(item));
    }

    function triggerDelivery(uint _index) public onlyOwner{
         require(items[_index]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
         items[_index]._step = SupplyChainSteps.Delivered;
         emit SupplyChainStep(_index, uint(items[_index]._step), address(items[_index]._item));
     }
}
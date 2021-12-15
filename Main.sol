pragma solidity ^0.4.0;

contract microloan {
  uint TimeStart; //time stamp of the block
  //constructor
  function microloan() public payable {
      TimeStart=now;

  }

  //links individual ID to address
  mapping(uint=>address)user_ID;

  //structure of member
  //TODO: add deposit monet attr
  //TODO: add state of the member: Borrower or Lender
  struct member {

    uint addtime;
    uint counter;

    address member_address;
    uint ID;
    //TODO: Replace the addresees with an array of them
    address sponsor_1;
    address sponsor_2;
    address sponsor_3;
    address sponsor_4;

  }
 uint CurrentTime;
  //maps address to the member structure
  mapping (address => member) link;

  uint count=1;
  //TODO: Replace the addresees with an array of them
  address var1;
  address var2;
  address var3;
  address var4;
//TODO: Change the event names
  // when member is added
  event SomeoneTriedToAddSomeone(address personWhoTried,address personWhoWasAdded);
  // when money is deposited
  event SomeoneAddedMoneyToThePool(address personWhoSent,uint moneySent);
  // when requested for loan
  event SomeoneRequestedMoney(address personWhoRequested,uint requestedM);

  //resets counter for new member
  function onlynew(address newadd){

      if(link[newadd].sponsor_1==0x0)
        count=1;

  }

  function () payable{
  }

}

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
 uint init_member_counter = 1;
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
  //Function that only allows to initiate the 4 initial members 
  //TODO: Should add an Ownable modifier from Zeppelin
  function init_members(uint _ID) {
    user_ID[_ID]=msg.sender;
    if(init_member_counter <5){
      link[msg.sender]=member(now,4,msg.sender,_ID,0x1,0x2,0x3,0x4);
      init_member_counter++;
    }
    else{
      throw;
    }

  }

   //validates new member by sponsors
  function add_Member(address _req_member,uint __ID) {

    onlynew(_req_member);

    if(count==1)
    {user_ID[__ID]=_req_member;
      var1=msg.sender;
      link[_req_member]=member(now,count,_req_member,__ID,var1,0,0,0);
    }
    else if (count==2)
    {
      link[_req_member].sponsor_2=msg.sender;
    }
    else if (count==3)
    {
      link[_req_member].sponsor_3=msg.sender;
    }

    else if (count==4)
    {
      link[_req_member].sponsor_4=msg.sender;
    }

    count++;

    SomeoneTriedToAddSomeone(msg.sender,_req_member);

  }

  function () payable{
  }

}

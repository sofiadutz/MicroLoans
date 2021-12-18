pragma solidity ^0.4.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract microloan is Ownable {

  using SafeMath for uint;

  uint TimeStart; //time stamp of the block
  //constructor
  function microloan() public payable {
      TimeStart=now;

  }

  //links individual ID to address
  mapping(uint=>address)user_ID;

  //structure of member
  
  //TODO: add state of the member: Borrower or Lender
  // the state is defined by the add_member function: if the requirement of the 4 sponsors is satisfied, the member is borrower, else is lender
  
  struct member {

    uint addtime;
    uint counter;

    address member_address;
    uint ID;
    
    uint deposit;
    
    bool borrower;
    
    //TODO: Replace the addresees with an array of them
    // allow for the possibility of having more than 4 sponsors
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


  // when member is added
  event NewMemberSponsored(address Sponsor,address new_member);
  // when money is deposited
  event Deposit(address sender,uint amount);
  // when loan is requested
  event LoanRequest(address borrower,uint amount);

  //resets counter for new member
  function onlynew(address newadd){

      if(link[newadd].sponsor_1==0x0)
        count=1;

  }
  //Function that only allows to initiate the 4 initial members 
  //TODO: Should add an Ownable modifier from Zeppelin so that only we can call this function
  function init_members(uint _ID) onlyOwner {
    user_ID[_ID]=msg.sender;
    if(init_member_counter <5){
      link[msg.sender]=member(now,4,msg.sender,_ID,0x1,0x2,0x3,0x4);
      init_member_counter++;
    }
    else{
      throw;
    }

  }
  //check eligibility of member for payments
  modifier check_num_sponsors(address _check_address) {

    if(link[_check_address].counter < 4){
      throw;
    }
    else{
      _;
    }

  }
   //validates new member by sponsors
   //TODO: modify so that a new memeber who wants to be lender can enter without the 4 sponsors
  function add_Member(address _req_member,uint __ID) check_num_sponsors(msg.sender) {

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

    emit NewMemberSponsored(msg.sender,_req_member);

  }
  
  //deposit money in the pool
  function deposit(uint __amount) payable {

    this.transfer(__amount);
    emit Deposit(msg.sender,__amount);

  }
    //shows the money in the pool
  function getPoolMoney() constant returns (uint){

    return this.balance;

  }

    //show ID refrences of a member
  function list_refrences(address _master_address) constant returns (uint,uint,uint,uint) {

    return (link[link[_master_address].sponsor_1].ID,link[link[_master_address].sponsor_2].ID,link[link[_master_address].sponsor_3].ID,link[link[_master_address].sponsor_4].ID);

  }
  uint[] public amounts;
//requested money mapped to member address
  mapping (uint => address) amount_map;

//TODO: Add modifier to prevent pooling too many times or too early
  modifier onlymember()
  {
      //TODO: check the flag instead of the sponsors number
      uint memcount=link[msg.sender].counter;
      if(memcount >= 4)
      {
        _;
      }
      else
      {
          throw;
      }
  }
//To request money from the pool
  function whitdraw(uint _amount_) {
    amounts.push(_amount_);
    amount_map[_amount_] = msg.sender;

   emit LoanRequest(msg.sender,_amount_);
  }
  

  uint temp;
// TODO: Not sure if we need this buble_sort
  function bubble_sort(){

    for(uint j=0;j<amounts.length-1;j++){

      for(uint k=0;k<amounts.length-j-1;k++){

        if(amounts[k]>amounts[k+1]){

          temp = amounts[k];
          amounts[k] = amounts[k+1];
          amounts[k+1] = temp;

        }
      }
    }
  }

  uint sum;

  uint t;

  uint counter_sum=0;
//Total distributable money from the pool
  function assign_loan() constant returns (uint){

    sum = 0;

   for(t=0;t<amounts.length;t++){

    if(sum<=amounts[t]){

        sum=sum+amounts[t];
         counter_sum = t;

    }
   }

   return sum;

  }

  function check_time(address ad1) constant returns(uint)
  {
      return(link[ad1].addtime);
  }
//Address of members who will receive loan
  function BorrowersList() public constant returns(address[]){

    uint length = amounts.length;
    address[] memory addr = new address[](length);

    for(uint q=0; q <= counter_sum; q++ ){

      addr[q] = amount_map[amounts[q]];

    }

    return addr ;
  }

  address temp_address;
//Check if the month is end of three months cycle
  modifier every_3_months {

    uint months=(now-TimeStart)/(24*60*60*30);
    if(months%3==0)
    {
        _;
    }
    else
    {
        throw;
    }

  }
//Pay the members the requested loan amount
  function pay_loan() public every_3_months {

    for(uint w=0; w <= counter_sum; w++ ){

      temp_address = amount_map[amounts[w]];
      temp_address.transfer(amounts[w]);

    }
  }
  
//for lenders to withdraw their interest
// TODO: modify so that the person who calls this function is a lender and can access to the interest associated with its initial deposit invested

  function withdraw_interest(lender) public every_3_months {
  
  uint public Periods = 3;
  uint public Interest;
  uint public InterestRateInteger = 2
  uint Principle = link[member].deposit
  
  Interest = (Principle * (1 + InterestRateInteger/100)**Periods) - Principle;
  msg.sender.transfer(Interest);
  
  
  }



 function getCurrentTime() public constant returns(uint)
  {

      CurrentTime=now;
      return CurrentTime;
  }

  function () payable{
  }

}

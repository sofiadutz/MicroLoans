pragma solidity ^0.4;

contract microloan {


  uint TimeStart; //time stamp of the block
  //constructor
  function time() public payable {
      TimeStart=now;

  }

  //links individual ID to address
  mapping(string => address)user_ID;

  //structure of member
  struct member {

    uint addtime;
    uint counter;

    address member_address;
    string ID;
    
    uint deposit;
    
    bool borrower;
    

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
  function init_members(string _ID) {
    user_ID[_ID]=msg.sender;
    if(init_member_counter <5){
      link[msg.sender]=member(now,4,msg.sender,_ID,0,false,0x1,0x2,0x3,0x4);
      init_member_counter++;
    }
    else{
      revert();
    }

  }
  //check eligibility of member for payments
  modifier check_num_sponsors(address _check_address) {

    if(link[_check_address].counter < 4){
      revert();
    }
    else{
      _;
    }

  }
  
  //validates new member by sponsors
  function add_Member(address _req_member,string __ID) check_num_sponsors(msg.sender) {

    onlynew(_req_member);

    if(count==1)
    {user_ID[__ID]=_req_member;
      var1=msg.sender;
      link[_req_member]=member(now,count,_req_member,__ID,0,true,var1,0,0,0);
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
      link[_req_member].counter=4;
    }

    count++;


  }
  function show_count(address _master_address) constant returns (uint) {

    return (link[msg.sender].counter);
  }
  
  // add members without recommenders
  function add_Lender(address _req_member, string __ID) {
  onlynew(_req_member);
  user_ID[__ID]=_req_member;
  link[_req_member]=member(now,count,_req_member,__ID,0,false,0,0,0,0);
  }
  


  //deposit money in the pool
  function deposit() payable {
    uint __amount = msg.value;
    this.transfer(__amount);
    link[msg.sender].deposit += __amount;
    if(amount_borrowed[msg.sender]>0) {
      amount_borrowed[msg.sender]= amount_borrowed[msg.sender] - __amount;
      if(amount_borrowed[msg.sender]<0) {
        amount_borrowed[msg.sender]=0;
      }

    }

  }
  //shows individual deposit
  function show_deposit(address _master_address) constant returns (uint) {

    return (link[msg.sender].deposit);
    
    }
    
    //shows the money in the pool
  function getPoolMoney() constant returns (uint){

    return this.balance;

  }

    //show ID refrences of a member
  function list_refrences(address _master_address) constant returns (string,string,string,string) {

    return (link[link[_master_address].sponsor_1].ID,link[link[_master_address].sponsor_2].ID,link[link[_master_address].sponsor_3].ID,link[link[_master_address].sponsor_4].ID);

  }
  uint[] amounts;
//requested money mapped to member address
  mapping (uint => address) amount_map;
// amount effectively borrowed
  mapping (address => uint) amount_borrowed;

  modifier onlymember()
  {
      uint memcount=link[msg.sender].counter;
      if(memcount >= 4)
      {
        _;
      }
      else
      {
          revert();
      }
  }
  
//To request money from the pool
  function request(uint _amount_) {
    amounts.push(_amount_);
    amount_map[_amount_] = msg.sender;

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
  function assign_loan(){

    sum = 0;

   for(t=0;t<amounts.length;t++){

    if(sum+amounts[t]<=this.balance){

        sum=sum+amounts[t];
         counter_sum = t;

    }
   }

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
        revert();
    }

  }

//Pay the members the requested loan amount

  function pay_loan() every_3_months {

    for(uint w=0; w <= counter_sum; w++ ){
      temp_address = amount_map[amounts[w]];
      uint total_recmd = (link[link[temp_address].sponsor_1].deposit + 
      link[link[temp_address].sponsor_2].deposit + 
      link[link[temp_address].sponsor_3].deposit + 
      link[link[temp_address].sponsor_4].deposit);

      if (total_recmd >= amounts[w]) {

      
      temp_address.transfer(amounts[w]);
      amount_borrowed[msg.sender] = amounts[w];
      delete amounts[w];
      delete amount_map[amounts[w]];}
      else {
        revert();
      }
      counter_sum=0;

    
    }
  }

// shows deposits of recommenders
  function show_recDepo(uint w) constant returns(uint,uint,uint,uint) {
    temp_address = amount_map[amounts[w]];
    return (link[link[temp_address].sponsor_1].deposit,link[link[temp_address].sponsor_2].deposit,link[link[temp_address].sponsor_3].deposit,link[link[temp_address].sponsor_4].deposit);
  } 
  
//to withdraw deposit
  function withdraw_deposit(address _member) public {
    require(_member == msg.sender);
    uint amount = link[_member].deposit;
    msg.sender.transfer(amount);
    link[msg.sender].deposit = link[msg.sender].deposit - amount;

}
  function show_Depo(address _master_address) constant returns (uint) {

    return (link[_master_address].deposit);
  } 

//for lenders to withdraw their interest
  function withdraw_interest(address lender) public every_3_months {
  
  uint Periods = 3;
  uint Interest;
  uint InterestRateInteger = 2;
  uint Principle = link[lender].deposit;
  
  Interest = (Principle * (1 + InterestRateInteger/100)**Periods) - Principle;
  msg.sender.transfer(Interest);
  
  
  }


 function show_counter_sum() constant returns(uint) {

    return (counter_sum);
  }
 function getCurrentTime() public constant returns(uint)
  {

       CurrentTime=now;
      return CurrentTime;
  }

  function () payable{
  }

}
pragma solidity >=0.5.0 <0.6.0;
import "./ownable.sol";
contract microloan is Ownable {


  uint TimeStart; //time stamp of the block
  //constructor
  function time() public payable{
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
    uint sponsored_deposit;
    bool borrower;
    

    address sponsor_1;
    address sponsor_2;
    address sponsor_3;
    address sponsor_4;
    
    address sponsorship;

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
  function onlynew(address newadd) private{

      if(link[newadd].sponsor_1==address(0))
        count=1;

  }
  //Function that only allows to initiate the 4 initial members 
  function init_members(string memory _ID) public{
    user_ID[_ID]=msg.sender;
    if(init_member_counter <5){
      link[msg.sender]=member(now,4,msg.sender,_ID,0,0,false,address(0),address(0),address(0),address(0),address(0));
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
  function add_Member(address _req_member,string memory __ID) public check_num_sponsors(msg.sender) {

    onlynew(_req_member);

    if(count==1)
    {user_ID[__ID]=_req_member;
      var1=msg.sender;
      link[_req_member]=member(now,count,_req_member,__ID,0,0,true,var1,address(0),address(0),address(0),address(0));
      link[var1].sponsorship = _req_member;
    }
    else if (count==2)
    {
      link[_req_member].sponsor_2=msg.sender;
      link[var2].sponsorship = _req_member;
    }
    else if (count==3)
    {
      link[_req_member].sponsor_3=msg.sender;
      link[var3].sponsorship = _req_member;
    }

    else if (count==4)
    {
      link[_req_member].sponsor_4=msg.sender;
      link[_req_member].counter=4;
      link[var4].sponsorship = _req_member;
    }

    count++;


  }
  
  // add members without recommenders
  function add_Lender(address _req_member, string memory __ID) public {
  onlynew(_req_member);
  user_ID[__ID]=_req_member;
  link[_req_member]=member(now,count,_req_member,__ID,0,0,false,address(0),address(0),address(0),address(0),address(0));
  }
  


  //deposit money in the pool
  function deposit() public payable {
    uint __amount = msg.value;
    address(this).transfer(__amount);
    
    if(amount_borrowed[msg.sender]>0) {
      link[link[msg.sender].sponsor_1].deposit += __amount/4;
      link[link[msg.sender].sponsor_1].sponsored_deposit -= __amount/4;
      link[link[msg.sender].sponsor_2].deposit += __amount/4;
      link[link[msg.sender].sponsor_2].sponsored_deposit -= __amount/4;
      link[link[msg.sender].sponsor_3].deposit += __amount/4;
      link[link[msg.sender].sponsor_3].sponsored_deposit -= __amount/4;
      link[link[msg.sender].sponsor_4].deposit += __amount/4;
      link[link[msg.sender].sponsor_4].sponsored_deposit -= __amount/4;
      amount_borrowed[msg.sender]= amount_borrowed[msg.sender] - __amount;
      if(amount_borrowed[msg.sender]<0) {
        amount_borrowed[msg.sender]=0;
      }
    }
    else {
      link[msg.sender].deposit += __amount;

    }

  }
  //shows individual deposit
  function show_deposit() public view returns (uint) {

    return (link[msg.sender].deposit);
    
    }
  function show_sponsored_deposit() public view returns (uint) {

    return (link[msg.sender].sponsored_deposit);
    
    }
  function show_borrowewd() public view returns (uint) {

    return (amount_borrowed[msg.sender]);
    
    }  
  function show_sponsorship() public view returns (address) {

    return (link[msg.sender].sponsorship);
    
    } 
    //shows the money in the pool
  function getPoolMoney() public view returns (uint){

    return address(this).balance;

  }

    //show ID refrences of a member
  function list_references(address _master_address) public view returns (string memory,string memory,string memory,string memory) {

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
  function request(uint _amount_) public{
    if(amount_borrowed[msg.sender]>0){
      revert('You are already in debt');
    }
    if (link[msg.sender].deposit <= 50000) {
      revert('You dont have enough deposit. reach to 50000');
    }
    amounts.push(_amount_);
    amount_map[_amount_] = msg.sender;

  }
  

  uint temp;

  function bubble_sort() external onlyOwner{

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
  function assign_loan() external onlyOwner{

    sum = 0;

   for(t=0;t<amounts.length;t++){

    if(sum+amounts[t]<=address(this).balance){

        sum=sum+amounts[t];
         counter_sum = t;

    }
   }

  }

  function check_time(address ad1) public view returns(uint)
  {
      return(link[ad1].addtime);
  }
  
  
//Address of members who will receive loan
  function BorrowersList() public view returns(address[] memory){

    uint length = amounts.length;
    address[] memory addr = new address[](length);

    for(uint q=0; q <= counter_sum; q++ ){

      addr[q] = amount_map[amounts[q]];

    }

    return addr ;
  }


  
  
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
// TODO: add every_3_months
  function pay_loan() external payable onlyOwner {

    for(uint w=0; w <= counter_sum; w++ ){
      address payable temp_address = address(uint160(amount_map[amounts[w]]));
      uint recmd_share = amounts[w]/4;
      if (recmd_share > link[link[temp_address].sponsor_1].deposit){
        revert('sponsor 1 problem');
      }
      if (recmd_share > link[link[temp_address].sponsor_2].deposit){
        revert('sponsor 2 problem');
      }
      if (recmd_share > link[link[temp_address].sponsor_3].deposit){
        revert('sponsor 3 problem');
      }
      if (recmd_share > link[link[temp_address].sponsor_4].deposit){
        revert('sponsor 4 problem');
      }
      uint interest_rate_integer = 4;
      temp_address.transfer(amounts[w]*interest_rate_integer/100);
      amount_borrowed[temp_address] = amounts[w];
      link[link[temp_address].sponsor_1].deposit -= recmd_share;
      link[link[temp_address].sponsor_1].sponsored_deposit += recmd_share;
      link[link[temp_address].sponsor_2].deposit -= recmd_share;
      link[link[temp_address].sponsor_2].sponsored_deposit += recmd_share;
      link[link[temp_address].sponsor_3].deposit -= recmd_share;
      link[link[temp_address].sponsor_3].sponsored_deposit += recmd_share;
      link[link[temp_address].sponsor_4].deposit -= recmd_share;
      link[link[temp_address].sponsor_4].sponsored_deposit += recmd_share;
      delete amounts[w];
      delete amount_map[amounts[w]];}

      counter_sum=0;

    
    
  }

// shows deposits of recommenders
  // function show_recDepo(uint w) public view returns(uint,uint,uint,uint) {
  //   address payable temp_address = address(uint160(amount_map[amounts[w]]));
  //   return (link[link[temp_address].sponsor_1].deposit,link[link[temp_address].sponsor_2].deposit,link[link[temp_address].sponsor_3].deposit,link[link[temp_address].sponsor_4].deposit);
  // } 
  
//to withdraw deposit
  function withdraw_deposit(address _member) public {
    require(_member == msg.sender);
    uint amount = link[_member].deposit;
    if (address(this).balance < amount){
      revert('currently there is not enough money in the pool, try later');
    }
    msg.sender.transfer(amount);
    link[msg.sender].deposit = link[msg.sender].deposit - amount;

}


//for lenders to withdraw their interest
  function withdraw_interest(address lender) public every_3_months {
  
  uint Periods = 3;
  uint Interest;
  uint InterestRateInteger = 2;
  uint Principle = link[lender].deposit;
  require(msg.sender == lender);
  Interest = (Principle * (1 + InterestRateInteger/100)**Periods) - Principle;
  msg.sender.transfer(Interest);
  
  
  }



 function getCurrentTime() public view returns(uint)
  {

      return now;
  }

  function () payable external{
  }

}

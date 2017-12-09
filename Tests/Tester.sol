pragma solidity ^0.4.17;

interface swap_interface{
    function forcePay(uint _begin, uint _end) public returns (bool);
}

contract Tester {
    address oracleAddress;
    address baseToken1;
    address baseToken2;
    address factory_address;
    address usercontract_address;
    address swapAddress;
    address drct1;
    address drct2;
    swap_interface swap;
    Factory factory;
    Oracle oracle;
    event Print(string _string, uint _value);

    
    function StartTest() public returns(address){
        oracleAddress = new Oracle();
        baseToken1 = new Wrapped_Ether();
        baseToken2 = new Wrapped_Ether();
        factory_address = new Factory();
        return factory_address;
    }
    
    function setVars(uint _startval, uint _endval) public {
        factory = Factory(factory_address);
        oracle = Oracle(oracleAddress);
        factory.setStartDate(1543881600);
        factory.setVariables(1000000000000000,1000000000000000,7,2);
        factory.setBaseTokens(baseToken1,baseToken2);
        factory.setOracleAddress(oracleAddress);
        oracle.StoreDocument(1543881600, _startval);
        oracle.StoreDocument(1544486400,_endval);
        Print('Start Value : ',_startval);
        Print('End Value " ',_endval);
    }
    
    function setTokens(address _drct1,address _drct2) public{
        drct1 = _drct1; drct2 = _drct2;
        factory.settokens(drct1,drct2);
    }

    function getFactory() public returns (address){
      return factory_address;
    }

   function getUC() public returns (address){
      return usercontract_address;
    }

    function swapAdd(address _swap, bool _isSwap) public returns(address){
      if (_isSwap){
        swapAddress = _swap;
      }
      return swapAddress;
    }


    function setVars2(address _deployer, address _userContract) public{
      factory.setDeployer(_deployer);
      factory.setUserContract(_userContract);
      usercontract_address = _userContract;
    }

    function getWrapped() public returns(address,address){
      return (baseToken1,baseToken2);
    }

    function getDRCT(bool _isLong) public returns(address){
      address drct;
      if(_isLong){
        drct = drct1;
      }
      else{
        drct= drct2;
      }
      return drct;
    }

    function paySwap() public returns(uint,uint){
      for(uint i=0; i < factory.getCount(); i++){
        var x = factory.contracts(i);
          swap = swap_interface(x);
          swap.forcePay(1,100);

      }
      
    Wrapped_Ether wrapped = Wrapped_Ether(baseToken1);
    uint balance_long = wrapped.balanceOf(address(this));
    wrapped = Wrapped_Ether(baseToken2);
    uint balance_short = wrapped.balanceOf(address(this));
    return (balance_long, balance_short);
    }
}


interface Tester_Interface {
  function getFactory() public returns (address);
  function setVars2(address _deployer, address _userContract) public;
  function getUC() public returns (address);
  function swapAdd(address _swap, bool _isSwap) public returns(address);
  function getWrapped() public returns(address,address);
  function getDRCT(bool _isLong) public returns(address);
  function setTokens(address _drct1,address _drct2);
}

contract Tester2 {
  UserContract usercontract;
  address deployer_address;
  address usercontract_address;
  address factory_address;
  Tester_Interface tester;


  function Tester2(address _tester) {
    tester = Tester_Interface(_tester);
    factory_address = tester.getFactory();
    deployer_address = new Deployer(factory_address);
    usercontract_address = new UserContract();
  }

  function setLastVars(){
    tester.setVars2(deployer_address,usercontract_address);
    usercontract = UserContract(usercontract_address);
    usercontract.setFactory(factory_address);
    address drct1 = new DRCT_Token(factory_address);
    address drct2 = new DRCT_Token(factory_address);
    tester.setTokens(drct1,drct2);
  }

}

contract TestParty1 {
  address swap_address;
  address factory_address;
  address usercontract_address;
  address wrapped_long;
  address wrapped_short;
  address user3;
  address drct;
  UserContract usercontract;
  Tester_Interface tester;
  Factory factory;
  Wrapped_Ether wrapped;
  ERC20_Interface dtoken;
  event Print(string _string, uint _value);
  event Print2(string _string, address _value);

  function TestParty1(address _tester) public{
    tester = Tester_Interface(_tester);
    factory_address = tester.getFactory();
    factory = Factory(factory_address);
    swap_address = factory.deployContract();
}

function createSwap() public payable{
    usercontract_address = tester.getUC();
    usercontract = UserContract(usercontract_address);
    usercontract.Initiate.value(msg.value)(swap_address,10000000000000000000,10000000000000000000,0,true );
    tester.swapAdd(swap_address,true);
    user3 = new newTester();
    Print2('New Swap : ',swap_address);
  }

    function transfers() public {
    drct = tester.getDRCT(true);
    dtoken = ERC20_Interface(drct);
    dtoken.transfer(user3,5000);
  }

  function cashOut() public returns(uint, uint,uint,uint){
    (wrapped_long,wrapped_short) = tester.getWrapped();
    wrapped = Wrapped_Ether(wrapped_long);
    uint balance_long = wrapped.balanceOf(address(this));
    uint balance_long3 = wrapped.balanceOf(user3);
    wrapped = Wrapped_Ether(wrapped_short);
    uint balance_short = wrapped.balanceOf(address(this));
    uint balance_short3 = wrapped.balanceOf(user3);
    Print('Long Balance1 : ',balance_long);
    Print('Transferred Long Balance : ', balance_long3);
    Print('Short Balance1 : ', balance_short);
    Print('Transferred Short Balance : ', balance_short3);
    return (balance_long, balance_long3, balance_short, balance_short3);
  }
}

contract TestParty2 {

  address swap_address;
  address usercontract_address;
  address wrapped_long;
  address drct;
  address wrapped_short;
  UserContract usercontract;
  Tester_Interface tester;
  address user4;
  Wrapped_Ether wrapped;
  ERC20_Interface dtoken;
  event Print(string _string, uint _value);

  function EnterSwap(address _tester) public payable{
    tester = Tester_Interface(_tester);
    usercontract_address = tester.getUC();
    usercontract = UserContract(usercontract_address);
    swap_address = tester.swapAdd(msg.sender,false);
    usercontract.Enter.value(msg.value)(10000000000000000000,10000000000000000000,false,swap_address);
    user4 = new newTester();
  }

    function transfers() public {
    drct = tester.getDRCT(false);
    dtoken = ERC20_Interface(drct);
    dtoken.transfer(user4,5000);
  }

  function cashOut() public returns(uint, uint,uint,uint){
    (wrapped_long,wrapped_short) = tester.getWrapped();
    wrapped = Wrapped_Ether(wrapped_long);
    uint balance_long = wrapped.balanceOf(address(this));
    uint balance_long4 = wrapped.balanceOf(user4);
    wrapped = Wrapped_Ether(wrapped_short);
    uint balance_short = wrapped.balanceOf(address(this));
    uint balance_short4 = wrapped.balanceOf(user4);
    Print('Long Balance : ',balance_long);
    Print('Transferred Long Balance : ', balance_long4);
    Print('Short Balance : ', balance_short);
    Print('Transferred Short Balance : ', balance_short4);
    return (balance_long, balance_long4, balance_short, balance_short4);
  }

}

contract newTester{

}

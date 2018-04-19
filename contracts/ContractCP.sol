pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;
import "./ContractPI.sol";


contract ContractCP {
    
    enum Status {NEW, WAITING_FOR_PAID, CHECKING, DONE, CANCELLED}
    
    struct Item {
        string name;
        uint price;
        bool isValid;
    }
    
    address private _clinic;
    address private _patient;
    uint[] private _checkItems;
    uint[] private _checkPrices;
    Status public _status;
    string private _desc;
    uint private _totalFee;
    
    address private _contractPI;
    bool private _patientPaid;
    uint private _patientPaidAmount;
    bool private _insurerPaid;
    uint private _insurerPaidAmount;
    
    mapping(string => Item) _availableItems;
    mapping(string => Item) _selectedItem;
    
    function ContractCP(address inClinic, address inPatient, uint[] inCheckItems) {
        //require(inCheckItems.length > 0);
        _clinic = inClinic;
        _patient = inPatient;
        _status = Status.NEW;
        
        // TODO
        // Init _availableItems as available services at Clinic
        // Stomache, General, Blood, Head, Heart?
        
        // for(uint i = 0; i < inCheckItems.length; i++) {
        //     Item foundItem = _availableItems[inCheckItems[i]];
        //     if(foundItem.isValid == false) {
        //         throw;
        //     }
        //     _selectedItem[inCheckItems[i]] = foundItem;
        //     _totalFee += foundItem.price;
        // }
    }
    
    function clinicAcceptPatient(address inContractPI) {
        require(msg.sender == _clinic);
        require(_status == Status.NEW);
        _contractPI = inContractPI;
        _status = Status.WAITING_FOR_PAID;
    }
    
    function calculateFee() returns (uint, uint) {
        require(msg.sender == _clinic);
        require(_status == Status.WAITING_FOR_PAID);
        ContractPI pi = ContractPI(_contractPI);
        uint[] pays;
        pays[0] = pi.requestForClaim(this);
        pays[1] = _totalFee - pays[0];
        
        emit InformTotalFee(pays[0], pays[1]);
        
        return (pays[0], pays[1]);
    }
    
    function patientPay() payable {
        require(msg.sender == _patient);
        require(_status == Status.WAITING_FOR_PAID);
        require(_patientPaidAmount > 0);
        require(_patientPaid == false);
        require(msg.value >= _patientPaidAmount);
        _patientPaid = true;
        emit PatientPaid(_patientPaidAmount);
        
        checkForPay();
    }
    
    function insurerPay() payable {
        require(_status == Status.WAITING_FOR_PAID);
        require(_insurerPaidAmount > 0);
        require(_insurerPaid == false);
        ContractPI pi = ContractPI(_contractPI);
        require(msg.sender == pi.getInsurer());
        require(msg.value >= _insurerPaidAmount);
        _insurerPaid = true;
        emit InsurerPaid(_patientPaidAmount);
        
        checkForPay();
    }
    
    function checkForPay() {
        require(_status == Status.WAITING_FOR_PAID);
        require(_insurerPaidAmount == 0 || _insurerPaid);
        require(_patientPaidAmount == 0 || _patientPaid);
        _status = Status.CHECKING;
        emit ReadyToCheck();
    }
    
    function patientConfirm() payable {
        require(msg.sender == _patient);
        require(_status == Status.CHECKING);
        _clinic.transfer(this.balance);
        _status = Status.DONE;
    }
    
    function patientCancel() {
        require(msg.sender == _patient);
        require(_status == Status.NEW);
        _status = Status.CANCELLED;
        suicide(msg.sender);
    }
    
    function getPatient() view external returns (address) {
        return _patient;
    }
    
    function getCheckItem(uint inIndex) view external returns (uint) {
        return _checkItems[inIndex];
    }
    
    function getCheckPrice(uint inIndex) view external returns (uint) {
        return _checkPrices[inIndex];
    }
    
    function getItemCount() view external returns (uint) {
        return _checkItems.length;
    }
    
    function receive(uint inAmount) payable minimumAmount(inAmount) {
        
    }
    
    modifier minimumAmount(uint inEtherAmount) {
        require (msg.value >= inEtherAmount * 1 ether);
        _;
    }
    
    event InformTotalFee(uint, uint);
    
    event PatientPaid(uint);
    
    event InsurerPaid(uint);
    
    event ReadyToCheck();
    
    // function stringToBytes32(string memory source) returns (bytes32 result) {
    //     bytes memory tempEmptyStringTest = bytes(source);
    //     if (tempEmptyStringTest.length == 0) {
    //         return 0x0;
    //     }
    
    //     assembly {
    //         result := mload(add(source, 32))
    //     }
    // }
    
}
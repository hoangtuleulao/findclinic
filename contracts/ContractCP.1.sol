pragma solidity ^0.4.21;
// Local file
contract ContractCP {
    
    enum ContractStatus {
        NEW,                // When Contract is deployed
        ON_GOING,           // When Patient come to Clinic
        PATIENT_CONFIRMED,  // When Patient confirm that OK.
        CANCELLED           // When Patient cancel the contract
    }
    
    address private _admin;
    address private _clinic;
    address private _patient;
    
    uint private _amount; 			// wei
    
    string private _description;
    uint private _estimatedTime; 	// in miliseconds
    uint private _createdTime; 		// time that contract is created
    
    ContractStatus public _status;
	
	// When deploy Contract, attach value = 10 ETH
	// Parameter
    // "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", "Test", 10000 (10 seconds), 10 (ETH)
    function ContractCP(address inClinic, address inPatient, string inDescription, uint inEstimatedTime, uint inAmount) public
        payable minimumAmount(inAmount) {
		
		// TODO
		// Require NOT NULL / EMPTY
            
        _admin = msg.sender;
        _clinic = inClinic;
        _patient = inPatient;
        
        _amount = msg.value;
            
        _description = inDescription;
        _estimatedTime = inEstimatedTime;
        _createdTime = block.timestamp;
        
        _status = ContractStatus.NEW;
    }
    
    function clinicAcceptPatient() public{
        require (msg.sender == _clinic);
        require (_status == ContractStatus.NEW);
        
        _status = ContractStatus.ON_GOING;
        
    }
    
    function patientConfirm() payable public{
        require (msg.sender == _patient);
        require (_status == ContractStatus.ON_GOING);
        
        // Check for late?
        uint currentTime = block.timestamp;
        uint diffTime = currentTime - _createdTime;
        
        if(diffTime > _estimatedTime) {
            _clinic.transfer(_amount);
            emit sent(this, _clinic, _amount);
        }
        else {
            uint clinicAmount = _amount * 9 / 10; // 10% for late
            _clinic.transfer(clinicAmount);
            emit sent(this, _clinic, clinicAmount);
            
            uint patienrAmount = _amount - clinicAmount;
            _patient.transfer(patienrAmount);
            emit sent(this, _clinic, patienrAmount);
        }
        
        _status = ContractStatus.PATIENT_CONFIRMED;
    }
    
    function patientCancel() payable public{
        require (msg.sender == _patient);
        require (_status == ContractStatus.NEW);
        
        // Refund full amount to patient if he want cancel
        _patient.transfer(_amount);
         
        _status = ContractStatus.CANCELLED; 
        selfdestruct(msg.sender);
    }
    
    
    function currentStatus() public view returns (ContractStatus){
        return _status;
    }
    
    modifier minimumAmount(uint inAmount) {
        // inAmount is ether ==> wei by multiple 1000000000000000000
        require (msg.value >= inAmount * 1000000000000000000);
        _;
    }
    
    event sent(address from, address to, uint amount);
    
}
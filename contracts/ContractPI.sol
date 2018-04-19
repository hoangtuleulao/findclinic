pragma solidity ^0.4.21;
//pragma experimental ABIEncoderV2;
import "./ContractCP.sol";

/**
 * This is contract between Insurer and Patient
 */
contract ContractPI {
    
   /**
     * Status of Contract
     * - NEW: when Patient deploy the contract
     */
    enum Status {NEW, VALID, EXPIRED, CANCELLED}
    
    struct Item {
        string name;
        uint percent;
        bool isValid;
    }
    
    struct Option {
        uint period;
        uint price;
        mapping(uint => Item) items;
        bool isValid;
    }
    
    struct ClaimRequest {
        address requestedContract;
        address patient;
        bool paid;
        uint amount;
        bool isValid;
    }
    
    address private _insurer;
    address private _patient;
    
    Status public _status;
    
    string private _desc;
    uint private _contractValue;
    uint private _startDate;
    uint private _endDate;
    uint private _period;
    
    Option private _selectedOption;
    mapping(uint => Option[]) _availableOptionsList;
    mapping(address => ClaimRequest) _claimQueue;
    
    function ContractPI(address inInusrer, address inPatient) {
        require(msg.sender == inPatient);
        _insurer = inInusrer;
        _patient = inPatient;
        _status = Status.NEW;
        
        
        // TODO
        // Init _availableOptionsList as avaiable service packs at Insurer
        // Pack 1: 6 month, {Head, Stomache, ..} 50 ETH
        // Pack 2: ...
    }
    
    function getOption(uint inPackId, uint inNumberOfMonths) internal returns (Option) {
        Option[] optionsForPack = _availableOptionsList[inPackId];
        for (uint i = 0; i < optionsForPack.length; i++) {
            if(optionsForPack[i].period == inNumberOfMonths) {
                return optionsForPack[i];
            }
        }
    }
    
    function calculateContractValue(uint inPackId, uint inNumberOfMonths) returns (uint) {
        Option memory matchedOption = getOption(inPackId, inNumberOfMonths);
        if(matchedOption.isValid) {
            return matchedOption.price;
        }
        return 0;
    }
    
    function patientConfirm(uint inPackId, uint inNumberOfMonths, uint inStartDate, uint inContractValue) payable minimumAmount(inContractValue) {
        require(msg.sender == _patient);
        uint totalContractValue = calculateContractValue(inPackId, inNumberOfMonths);
        require(totalContractValue > 0);
        require(msg.value >= inContractValue);
        require(inContractValue >= totalContractValue);
        require(inStartDate >= now);
        
        _contractValue = msg.value;
        _period = inNumberOfMonths;
        _startDate = inStartDate;
        _endDate = inStartDate + monthToMiliseconds(inNumberOfMonths);
        _selectedOption = getOption(inPackId, inNumberOfMonths);
        _status = Status.VALID;
        
        emit ContractSigned(msg.sender, inPackId, _contractValue);
        
    }
    
    function patientCancel() {
        require(msg.sender == _patient);
        require(_status == Status.NEW);
        suicide(msg.sender);
    }
    
    function getInsurer() returns(address) {
        return _insurer;
    }
    
    function calculateClaimAmount(address inPatient, uint[] inCheckItems, uint[] inCheckPrices) returns (uint) {
        require(_status == Status.NEW);
        require(_endDate >= now);
        uint sum = 0;
        for(uint i = 0; i < inCheckItems.length; i++) {
            Item matchedItem = _selectedOption.items[inCheckItems[i]];
            if(matchedItem.isValid) {
                sum += matchedItem.percent * inCheckPrices[i] / 100;
            }
        }
        return sum;
    }
    
    function requestForClaim(address inContractCP) returns (uint) {
        require(_status == Status.VALID);
        require(_endDate >= now);
        
        ContractCP cp = ContractCP(inContractCP);
        require(cp.getPatient() == _patient);
        require(_claimQueue[inContractCP].isValid == false);
        
        uint itemCount = cp.getItemCount();
        uint[] storage checkItems;
        uint[] storage checkPrices;
        for(uint i = 0; i < itemCount; i++) {
            checkItems[i] = cp.getCheckItem(i);
            checkPrices[i] = cp.getCheckPrice(i);
        }
        
        uint totalAmount = calculateClaimAmount(cp.getPatient(), checkItems, checkPrices);
        if(totalAmount > 0) {
            _claimQueue[inContractCP] = ClaimRequest(inContractCP, _patient, false, totalAmount, true);
            emit ClaimRequested(inContractCP, _patient, totalAmount);
            return 0;
        }
        return 1;
        
    }
    
    function insurerAcceptClaim(address inContractCP) payable {
        require(msg.sender == _insurer);
        require(_status == Status.VALID);
        ClaimRequest request = _claimQueue[inContractCP];
        require(request.isValid);
        require(request.paid == false);
        require(msg.value >= request.amount);
        ContractCP cp = ContractCP(inContractCP);
        cp.receive.gas(300000).value(request.amount)(request.amount);
        request.paid = true;
        
        emit AcceptClaim(inContractCP, _patient, request.amount);
    }
    
    function requestForWithdraw() payable {
        require(msg.sender == _insurer);
        require(_status == Status.VALID);
        require(_endDate < now);
        _status = Status.EXPIRED;
        msg.sender.transfer(this.balance);
    }
    
    function monthToMiliseconds(uint inMonth) internal returns (uint) {
        uint daysPerMonth = 30;
        uint hoursPerDay = 24;
        uint minsPerHour = 60;
        uint secsPerMin = 60;
        uint milisPerSec = 1000;
        return inMonth * daysPerMonth * hoursPerDay * minsPerHour * secsPerMin * milisPerSec;
    }
    
    
    modifier minimumAmount(uint inEtherAmount) {
        require (msg.value >= inEtherAmount * 1 ether);
        _;
    }
    
    event ContractSigned(address, uint, uint);
    
    event ClaimRequested(address, address, uint);
    
    event AcceptClaim(address, address, uint);
    
   /**
     * Convert bytes32 to string
     * @param x The bytes32 value
     * @return string The resulting string from bytes32
     */
    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    
    
    
    
    
    
    
    
    
}
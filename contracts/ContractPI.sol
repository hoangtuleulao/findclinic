pragma solidity ^0.4.21;
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
        uint id;
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
    
    
    Option optionG6 = Option(6, 20, true);
    Item itemG6_1 = Item(1, "Fever", 100, true);
    Item itemG6_2 = Item(2, "Flu", 100, true);
    Item itemG6_3 = Item(3, "Backache", 80, true);
    Item itemG6_4 = Item(4, "Stomach ache", 80, true);
    Item itemG6_5 = Item(5, "Headache", 80, true);
    Item itemG6_6 = Item(6, "Toothache", 50, true);
    
    Option optionG12 = Option(12, 30, true);
    Item itemG12_1 = Item(1, "Fever", 100, true);
    Item itemG12_2 = Item(2, "Flu", 100, true);
    Item itemG12_3 = Item(3, "Backache", 80, true);
    Item itemG12_4 = Item(4, "Stomach ache", 80, true);
    Item itemG12_5 = Item(5, "Headache", 80, true);
    Item itemG12_6 = Item(6, "Toothache", 50, true);
    
    Option optionP6 = Option(6, 30, true);
    Item itemP6_1 = Item(1, "Fever", 100, true);
    Item itemP6_2 = Item(2, "Flu", 100, true);
    Item itemP6_3 = Item(3, "Backache", 100, true);
    Item itemP6_4 = Item(4, "Stomach ache", 100, true);
    Item itemP6_5 = Item(5, "Headache", 100, true);
    Item itemP6_6 = Item(6, "Toothache", 80, true);
    Item itemP6_7 = Item(7, "Cancer", 80, true);
    Item itemP6_8 = Item(8, "General examination", 50, true);
    
    Option optionP12 = Option(12, 40, true);
    Item itemP12_1 = Item(1, "Fever", 100, true);
    Item itemP12_2 = Item(2, "Flu", 100, true);
    Item itemP12_3 = Item(3, "Backache", 100, true);
    Item itemP12_4 = Item(4, "Stomach ache", 100, true);
    Item itemP12_5 = Item(5, "Headache", 100, true);
    Item itemP12_6 = Item(6, "Toothache", 80, true);
    Item itemP12_7 = Item(7, "Cancer", 80, true);
    Item itemP12_8 = Item(8, "General examination", 50, true);
    
    function ContractPI(address inInusrer, address inPatient) {
        require(msg.sender == inPatient);
        _insurer = inInusrer;
        _patient = inPatient;
        _status = Status.NEW;
        
                // Option 1: General - 6 months
        optionG6.items[1] = itemG6_1;
        optionG6.items[2] = itemG6_2;
        optionG6.items[3] = itemG6_3;
		optionG6.items[4] = itemG6_4;
		optionG6.items[5] = itemG6_5;
		optionG6.items[6] = itemG6_6;
		
		// Option 1: General - 12 months
        optionG12.items[1] = itemG12_1;
        optionG12.items[2] = itemG12_2;
        optionG12.items[3] = itemG12_3;
		optionG12.items[4] = itemG12_4;
		optionG12.items[5] = itemG12_5;
		optionG12.items[6] = itemG12_6;
        
        Option[] generalOptions;
        generalOptions.push(optionG6);
		generalOptions.push(optionG12);
        _availableOptionsList[1] = generalOptions;
        
        // Option 2: Premium - 6 months
        optionP6.items[1] = itemP6_1;
        optionP6.items[2] = itemP6_2;
        optionP6.items[3] = itemP6_3;
		optionP6.items[4] = itemP6_4;
		optionP6.items[5] = itemP6_5;
		optionP6.items[6] = itemP6_6;
		optionP6.items[7] = itemP6_7;
		optionP6.items[8] = itemP6_8;
		
		// Option 2: Premium - 12 months
        optionP12.items[1] = itemP12_1;
        optionP12.items[2] = itemP12_2;
        optionP12.items[3] = itemP12_3;
		optionP12.items[4] = itemP12_4;
		optionP12.items[5] = itemP12_5;
		optionP12.items[6] = itemP12_6;
		optionP12.items[7] = itemP12_7;
		optionP12.items[8] = itemP12_8;
        
        Option[] premiumOptions;
        premiumOptions.push(optionP6);
		premiumOptions.push(optionP12);
        _availableOptionsList[2] = premiumOptions;
        
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
        uint[] checkItems;
        uint[] checkPrices;
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
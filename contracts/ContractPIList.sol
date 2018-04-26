pragma solidity ^0.4.21;
import "./ContractPI.sol";

/**
 * This contract manages all contracts of Patient & Insurer
 */
contract ContractPIList {
    
    mapping(address => address[]) private _patientContractList;
    mapping(address => address[]) private _insurerContractList;
    
    /**
     * Create a ContractPI and save it to the list of contracts of Patient;
     * @param inInsurer address of Insurer account
     * @param inPatient address of Patient account
     */
    function createContract(address inInsurer, address inPatient) public {
        require(msg.sender == inPatient);
        address pi = new ContractPI(inInsurer, inPatient);
        // Add to Patient contracts list
        address[] storage currentContractListOfPatient = _patientContractList[inPatient];
        currentContractListOfPatient.push(pi);
        // Add to Insurer contracts list
        address[] storage currentContractListOfInsurer = _insurerContractList[inInsurer];
        currentContractListOfInsurer.push(pi);
    }
    
    /**
     * Returns list of contracts of a patient
     * @param inPatient address of patient
     * @return address[] list of contract addresses
     */
    function getPatientContracts(address inPatient) public view returns (address[]) {
        return _patientContractList[inPatient];
    }
    
    /**
     * Returns list of contracts of a insurer
     * @param inInsurer address of insurer
     * @return address[] list of contract addresses
     */
    function getInsurerContracts(address inInsurer) public view returns (address[]) {
        return _insurerContractList[inInsurer];
    }
    
}
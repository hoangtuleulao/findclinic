pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;
import "./ContractCP.sol";

/**
 * This contract manages all contracts of Patient & Clinic
 */
contract ContractCPList {
    
    mapping(address => address[]) private _patientContractList;
    mapping(address => address[]) private _clinicContractList;
    
    // Duration of implementation, we need to detect when the method is called
    event CreateContractEvent(string message);

    /**
     * Create a ContractCP and save it to the list of contracts of Patient;
     * @param inClinic address of Clinic account
     * @param inPatient address of Patient account
     * @param inCheckItems list of items that Patient want to check
     */
    function createContract(address inClinic, address inPatient, string[] inCheckItems) {
        emit CreateContractEvent("1");
        require(msg.sender == inPatient);

        emit CreateContractEvent("2");
        address pi = new ContractCP(inClinic, inPatient, inCheckItems);
        // Add to Patient contracts list
        emit CreateContractEvent("3");
        address[] currentContractListOfPatient = _patientContractList[inPatient];
        emit CreateContractEvent("4");
        currentContractListOfPatient.push(pi);
        // Add to Clinic contracts list
        emit CreateContractEvent("5");
        address[] currentContractListOfClinic = _clinicContractList[inClinic];
        emit CreateContractEvent("6");
        currentContractListOfClinic.push(pi);
    }
    
    /**
     * Returns list of contracts of a patient
     * @param inPatient address of patient
     * @return address[] list of contract addresses
     */
    function getPatientContracts(address inPatient) returns (address[]) {
        return _patientContractList[inPatient];
    }
    
    /**
     * Returns list of contracts of a clinic
     * @param inClinic address of clinic
     * @return address[] list of contract addresses
     */
    function getClinicContracts(address inClinic) returns (address[]) {
        return _clinicContractList[inClinic];
    }
    
}
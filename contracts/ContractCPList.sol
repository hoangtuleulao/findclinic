pragma solidity ^0.4.21;
import "./ContractCP.sol";

/**
 * This contract manages all contracts of Patient & Clinic
 */
contract ContractCPList {
    
    mapping(address => address[]) private _patientContractList;
    mapping(address => address[]) private _clinicContractList;
    
    /**
     * Create a ContractCP and save it to the list of contracts of Patient;
     * @param inClinic address of Clinic account
     * @param inPatient address of Patient account
     * @param inCheckItems list of items that Patient want to check
     */
    function createContract(address inClinic, address inPatient, uint[] inCheckItems) public {
        ContractCP pi = new ContractCP(inClinic, inPatient, inCheckItems);

        address address_pi = address(pi);
    
        // Add to Patient contracts list
        address[] storage currentContractListOfPatient = _patientContractList[inPatient];
        currentContractListOfPatient.push(address_pi);

        // Add to Clinic contracts list
        address[] storage currentContractListOfClinic = _clinicContractList[inClinic];
        currentContractListOfClinic.push(address_pi);
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
     * Returns list of contracts of a clinic
     * @param inClinic address of clinic
     * @return address[] list of contract addresses
     */
    function getClinicContracts(address inClinic) public view returns (address[]) {
        return _clinicContractList[inClinic];
    }
}
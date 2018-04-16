pragma solidity ^0.4.21;

contract ContractPI {
    address private _patient;
    address private _isurance;
    ContractStatus public _status;

    struct Package {
        string _packageId;
        string _name;
        string _duration;
        string _description;
        string _price;
    }

    enum ContractStatus {
        NEW,                // When Patient accepted (deployed).
        SIGNED,             // When Isurer accepted.
        PATIENT_CANCELLED,  // When Patient cancel and withdraw money.
        REJECTED            // When Isurer rejected. 
    }

    modifier onlyInsurer {
        require(msg.sender == _isurance);
        _;
    }

    function signed() public onlyInsurer {

    }
}
App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    $('.review-box').hide();
    currentContractUICount = 0;
    patientContractAddresses = new Array();
    // Currently, these accounts are holding in source code
    // They should be hold in database system.
    patientAcc = "0xf17f52151EbEF6C7334FAD080c5704D77216b732";
    clinicAcc = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef";

    // Init the web3
    return App.initWeb3();

    // Init action listener for buttons
    App.bindEvents();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    // Init contract setting(provider)
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('ContractCPList.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ContractCPListArtifact = data;
      App.contracts.ContractCPList = TruffleContract(ContractCPListArtifact);
    
      // Set the provider for our contract
      App.contracts.ContractCPList.setProvider(App.web3Provider);

      // Init patient management
      return App.initPatientList();
    });

    $.getJSON('ContractCP.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ContractCPArtifact = data;
      App.contracts.ContractCP = TruffleContract(ContractCPArtifact);
    
      // Set the provider for our contract
      App.contracts.ContractCP.setProvider(App.web3Provider);

      return;
    });
  },

  initPatientList: function() {
    App.contracts.ContractCPList.deployed().then(function(instance) {
      return instance.getClinicContracts.call(clinicAcc);
    }).then(function(result) {
      if(patientContractAddresses.length < result.length) {
        for (let i = patientContractAddresses.length; i < result.length; i++) {
          patientContractAddresses[i] = result[i];
        }
        App.renderPatientList();
      }
      console.log("getClinicContracts is called" + result);
    }).catch(function(err) {
      console.log(err.message);
    });

    const filter = web3.eth.filter('latest');
    filter.watch((error, result) => {
      if(error) {
        console.log(`Failed to connect to blockchain: ${error}`);
      } else {
        // Retrieve patient list
        App.initPatientList();
      }
    });
  },

  renderPatientList: function() {
    if(currentContractUICount < patientContractAddresses.length) {
      $('.review-empty-message').hide();
      for (let i = currentContractUICount; i < patientContractAddresses.length; i++) {
        var address = patientContractAddresses[i];
        var reviewBox = $('.review-box').eq(i);
        reviewBox.find('.rev-info').text(address);
        reviewBox.find('.clinic_accept_patient').attr('address', address);
        reviewBox.show();
        currentContractUICount++;
      }
    }
  },

  bindEvents: function() {
    $(document).on('click', '.clinic_accept_patient', App.clinicAcceptPatient);
  },

  clinicAcceptPatient: function(event) {
    event.preventDefault();

    App.contracts.ContractCPList.deployed().then(function(instance) {
      return instance.createContract(clinicAcc, patientAcc, [1,2]);
    }).then(function(result) {
      console.log("createContract is called" + result);
    }).catch(function(err) {
      console.log(err.message);
    });
  }
}

$(function() {
  $(window).load(function() {
    App.init();
  });
});

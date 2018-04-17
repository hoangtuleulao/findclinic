App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
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

    patientAcc = "0xf17f52151EbEF6C7334FAD080c5704D77216b732";
    clinicAcc = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef";

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('ContractCPList.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ContractCPListArtifact = data;
      App.contracts.ContractCPList = TruffleContract(ContractCPListArtifact);
    
      // Set the provider for our contract
      App.contracts.ContractCPList.setProvider(App.web3Provider);

      return;
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn_1', App.bookNow);
  },

  bookNow: function(event) {
    event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.ContractCPList.deployed().then(function(instance) {
        instance.CreateContractEvent().watch((err, res) => {
          if (err) console.log(err);
          console.log('contract address', res.message);
      });
        console.log("accounts[0] = " + accounts[0]);
        console.log("clinicAcc = " + clinicAcc);
        console.log("patientAcc = " + patientAcc);
        //  function createContract(address inClinic, address inPatient, string[] inCheckItems) {
        return instance.createContract(clinicAcc, patientAcc, ["Noi khoa", "Rang"] , {from: patientAcc});
      }).then(function(result) {
        console.log("createContract is called");
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }
}

$(function() {
  $(window).load(function() {
    App.init();
  });
});

App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Currently, these accounts are holding in source code
    // They should be hold in database system.
    patientAcc = "0xf17f52151EbEF6C7334FAD080c5704D77216b732"; // patient account
    clinicAcc = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef"; // clinic account

    // Init the web3
    App.initWeb3();

    // Init account watcher (display balance)
    App.initAccountWatcher();

    // Init contract setting(provider)
    App.initContract();
  
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
  },

  initAccountWatcher: function() {
    // Retrieve balance
    App.notifyUpdateUserBalance();

    const filter = web3.eth.filter('latest');
    filter.watch((error, result) => {
      if(error) {
        console.log(`Account balance watcher catch error: ${error}`);
      } else {
        // Retrieve balance
        App.notifyUpdateUserBalance();
      }
    });
  },

  notifyUpdateUserBalance: function() {
    $('#user-balance').hide();
    $('#user-balance-loader').show();
    // Retrieve balance
    web3.eth.getBalance(patientAcc, (error, bal) => {
      if(error) {
        console.log(`getBalance error: ${error}`);
      } else {
        var balanceInWei = bal;
        var balanceInEther = web3.fromWei(bal, "ether");
        console.log(`Balance [${patientAcc}]: ${web3.fromWei(bal, "ether")}`);
        $('#user-balance').text(balanceInEther + ' ETH').attr('value', bal);

        $('#user-balance-loader').hide();
        $('#user-balance').show();
      }
    });
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

    // return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn_1', App.bookNow);
  },

  bookNow: function(event) {
    event.preventDefault();

    App.contracts.ContractCPList.deployed().then(function(instance) {
      instance.CreateContractEvent().watch((err, res) => {
        if (err) console.log(err);
        console.log('contract address', res.message);
      });

      console.log("clinicAcc = " + clinicAcc);
      console.log("patientAcc = " + patientAcc);

      return instance.createContract(clinicAcc, patientAcc,"Rang", {from: patientAcc});
    }).then(function(result) {
      console.log("createContract is called");
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

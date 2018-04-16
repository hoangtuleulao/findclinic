App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    $.getJSON('../clinics.json', function(data) {
      var clinicsRow = $('#clinicsRow');
      var clinicTemplate = $('#clinicTemplate');

      for (i = 0; i < data.length; i ++) {
        clinicTemplate.find('.panel-title').text(data[i].name);
        clinicTemplate.find('img').attr('src', data[i].picture);
        clinicTemplate.find('.clinic-status').text(data[i].status);
        clinicTemplate.find('.clinic-price').text(data[i].price);
        clinicTemplate.find('.clinic-location').text(data[i].location);
        clinicTemplate.find('.btn-accept').attr('data-id', data[i].id);

        clinicsRow.append(clinicTemplate.html());
      }
    });

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

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('ContractCP.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ContractCPArtifact = data;
      App.contracts.ContractCP = TruffleContract(ContractCPArtifact);
    
      // Set the provider for our contract
      App.contracts.ContractCP.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the adopted pets
      return App.markAccepted();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-accept', App.handleAccept);
  },

  markAccepted: function(status, account) {
    var contractCPInstance;

    App.contracts.ContractCP.deployed().then(function(instance) {
      contractCPInstance = instance;

      return contractCPInstance.currentStatus.call();
    }).then(function(status) {
      if (status != 0) {
        $('.panel-clinic').eq(0).find('button').text('Success').attr('disabled', true);
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleAccept: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    var contractCPInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.ContractCP.deployed().then(function(instance) {
        contractCPInstance = instance;

        // Execute adopt as a transaction by sending account
        return contractCPInstance.adopt(petId, {from: account});
      }).then(function(result) {
        return App.markAccepted();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

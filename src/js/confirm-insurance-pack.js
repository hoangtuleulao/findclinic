App = {
  web3Provider: null,
  contracts: {},

  init: function() {

    var price = '$';
    var insuranceItems = 'XXX';
    var packId = App.getURLParameter('pack');
    var packName = 'N/A';
    if(packId == '1') {
      packName = 'General Pack';
      price = '$100';
    }
    else if(packId == '2') {
      packName = 'Premium Pack';
      price = '$300';
    }
    $('#packName').text(packName);

    var period = App.getURLParameter('period');
    var periodName = 'N/A';
    if(period == '6') {
      periodName = '6 months';
      price = '$200';
    }
    else if(period == '12') {
      periodName = '1 year';
      price = '$400';
    }

    $('#period').text(periodName);

    $('#price').text(price);

    $('#insuranceItems').text(insuranceItems);

  },
  
  getURLParameter: function(sParam) {
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) {
            return sParameterName[1];
        }
    }
  }
}


$(function() {
  $(window).load(function() {
    App.init();
  });
});

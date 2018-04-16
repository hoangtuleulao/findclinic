var ContractCP = artifacts.require("ContractCP");

module.exports = function(deployer) {
  var clinicAddress = "0xf17f52151EbEF6C7334FAD080c5704D77216b732";
  var patientAddresss = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef";
  var description = "Example description";
  var estimation = 10000; // 10 seconds
  var amount = 10; // ether

  deployer.deploy(ContractCP, clinicAddress, patientAddresss, description, estimation, amount, {from: "0x627306090abaB3A6e1400e9345bC60c78a8BEf57", value: 10000000000000000000});
  // Note: deployer.deploy(CONTRACT, "123", {from:web3.eth.accounts[0], value:1000000});
  // "0xf17f52151EbEF6C7334FAD080c5704D77216b732", "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef", "Example description", 10000, 10
  // var Web3 = require("../node_modules/web3/");
  // web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  // module.exports = function(deployer) {
  // deployer.deploy(CONTRACT, "123", {from:web3.eth.accounts[0], value:1000000});
  // };
}
const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledFactory = require('../build/ContractCPList.json');
const compiledCampaign = require('../build/ContractCP.json');

let accounts;
let factory;
let campaignAddress;
let campaign;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  factory = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
    .deploy({ data: compiledFactory.bytecode })
    .send({ from: accounts[3], gas: '4000000' });

  await factory.methods.createContract(accounts[1], accounts[0], [1,2]).send({
    from: accounts[0],
    gas: '4000000'
  });

  [campaignAddress] = await factory.methods.getPatientContracts(accounts[0]).call();
  
  console.log(campaignAddress);
  
  campaign = await new web3.eth.Contract(
    JSON.parse(compiledCampaign.interface),
    campaignAddress
  );
  
  console.log(factory.options.address);
    console.log(campaign.options.address);
  
});

describe('Campaigns', () => {
  it('deploys a factory and a campaign', () => {
    assert.ok(factory.options.address);
    assert.ok(campaign.options.address);
  });
});



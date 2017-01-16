module.exports = function(deployer) {
//  deployer.deploy(ConvertLib);
//  deployer.autolink();
  deployer.deploy(Project);
  // Deploy FundingHub and create an initial project that requires 2 ether and has a deadline of 72 hours through the constructor.
  deployer.deploy(FundingHub, 1, 2000000000000000000, 72);
};
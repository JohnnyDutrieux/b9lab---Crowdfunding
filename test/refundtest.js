// These tests use a project that is created during deployment of this application.
// the project id = 1, needs 2 ether and has a deadline of 72 hours

contract('fundinghub', function(accounts) {

    //*************************************************************************************************************************
    // test 1. it should be possible to request a refund from the project after a  contribution has been made to that project
    // Scenario is
    // 1. Create a new project
    // 2. Account one makes a contribution
    // 3. Account one requests a refund.
    //*************************************************************************************************************************

    it("should be possible to request a refund from a project if contributed", function() {

      var fundingHub = FundingHub.deployed();
      var account_one = accounts[1];
      var account_one_starting_balance;
      var account_one_ending_balance;
      var project_total_raised_before;
      var project_total_raised_after;
      var amount = 100000000000000000; // 0,1 ether
      var id = 998; //project id of the test project

      // first, get the start balances 

      fundingHub.getProjectDetails.call(id, {from: account_one})
      .then(function(values) {
        project_total_raised_before = Number(values[3]);
        return web3.eth.getBalance(account_one);
        }).then(function(balance) {
          account_one_starting_balance = balance.toNumber(); 

          // create a project

          fundingHub.createProject(id, 2000000000000000000, 24, {from: accounts[2], gas: 3000000})
          }).then(function(tx) {
          
          // Make a contribution of 1 ether to the project

          return fundingHub.contribute(id, {from: account_one, value:amount, gas:3000000})
          }).then(function(tx) {

            // get the end balances

            return web3.eth.getBalance(account_one);
            }).then(function(balance) {
                account_one_ending_balance = balance.toNumber(); 
                return fundingHub.getProjectDetails.call(id, {from: account_one})
                .then(function(values) {
                  project_total_raised_after = Number(values[3]);
 
                  // Check if the balance of the account has been decreased by at least 1 ether
                  assert.isAtLeast(account_one_starting_balance - account_one_ending_balance, amount, "test 1: Amount wasn't correctly taken from the sender");

                  // Check if the raised amount of the project has increased by the amount
                  assert.equal(project_total_raised_after, (project_total_raised_before + amount), "test 1: he project has not been funded correctly");

                  // set the start balances again
                  project_total_raised_before = project_total_raised_after;
                  account_one_starting_balance = account_one_ending_balance;

                  // now request a refund from the project
                  return fundingHub.refund(id, {from: account_one, gas: 3000000})
                  .then(function(success) {

                    // get end balances
                    return web3.eth.getBalance(account_one);
                  }).then(function(balance) {
                      account_one_ending_balance = balance.toNumber(); 
                      return fundingHub.getProjectDetails.call(id, {from: account_one})
                      .then(function(values) {
                        project_total_raised_after = Number(values[3]);

                        // assuming transaction cost is not bigger then 1 ether, check if end balance is higher then start balance
                        assert.isAbove(account_one_ending_balance, account_one_starting_balance, "test 1: Amount wasn't correctly refunded to the sender");

                        // Check if the project raised amount has been decreased by 1 ether
                        assert.equal(project_total_raised_after, (project_total_raised_before - amount), "test 1: The project has not been refunding correctly");
                      });
                  });
                });
              });
    });

    //*************************************************************************************************************************
    // test 2. it should not be possible to request a refund from the project if no contribution has been made to that project.
    // Scenario is
    // 1. Create a new project
    // 2. Account one makes a contribution
    // 3. Account two requests a refund.
    //*************************************************************************************************************************

    it("should not be possible to request a refund from a project if you didn't contribute", function() {

      var fundingHub = FundingHub.deployed();
      var account_one = accounts[1];
      var account_two = accounts[2];
      var account_one_starting_balance;
      var account_one_ending_balance;
      var account_two_starting_balance;
      var account_two_ending_balance;

      var project_total_raised_before;
      var project_total_raised_after;
      var amount = 100000000000000000; // 0,1 ether
      var id = 999; //project id of the test project

      // first, get the start balances 

      fundingHub.getProjectDetails.call(id, {from: account_two})
      .then(function(values) {
        project_total_raised_before = Number(values[3]);
        return web3.eth.getBalance(account_two);
        }).then(function(balance) {
          account_two_starting_balance = balance.toNumber(); 

          // create a project

          fundingHub.createProject(id, 2000000000000000000, 24, {from: accounts[3], gas: 3000000})
          }).then(function(tx) {
          
          // Make a contribution of 1 ether to the project

          return fundingHub.contribute(id, {from: account_one, value:amount, gas:3000000})
          }).then(function(tx) {

            // get the end balances

            return fundingHub.getProjectDetails.call(id, {from: account_two})
            .then(function(values) {
            project_total_raised_after = Number(values[3]);

            // Check if the raised amount of the project has increased by the amount
            assert.equal(project_total_raised_after, (project_total_raised_before + amount), "test2: The project has not been funded correctly by account one");

            // set the start balances again
            project_total_raised_before = project_total_raised_after;
  
            // now request a refund from the project with account two
            return fundingHub.refund(id, {from: account_two, gas: 3000000})
              .then(function(success) {

                // get end balances
                return web3.eth.getBalance(account_two);
                }).then(function(balance) {
                    account_two_ending_balance = balance.toNumber(); 
                    return fundingHub.getProjectDetails.call(id, {from: account_two})
                    .then(function(values) {
                      project_total_raised_after = Number(values[3]);

                      // Check the balance of account two is lower, as he has to be for the transaction
                      assert.isAbove(account_two_starting_balance, account_two_ending_balance, "test 2: Amount wasn't correctly refunded to the sender");

                      // Check if the project raised amount has not changed, as account two made no contribution
                      assert.equal(project_total_raised_after, project_total_raised_before, "test 2: The project has not been refunding correctly");
                    });
                });
              });
            });
    });    

});
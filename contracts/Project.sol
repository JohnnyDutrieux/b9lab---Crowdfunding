pragma solidity ^0.4.2;

contract Project {

   struct ProjectDetails {
	   address projectOwner;
	   uint amountNeeded;
	   uint deadline;
	   uint amountRaised;
   }
 
   ProjectDetails public myProject;

   struct Contribution {
        uint amount;
        address contributor;
    }
	
	Contribution[] contributions;

	event GoalReached(address beneficiary, uint amountRaised);
	event FundTransfer(address backer, uint amount, bool isContribution);

	// constructor
	function Project(
		address _projectOwner,
		uint _amountNeeded,
		uint _timeInHoursForFundRaising
	) 
	{
		myProject.projectOwner = _projectOwner;
		myProject.amountNeeded = _amountNeeded;
		myProject.deadline = now + (_timeInHoursForFundRaising * 1 hours);
		myProject.amountRaised = 0;
	}

	function getAmountNeeded() public constant returns (uint) {
		return myProject.amountNeeded;
	}

	function getprojectOwner() public constant returns (address) {
		return myProject.projectOwner;
	}

	function getDeadline() public constant returns (uint) {
		return myProject.deadline;
	}

	function getAmountRaised() public constant returns (uint) {
		return myProject.amountRaised;
	}


	//fund() - This is the function called when the FundingHub receives a contribution. The function must keep track of the contributor and the individual amount contributed. 
	function fund(address _contributor)
	payable
	public
	{
		// Check deadline
		if (now >= myProject.deadline) throw;

		// Check Amount
		if (myProject.amountRaised >= myProject.amountNeeded) throw;

		contributions.push(
			Contribution({
				amount: msg.value,
				contributor: _contributor
			})
		);
		myProject.amountRaised += msg.value;
		FundTransfer(_contributor, msg.value, true);

		// payout if amountRaised has been reaced
		if (myProject.amountRaised >= myProject.amountNeeded) {
			GoalReached(myProject.projectOwner, myProject.amountRaised);
			payout();
		}
	}	

	//payout() - This is the function that sends all funds received in the contract to the owner of the project. 
	//Use this.balance (not myProject.amountRaised) to be sure no ether is lost.
	function payout() 
	{
//		 if (myProject.projectOwner.send(myProject.amountRaised)) {
		 if (myProject.projectOwner.send(this.balance)) {
		 	FundTransfer(myProject.projectOwner, myProject.amountRaised, false);
		 }
	}

	
	//refund() - This function lets all contributors retrieve their contributions.
	function refund(address toAddress) public returns(bool succesful)
	// check state
	{
		for (uint i = 0; i < contributions.length; i++) {
			if (contributions[i].contributor == toAddress) {
				if (contributions[i].amount > 0 && contributions[i].contributor.send(contributions[i].amount)) {
					FundTransfer(contributions[i].contributor, contributions[i].amount, false);
					myProject.amountRaised = myProject.amountRaised - contributions[i].amount;
					// should not be possible to refund twice, put the amount to zero
					contributions[i].amount = 0;
					return true;
				}
			}
		}
		return false;
	}

}
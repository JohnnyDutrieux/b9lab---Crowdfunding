pragma solidity ^0.4.2;

contract Project {

   enum State {
        Open,
        ElRefund,
        ClosedPayout
    }

   	struct ProjectDetails {
	   address projectOwner;
	   uint amountNeeded;
	   uint deadline;
	   uint amountRaised;
	   State state;
   	}
 
   	ProjectDetails public myProject;

   	struct Contribution {
        uint amount;
        address contributor;
    }
	
	Contribution[] contributions;

	event GoalReached(address beneficiary, uint amountRaised);
	event FundTransfer(address backer, uint amount, bool isContribution);

	modifier projectInState(State _state) {
        if (myProject.state != _state) throw;
        _;
    }

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
		myProject.state = State.Open;
	}

	function getAmountNeeded() public constant returns (uint) {
		return myProject.amountNeeded;
	}

	function getProjectOwner() public constant returns (address) {
		return myProject.projectOwner;
	}

	function getDeadline() public constant returns (uint) {
		return myProject.deadline;
	}

	function getAmountRaised() public constant returns (uint) {
		return myProject.amountRaised;
	}

	function getProjectState() public constant returns (uint) {
		return uint(myProject.state);
	}

	//*********************************************************************************************************************
	//fund() - If the contribution was sent after the deadline of the project passed, or the full amount has been reached, 
	// the function must return the value to the originator of the transaction and call one of two functions. If the full 
	// funding amount has been reached, the function must call payout. If the deadline has passed without the funding goal 
	// being reached, the function must call refund.
	//*********************************************************************************************************************
	function fund(address _contributor)
	payable
	public
	projectInState(State.Open)
	{
		contributions.push(
			Contribution({
				amount: msg.value,
				contributor: _contributor
			})
		);
		myProject.amountRaised += msg.value;
		FundTransfer(_contributor, msg.value, true);

		checkIfFundingCompleteOrExpired();
	}	

	function checkIfFundingCompleteOrExpired() {
        if (myProject.amountRaised >= myProject.amountNeeded) {
        	GoalReached(myProject.projectOwner, myProject.amountRaised);
            myProject.state = State.ClosedPayout;
            payout();
        } else if ( now > myProject.deadline )  {
            myProject.state = State.ElRefund; 
        }
    }

	//*********************************************************************************************************************
	//payout() - This is the function that sends all funds received in the contract to the owner of the project. 
	//Use this.balance (not myProject.amountRaised) to be sure no ether is lost.
	//*********************************************************************************************************************
	function payout() 
	projectInState(State.ClosedPayout)
	{
		if (!myProject.projectOwner.send(this.balance)) {
			throw;
		}
		FundTransfer(myProject.projectOwner, myProject.amountRaised, false);
	}

	//*********************************************************************************************************************
	//refund() - This function lets all contributors retrieve their contributions.
	//*********************************************************************************************************************
	function refund(address toAddress) public returns(bool succesful)
	{
		uint amount = 0;
		for (uint i = 0; i < contributions.length; i++) {
			if (contributions[i].contributor == toAddress) {
				if (contributions[i].amount > 0) {
					amount = contributions[i].amount;
					contributions[i].amount = 0;
					if (contributions[i].contributor.send(amount)) {
						myProject.amountRaised = myProject.amountRaised - amount;
						FundTransfer(contributions[i].contributor, amount, false);
						return true;
					} else {
						contributions[i].amount = amount;
					}
				}
			}
		}
		return false;
	}

}
pragma solidity ^0.4.2;

import "Project.sol";

contract FundingHub {

	struct ProjectAdr {
		address projectAddress;
	}
	mapping(uint => ProjectAdr) public projects;

	uint[] public ids;

	// constructor, will create an initial project.

	function FundingHub(
		uint _id,
		uint _amountNeeded,
		uint _timeInHoursForFundRaising) 
	public
	{
		createProject(_id, _amountNeeded, _timeInHoursForFundRaising);
	}	

	//createProject() - This function should allow a user to add a new project to the FundingHub. The function should deploy a new Project contract and keep track of its address. It should accept all constructor values that the Project contract requires.
	
	function createProject(
		uint _id,
		uint _amountNeeded,
		uint _timeInHoursForFundRaising) 
	public
	returns (bool succesful)
	{
		address newProjectAddress = new Project(msg.sender, _amountNeeded, _timeInHoursForFundRaising);
		projects[_id] = ProjectAdr({
			projectAddress: newProjectAddress
		});
		ids.push(_id);
		return true;
	}

	function contribute(uint _id)
	payable
	public
	{
		Project p = Project(projects[_id].projectAddress);
		p.fund.value(msg.value)(tx.origin);
	}

	function refund(uint _id)
	public
	returns (bool succesful)
	{
		Project p = Project(projects[_id].projectAddress);
		return p.refund(msg.sender);
	}


	function getProjectCount() public constant returns (uint length) {
		return ids.length;
	}

	function getProjectDetails(uint _id) public constant returns (uint, uint, uint, uint, uint) {
		Project p = Project(projects[_id].projectAddress);
		uint amountNeeded = p.getAmountNeeded();
		uint deadline = p.getDeadline();
		uint amountRaised = p.getAmountRaised();
		uint projectState = p.getProjectState();
		return (_id, amountNeeded, deadline, amountRaised, projectState);
	}

}
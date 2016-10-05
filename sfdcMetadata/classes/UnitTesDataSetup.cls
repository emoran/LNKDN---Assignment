@isTest
public class UnitTesDataSetup {
	
	/**
	 * [setupDemoUsers Prepare User demo records]
	 * @return [description]
	 */
	@testSetup public static void setupDemoUsers() {
		Profile profileRecord = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
     	
     	User userDemo1 = new User(	Alias = 'standt', Email='user1@testorg.com', 
      						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = profileRecord.Id, IsActive = true,
      						TimeZoneSidKey='America/Los_Angeles', UserName='user1experiments@testorg.com');

     	insert userDemo1;

     	User userDemo2 = new User(	Alias = 'standt3', Email='user2@testorg.com', 
      						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      						LocaleSidKey='en_US', ProfileId = profileRecord.Id, IsActive = true,
      						TimeZoneSidKey='America/Los_Angeles', UserName='user2experiments@testorg.com');

     	insert userDemo2;
	}

	@testSetup public static void setupDataRelationShips() {
		List<Opportunity> opportunityList				= new List<Opportunity>();
		List<OpportunityContactRole> contactRoleList	= new List<OpportunityContactRole>();

		User user1 = [Select Id from User where UserName='user1experiments@testorg.com' limit 1];
		User user2 = [Select Id from User where UserName='user2experiments@testorg.com' limit 1];

		Account account = new Account();
		account.Name = 'ACCDEMO1';
		insert account;
		
		Contact contact		= new Contact();
		contact.FirstName	= 'DEMO';
		contact.LastName	= 'DEMO LAST';
		contact.Email		= 'demo1@experiments.com';
		contact.AccountId	= account.Id;
		insert contact;

		Opportunity opportunity		= new Opportunity();
		opportunity.AccountId		= account.Id;
		opportunity.Name			= 'demo';
		opportunity.StageName		= 'Prospecting';
		opportunity.CloseDate		= Date.today();
		opportunity.OwnerId			= user1.Id;
		
		Opportunity opportunity2	= new Opportunity();
		opportunity2.AccountId		= account.Id;
		opportunity2.Name			= 'demo2';
		opportunity2.StageName		= 'Prospecting';
		opportunity2.CloseDate		= Date.today();
		opportunity2.OwnerId		= user2.Id;

		opportunityList.add(opportunity);
		opportunityList.add(opportunity2);

		insert opportunityList;

		for(Opportunity opp:[Select Id from Opportunity]){
			OpportunityContactRole contactRole	= new OpportunityContactRole();
			contactRole.OpportunityId			= opp.Id;
			contactRole.ContactId				= contact.Id;
			contactRoleList.add(contactRole);
		}

		insert contactRoleList;	
	}
	
}
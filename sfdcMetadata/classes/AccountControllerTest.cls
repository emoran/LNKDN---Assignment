@isTest
public  class AccountControllerTest {
	
	@isTest static void test_Contact() {
		// Implement test code
	}
	
	/**
	 * [setupTestData_Scenario1]
	 * 1 Account
	 * 2 Opportunities (Both contains contactRoles)
	 * 	Opp1 OwnerId Same as User running action
	 * 	Opp2 OwnerId different from the user running the process 
	 * 1 Contact to Convert
	 * @return [description]
	 */
	@testSetup public static void setupTestData_Scenario1() {
		UnitTesDataSetup.setupDemoUsers();
		UnitTesDataSetup.setupDataRelationShips();

		User user1 = [Select Id from User where UserName='user1experiments@testorg.com' limit 1];

		System.runAs(user1){	
			Account account = [Select Id,Name from Account where Name='ACCDEMO1' limit 1];
			account.Name = 'MychangedAccount';
			update account;

			CheckRecursive.run  = false;

			update account;

			System.assertEquals(1,[Select Id from Lead where Email ='demo1@experiments.com'].size());//one lead has been created
			System.assertEquals(0,[Select Id from Contact where Email ='demo1@experiments.com'].size());//one contact was deleted

		}
	}

}
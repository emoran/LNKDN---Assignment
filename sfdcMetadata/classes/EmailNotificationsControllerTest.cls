@isTest
private class EmailNotificationsControllerTest {
	
	@isTest static void test_method_one() {	
		UnitTesDataSetup.setupDemoUsers();
		UnitTesDataSetup.setupDataRelationShips();

		Opportunity opp = [Select Id from Opportunity where Name='demo' limit 1];

		EmailNotificationsController notification = new EmailNotificationsController();
		notification.sendEmailNotification(new List<String>{'yucel.moran@gmail.com'},opp.Id,'Notify Opportunity Owner');
	}	
}
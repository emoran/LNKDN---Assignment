@isTest
private class ContactToLeadClassTest {
	
	@isTest static void test_method_one() {
		UnitTesDataSetup.setupDemoUsers();
		UnitTesDataSetup.setupDataRelationShips();

		List<String> contactIds = new List<String>();
		for(Contact contact:[Select Id from Contact]){
			contactIds.add(contact.Id);
		}
		ContactToLeadClass.convertContactToLead(contactIds);
		System.assertEquals(1,[Select Id from Lead where Email ='demo1@experiments.com'].size());//one lead has been created
		System.assertEquals(0,[Select Id from Contact where Email ='demo1@experiments.com'].size());//one contact was deleted
	}
}
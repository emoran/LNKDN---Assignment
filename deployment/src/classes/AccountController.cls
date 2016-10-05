public with sharing class AccountController {
	public AccountController() {}

	/**
	 * [convertContacts Convert related Contacts to Leads]
	 * @param accounts [Accounts updated]
	 */
	public void convertContacts(Account[] accounts){

		Set<Id> idAccounts = new Set<Id>();
		List<String> contactIds = new List<String>();

		for(Account account:accounts){
			idAccounts.add(account.Id);
		}

		for(Contact contact:[Select Id,AccountId from Contact where AccountId IN:idAccounts]){
			contactIds.add(contact.Id);
		}

		//ContactToLeadClass contactToLead = new ContactToLeadClass();
		ContactToLeadClass.convertContactToLead(contactIds);
	}
}
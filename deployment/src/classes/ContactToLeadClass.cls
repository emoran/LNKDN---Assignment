global with sharing class ContactToLeadClass {
	

	/**
	 * [convertContactToLead description]
	 * @param  contacts [description]
	 * @return          [description]
	 */
	webservice static void convertContactToLead(String[] contactIds){

		// Here we get Contact fields with Describe instead of just get some (avoid 'Sobject retrive information Exception')
		SObjectType objectType								= Schema.getGlobalDescribe().get('Contact');
		Map<String,Schema.SObjectField> contactFieldsMap	= objectType.getDescribe().fields.getMap();
		List<String> fields									= new List<String>(contactFieldsMap.keySet());
		List<Contact> contactList = new List<Contact>();

		for (Contact contactInformation : Database.query(''+ ' Select ' + String.join(fields, ',')
									        + ' from Contact'
		       								+ ' where ID IN:contactIds')) {
			contactList.add(contactInformation);
		}

		Set<Id> idContacts									= new Set<Id>();
		Set<Id> idAccounts									= new Set<Id>();
		Set<Id> idOpportunities								= new Set<Id>();
		List<OpportunityContactRole> contactRolesToDelete	= new List<OpportunityContactRole>();
		List<Lead> leadsToCreate							= new List<Lead>();

		//collect contact ids
		for(Contact contact:contactList){
			idContacts.add(contact.Id);
			idAccounts.add(contact.AccountId);
		}

		//Allows to add additional fields from the related conctact account since we are getting query fields from getDescribe method
		Map<Id, Account> mapAccountInfo = new Map<Id, Account>([SELECT Id, Name,NumberOfEmployees 
																	FROM Account 
																	where Id IN:idAccounts]);

		//collect contact roles in open opps
		for(OpportunityContactRole contactRole:[Select Id,OpportunityId from OpportunityContactRole 
															where ContactId IN:idContacts 
															and Opportunity.IsClosed = FALSE]){
			contactRolesToDelete.add(contactRole);
			idOpportunities.add(contactRole.OpportunityId);
		}	

		//Collect each opportunity where contacts are included
		Map<Id, Opportunity> mapOpportunityInfo = new Map<Id, Opportunity>([SELECT Id,Owner.Email,OwnerId  
																	FROM Opportunity 
																	where Id IN:idOpportunities]);

		//Create a Lead Object
		for(Contact contact:contactList){
			
			Lead leadFromContact				= new Lead();
			leadFromContact.Street				= contact.MailingStreet;
			leadFromContact.State				= contact.MailingState;
			leadFromContact.Country				= contact.MailingCountry;
			leadFromContact.PostalCode			= contact.MailingPostalCode;
			leadFromContact.Description			= contact.Description;
			leadFromContact.DoNotCall			= contact.DoNotCall;
			leadFromContact.Email				= contact.Email;
			leadFromContact.HasOptedOutOfEmail	= contact.HasOptedOutOfEmail;
			leadFromContact.Fax					= contact.Fax;
			leadFromContact.HasOptedOutOfFax	= contact.HasOptedOutOfFax;
			leadFromContact.FirstName 			= contact.FirstName;
			leadFromContact.LastName			= contact.LastName;
			leadFromContact.OwnerId				= contact.OwnerId;
			leadFromContact.LeadSource			= contact.LeadSource;
			leadFromContact.MobilePhone			= contact.MobilePhone;						
			leadFromContact.Phone 				= contact.Phone;
			leadFromContact.Title 				= contact.Title;


			if(mapAccountInfo.get(contact.AccountId) != null){
				leadFromContact.NumberOfEmployees   = mapAccountInfo.get(contact.AccountId).NumberOfEmployees;
				leadFromContact.Company				= mapAccountInfo.get(contact.AccountId).Name;
			}

			leadsToCreate.add(leadFromContact);
		}

		//Creating a save point before process transactions
		Savepoint sp = Database.setSavepoint();

		try{
			//only if there're contact roles associated to opportunities
			if(contactRolesToDelete.size()>0){
				delete contactRolesToDelete;
				
				//Send email notification always the owner is not the same as the user running the action
				for(Opportunity opportunity:mapOpportunityInfo.values()){
					if(opportunity.OwnerId != UserInfo.getUserId()){
						EmailNotificationsController notification = new EmailNotificationsController();
						notification.sendEmailNotification(new List<String>{opportunity.Owner.Email},opportunity.Id,'Notify Opportunity Owner');
					}
				}
			}

			insert leadsToCreate;
			delete contactList;
		}
		catch(Dmlexception e){
			throw new Dmlexception('An error has occurred attempting to execute actions: '+e.getMessage());
			Database.rollback(sp);
		}	
	}

}
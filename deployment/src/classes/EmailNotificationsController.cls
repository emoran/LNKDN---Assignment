public with sharing class EmailNotificationsController {
	
	public Id templateId{get;set;}

	public void sendEmailNotification(String[] recipients,Id whatId,String emailTemplateName){

		final Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		try{
			templateId = [select id, name from EmailTemplate where Name =:emailTemplateName].id;
		}
		catch (Exception e) {
			throw new CustomExceptionController.EmailTemplateException ('Unable to locate EmailTemplate using name: \'Notify Opportunity Owner\' please check the template exist.');
		}

		Contact dummyContact = new Contact(FirstName='DEMO',LastName='DEMOLAST',Email='emoran@demo.com'); 
		insert dummyContact; //NOTE: This contact is created just because we are using a Email Template with merge fields of Opportunities, if it is only an informative email this piece is not needed.
		
		email.setToAddresses(recipients);
	    email.setTargetObjectId(dummyContact.Id);
	    email.setWhatId(whatId);
	    email.setTemplateId(templateId);
	    email.setSaveAsActivity(false);
	    
	  
	    try {
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	        delete dummyContact;//Deleting dummy contact
	        return;
	    }
	    catch (EmailException e) {
    		throw new EmailException(' An error has occurred when send Email notification' + e.getMessage());
    	}  
	}
}
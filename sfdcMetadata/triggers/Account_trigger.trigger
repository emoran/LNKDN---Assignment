trigger Account_trigger on Account (after update) {

	if(Trigger.isUpdate){
		if(Trigger.isAfter || Trigger.isUpdate){	
			if(checkRecursive.runOnce()){
				AccountController accController = new AccountController();
				accController.convertContacts(Trigger.new);
			}
		}	
	}
}
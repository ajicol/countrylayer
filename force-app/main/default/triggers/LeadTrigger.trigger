trigger LeadTrigger on Lead (before insert, before update) {

	LeadTriggerHandler handler = new LeadTriggerHandler();

	if(Trigger.isInsert && Trigger.isBefore) {
		handler.onBeforeInsert(Trigger.new);
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
	}
}
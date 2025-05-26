trigger CaseRequestTrigger on Case_Request__c (after update) {
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            CaseRequestHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}
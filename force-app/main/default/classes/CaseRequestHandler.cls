/**
* @File Name : CaseRequestHandler.cls
* @Description : Class responsible for orchestrating the business rule
* @Author : Anderson Carvalho da Silva
* @Last Modified By : Anderson Carvalho da Silva
* @Last Modified On : May 21, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 | Anderson Carvalho da Silva | Initial Version
**/

public with sharing class CaseRequestHandler {
    
    public static final String STATUS_CLOSED = 'Closed';
    
    public static void afterUpdate(Map<Id, Case_Request__c> oldCases, Map<Id, Case_Request__c> newCases) {        
        List<Case_History__c> caseHistories = new List<Case_History__c>();
        Datetime dateTimeNow = System.now();

        for (Id caseId : newCases.keySet()) {
            Case_Request__c oldRec = oldCases.get(caseId);
            Case_Request__c newRec = newCases.get(caseId);
			
            if (oldRec.Status__c != STATUS_CLOSED && newRec.Status__c == STATUS_CLOSED) {
                caseHistories.add(CaseRequestService.buildHistory(newRec, dateTimeNow));
            }
        }

        if(!caseHistories.isEmpty()) {
            Database.insert(caseHistories);
        }
    }
}
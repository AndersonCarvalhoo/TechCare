/**
* @File Name : CaseRequestService.cls
* @Description : Class responsible for executing the business rule
* @Author : Anderson Carvalho da Silva
* @Last Modified By : Anderson Carvalho da Silva
* @Last Modified On : May 21, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 | Anderson Carvalho da Silva | Initial Version
**/

public class CaseRequestService {
	public static Case_History__c buildHistory(Case_Request__c caseRequest, Datetime now) {
        Boolean isSLADeadlineMet = caseRequest.SLA_Deadline__c != null && now <= caseRequest.SLA_Deadline__c;

        return new Case_History__c(
            Name = 'Case Request ' + caseRequest.Name + ' History',
            Case_Request__c = caseRequest.Id,
            Time_Closed__c = now,
            SLA_Met__c = isSLADeadlineMet
        );
    }
}
/**
* @File Name : CaseRequestDetailController.cls
* @Description : Class responsible for handling the requests made by the caseRequestDetail component.
* @Author : Anderson Carvalho da Silva
* @Last Modified By : Anderson Carvalho da Silva
* @Last Modified On : May 21, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 | Anderson Carvalho da Silva | Initial Version
**/

public with sharing class CaseRequestDetailController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSLAInfo(Id caseRequestId) {
        return CaseRequestDetailService.getSLAInfo(caseRequestId);
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> reopenCaseRequest(Id caseRequestId) {
        return CaseRequestDetailService.reopenCaseRequest(caseRequestId);
    }
}

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

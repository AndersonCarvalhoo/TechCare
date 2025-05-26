/**
* @File Name : CaseRequestRestResource.cls
* @Description : Class responsible for exposing a RestResource that, given a caseId, returns JSON
* @Author : Anderson Carvalho da Silva
* @Last Modified By : Anderson Carvalho da Silva
* @Last Modified On : May 21, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 | Anderson Carvalho da Silva | Initial Version
**/

@RestResource(urlMapping='/CaseRequest/*')
global with sharing class CaseRequestRestResource {

    @HttpGet
    global static void getCaseRequestInfo() {
        RestRequest request = RestContext.request;
        String caseId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        Map<String, Object> responseMap = new Map<String, Object>();
        if (String.isBlank(caseId) || caseId.length() < 15) {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf('{"error":"Invalid or missing CaseRequest Id"}');
            return;
        }
        
        try {
            Case_Request__c caseRequest = [
            SELECT Status__c, (SELECT SLA_Met__c FROM Case_Histories__r WHERE Case_Request__c = :caseId LIMIT 1) FROM Case_Request__c WHERE Id = :caseId LIMIT 1
            ];

            response.statusCode = 200;
            Boolean slaMet = !caseRequest.Case_Histories__r.isEmpty() ? caseRequest.Case_Histories__r[0].SLA_Met__c : null;
            responseMap.put('Status', caseRequest.Status__c);
            responseMap.put('Sla_Met', slaMet);

            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        } catch (QueryException e) {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf('{"error":"Case request not found"}');
        }
        
    }
}
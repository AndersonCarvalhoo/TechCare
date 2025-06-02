/**
* @File Name : CaseRequestRestResourceTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 23, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 23, 2025 |   | Initial Version
**/

@IsTest
public class CaseRequestRestResourceTest {

    @testSetup
    static void setupData() {
        Case_Request__c caseReq = new Case_Request__c(
            Status__c = 'Closed',
            SLA_Deadline__c = System.now().addDays(1),
            Resolution_Notes__c = 'Resolution Notes Example Test'
        );
        insert caseReq;

        Case_History__c history = new Case_History__c(
            Name = 'Case Request 000001 History',
            Case_Request__c = caseReq.Id,
            SLA_Met__c = true,
            Time_Closed__c = System.now()
        );
        insert history;
    }

    @isTest
    static void testGetCaseRequestInfoByIdSuccess() {
        Case_Request__c caseReq = [
            SELECT Id FROM Case_Request__c WHERE Status__c = 'Closed' LIMIT 1
        ];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseRequest/' + caseReq.Id;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        CaseRequestRestResource.getCaseRequestInfo();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug(resultMap);

        System.assertEquals('Closed', resultMap.get('Status'), 'Status deveria ser Closed');
        System.assertEquals(true, resultMap.get('Sla_Met'), 'SLA deveria ter sido cumprido');
    }

    @IsTest
    static void testGetCaseRequestInfoInvalidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseRequest/' + '04325';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        CaseRequestRestResource.getCaseRequestInfo();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug(resultMap);

        System.assertEquals('Invalid or missing CaseRequest Id', resultMap.get('error'), 'Id deve ser válido');
        System.assertEquals(400, RestContext.response.statusCode, 'Status code deve ser 400');
    }

    @IsTest
    static void testGetCaseRequestInfoQueryException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseRequest/' + 'a00gK504003w454QAQ';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        CaseRequestRestResource.getCaseRequestInfo();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug(resultMap);

        System.assertEquals('Case request not found', resultMap.get('error'), 'Id deve ser existente');
        System.assertEquals(404, RestContext.response.statusCode, 'Status code deve ser 404');
    }
}
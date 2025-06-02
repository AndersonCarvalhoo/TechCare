@IsTest
public class CaseRequestDetailTest {

    @TestSetup
    static void setupData(){
        Case_Request__c caseRequest = new Case_Request__c(
            Status__c = 'New',
            SLA_Deadline__c = System.now()+1
        );
        insert caseRequest;
    }

    @IsTest
    static void testGetSLAInfo() {
        Case_Request__c caseRequestQuery = [SELECT Id, Status__c, SLA_Deadline__c FROM Case_Request__c WHERE Status__c = 'New' LIMIT 1];

        Map<String, Object> caseInfo = (Map<String, Object>) CaseRequestDetailController.getSLAInfo(caseRequestQuery.Id);

        System.assertEquals(caseRequestQuery.SLA_Deadline__c, caseInfo.get('slaEnd'));
        System.assertEquals(caseRequestQuery.Status__c, caseInfo.get('status'));

    }
    
    static User createUser(Boolean hasPermission) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'test' + Math.random() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + Math.random() + '@example.com'
        );
        insert u;

        Group queue = [SELECT Id FROM Group where type = 'Queue' and Name = 'Support Premium Queue' limit 1];

        GroupMember gm = new GroupMember(
            GroupId = queue.Id,
            UserOrGroupId = u.Id
        );
        insert gm;

        if (hasPermission) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Support_Premium' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }
        return u;
    }

    @isTest
    static void testReopenWithPermission() {
        User u = createUser(true);
        System.runAs(u) {
            Case_Request__c cr = new Case_Request__c(Status__c = 'Closed', Resolution_Notes__c = 'Test example');
            insert cr;

            System.debug([SELECT RecordType.Name, Owner.Name FROM Case_Request__c]);
            Map<String, Object> res = CaseRequestDetailController.reopenCaseRequest(cr.Id);
            cr = [SELECT Status__c FROM Case_Request__c WHERE Id = :cr.Id];
            
            System.assertEquals('In Progress', cr.Status__c);
            System.assertEquals('Caso reaberto com sucesso!', res.get('message'));
        }
    }

    @isTest
    static void testReopenWithoutPermission() {
        User u = createUser(false);
        System.runAs(u) {
            Case_Request__c cr = new Case_Request__c(Status__c = 'Closed', Resolution_Notes__c = 'Test example');
            insert cr;

            Map<String, Object> res = CaseRequestDetailController.reopenCaseRequest(cr.Id);
            cr = [SELECT Status__c FROM Case_Request__c WHERE Id = :cr.Id];

            System.assertEquals('Closed', cr.Status__c);
            System.assertEquals('Você não tem permissão suficiente parar reabrir Casos.', res.get('error'));
        }
    }
    @isTest
    static void testReopenCaseRequest_CaseNotFound() {
        Id fakeId = Id.valueOf('a01000000000000AAA');

        Test.startTest();
        Map<String, Object> result = CaseRequestDetailController.reopenCaseRequest(fakeId);
        Test.stopTest();

        System.assertEquals(true, result.containsKey('error'), 'Deveria conter a chave "error"');
        System.assertEquals('Caso não encontrado', result.get('error'), 'Mensagem de erro incorreta');
    }
}

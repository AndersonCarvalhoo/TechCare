/**
* @File Name : CaseRequestHandlerTest.cls
* @Description : Class responsible for testing the class CaseRequestHandler
* @Author : Anderson Carvalho da Silva
* @Last Modified By : Anderson Carvalho da Silva
* @Last Modified On : May 21, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 | Anderson Carvalho da Silva | Initial Version
**/

@IsTest
public class CaseRequestHandlerTest {
    
    @testSetup //Configuração dos dados reutilizáveis
    static void setupData() {
        Case_Request__c cr = new Case_Request__c(
            Status__c = 'New'
        );
        insert cr;
    }
    
    @isTest //Teste da criação do histório após fechar o caso
    static void testCreatesHistoryWhenClosed() {
        Case_Request__c crToUpdate = [SELECT Id, Status__c, Resolution_Notes__c FROM Case_Request__c WHERE Status__c = 'New' LIMIT 1];
        
        crToUpdate.Status__c = 'Closed';
        crToUpdate.Resolution_Notes__c = 'Test Resolution Notes';
        update crToUpdate;

        List<Case_History__c> results = [
            SELECT Id FROM Case_History__c WHERE Case_Request__c = :crToUpdate.Id
        ];

        System.assertEquals(1, results.size(), 'Deveria retornar 1 registro');
    }

    @isTest //Teste da criação do histório após fechar o caso sem preeencher o campo Resolution Notes
    static void testCreatesHistoryWhenClosedWithoutResolutionNotes() {
        Case_Request__c crToUpdate = [SELECT Id, Status__c, Resolution_Notes__c FROM Case_Request__c WHERE Status__c = 'New' LIMIT 1];        
        crToUpdate.Status__c = 'Closed';
        
        Test.startTest();
            try {
                update crToUpdate;
                System.assert(false, 'Esperava falha por campo obrigatório ausente');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Resolution Notes'), 'Mensagem de erro não corresponde');
            }
        Test.stopTest();
    }
}
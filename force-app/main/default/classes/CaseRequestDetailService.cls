public with sharing class CaseRequestDetailService {

    public static Map<String, Object> getSLAInfo(Id caseRequestId) {
        Case_Request__c req = [
            SELECT SLA_Deadline__c, Status__c, CreatedDate, Resolution_Notes__c 
            FROM Case_Request__c 
            WHERE Id = :caseRequestId 
            LIMIT 1
        ];

        Long millisRemaining = req.Status__c != 'Closed' ? req.SLA_Deadline__c.getTime() - DateTime.now().getTime() : 0;

        Long totalMilliseconds = req.SLA_Deadline__c.getTime() - req.CreatedDate.getTime();

        Boolean supportPremiumUser = supportPremiumUser('Support_Premium');

        return new Map<String, Object>{
            'slaEnd' => req.SLA_Deadline__c,
            'totalMilliseconds' => totalMilliseconds,
            'millisRemaining' => millisRemaining,
            'status' => req.Status__c,
            'resolutionNotes' => req.Resolution_Notes__c,
            'supportPremiumUser' => supportPremiumUser
        };
    }

    public static Map<String, Object> reopenCaseRequest(Id caseRequestId) {
        Case_Request__c caseRequest = [
            SELECT Status__c 
            FROM Case_Request__c 
            WHERE Id = :caseRequestId 
            LIMIT 1
        ];
        Boolean isSupportPremiumUser = SupportPremiumUser('Support_Premium');

        if(caseRequest != null) {
            if(isSupportPremiumUser) {
                caseRequest.Status__c = 'In Progress';
                Database.update(caseRequest);
                return new Map<String, Object>{
                    'message' => 'Caso reaberto com sucesso!'
                };
            } else {
                return new Map<String, Object>{
                    'error' => 'Você não tem permissão suficiente parar reabrir Casos.'
                };
            }
        }
        return new Map<String, Object>{
            'error' => 'Caso não encontrado'
        };
    }

    private static Boolean supportPremiumUser(String permissionSetName) {
        Id currentUserId = UserInfo.getUserId();

        List<PermissionSetAssignment> psa = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :currentUserId 
            AND PermissionSet.Name = :permissionSetName
        ];

        return !psa.isEmpty();
    }
}

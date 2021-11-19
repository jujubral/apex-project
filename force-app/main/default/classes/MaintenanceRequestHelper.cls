public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> mainReqList) {
        Map<Id, Integer> dueDateMap = new Map<Id, Integer>();
        Map<Id,Case> newMainReqIdMap = new Map<Id,Case>();
        List<Case> insertMainReqList = new List<Case>();
        List<Case> mainReqIdList = new List<Case>();
        for(Case mainReq : mainReqList){
            if((mainReq.Type == 'Repair' || mainReq.Type == 'Routine Maintenance') && mainReq.Status == 'Closed'){
                mainReqIdList.add(mainReq);   
            }
        }    
        
        List<AggregateResult> minCycleDaysList = [Select Maintenance_Request__c reqId, MIN(Equipment__r.Maintenance_Cycle__c)
                                                            From Equipment_Maintenance_Item__c 
                                                            Where Maintenance_Request__c IN : mainReqIdList
                                                            Group by Maintenance_Request__c];
        for(AggregateResult minDate : minCycleDaysList){
            dueDateMap.put((Id)minDate.get('reqId'), Integer.valueOf(minDate.get('expr0')));
        }
         
            for(Case mainReq : mainReqIdList){
                Case newMainReq = new Case();
                newMainReq.Vehicle__c = mainReq.Vehicle__c;
                newMainReq.status = 'New';
                newMainReq.Type = 'Routine Maintenance';
                newMainReq.Subject = 'Subject';
                newMainReq.Date_Reported__c = Date.today();
                if(dueDateMap.get(mainReq.Id) != null){
                    newMainReq.Date_Due__c = Date.today().addDays(dueDateMap.get(mainReq.Id));
                }
                else{
                    newMainReq.Date_Due__c = Date.today();
                }
                insertMainReqList.add(newMainReq);
                newMainReqIdMap.put(mainReq.Id,newMainReq);
            }  
            insert insertMainReqList; 
            
            cloneEquipItems(mainReqIdList,newMainReqIdMap);               
    }

    public static void cloneEquipItems(List<case> mainReqIdList, Map<Id,case> newMainReqIdMap){
        List<Equipment_Maintenance_Item__c> newEquipItems = new List<Equipment_Maintenance_Item__c>();
            List<Equipment_Maintenance_Item__c> oldEquipItems = [Select Equipment__c, Maintenance_Request__c, Quantity__c,Maintenance_Request__r.Id
                                                                 From Equipment_Maintenance_Item__c
                                                                 Where Maintenance_Request__c IN :mainReqIdList];
            
            for(Equipment_Maintenance_Item__c equipItem : oldEquipItems) {
                Equipment_Maintenance_Item__c newItem = equipItem.clone(false, true, false, false);
                newItem.Maintenance_Request__c = newMainReqIdMap.get(equipItem.Maintenance_Request__c).id;
                newEquipItems.add(newItem);
            }
            insert newEquipItems;
    }
}
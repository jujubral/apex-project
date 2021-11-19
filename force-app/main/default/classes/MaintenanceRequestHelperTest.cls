@isTest
public with sharing class MaintenanceRequestHelperTest {

    @TestSetup
    private static void prepareTestData(){
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name = 'Bike';
        insert vehicle;
        
        List<Product2> equipmentList = new List<Product2>();
        Product2 equipment = new Product2();
        equipment.Name = 'Wheel pump';
        equipment.isActive = true;
        equipment.Maintenance_Cycle__c = 5;
        equipment.Replacement_Part__c = true;
        equipmentList.add(equipment);

        Product2 nullCycleEquipment = new Product2();
        nullCycleEquipment.Name = 'Nullable Cycle';
        nullCycleEquipment.isActive = true;
        nullCycleEquipment.Maintenance_Cycle__c = null;
        nullCycleEquipment.Replacement_Part__c = true;
        equipmentList.add(nullCycleEquipment);

        insert equipmentList;

        List<Case> mainReqBulk = new List<Case>();
        for(Integer i=0; i<=300; i++){
            Case newMainReq = new Case();
            newMainReq.Subject = 'Subject';
            newMainReq.Type = 'Repair';
            newMainReq.Status = 'New';
            newMainReq.Origin = 'Web';
            if(i<50)
                newMainReq.ProductId = nullCycleEquipment.Id;
            else
                newMainReq.ProductId = equipment.Id;
            newMainReq.Vehicle__c = vehicle.Id;
            mainReqBulk.add(newMainReq);
        }
        insert mainReqBulk;

        List<Equipment_Maintenance_Item__c> equipMainItemBulk = new List<Equipment_Maintenance_Item__c>();
        for(Integer i=0; i<=300; i++){
            Equipment_Maintenance_Item__c newEquipMainItem = new Equipment_Maintenance_Item__c();
            if(i<50)
                newEquipMainItem.Equipment__c = nullCycleEquipment.Id;
            else
                newEquipMainItem.Equipment__c = equipment.Id;
            newEquipMainItem.Maintenance_Request__c = mainReqBulk.get(i).Id;
            equipMainItemBulk.add(newEquipMainItem);
        }
        insert equipMainItemBulk;

    }

    @isTest
    private static void MaintenanceRequestPositiveTest(){
        Case mainReqToUpdate = [Select Id, Status, ProductId From Case Where Status = 'New' Limit 1 ];
        test.startTest();
        mainReqToUpdate.Status = 'Closed';
        update mainReqToUpdate;
        test.stopTest();

        List<Case> actualMainReqList = [Select Id, Type, Status 
                                        From Case 
                                        Where Status = 'New' And Type ='Routine Maintenance'];

        System.assertEquals(1, actualMainReqList.size());
    }

    @isTest
    private static void MaintenanceRequestNegativeTest(){
        List<Case> mainReqToUpdate = [Select Id, Status From Case Where Status = 'New'];
        
        test.startTest();
        mainReqToUpdate.get(1).Status = 'Working';
        update mainReqToUpdate;
        test.stopTest();

        List<Case> actualMainReqList = [Select Id, Type, Status From Case Where Status = 'New'];
        System.assertEquals(mainReqToUpdate.size()-1, actualMainReqList.size());
    }

    @isTest
    private static void MaintenanceRequestBulkTest(){
        List<Case> mainReqBulk = [Select Id, Status From Case Limit 300];

        test.startTest();
        for(Case mainReq : mainReqBulk){
            mainReq.Status = 'Closed';
        }
        update mainReqBulk;
        test.stopTest();

        List<Case> actualMainReqList = [Select Id, Type, Status 
                                        From Case 
                                        Where Status = 'New' And Type = 'Routine Maintenance'];
                                        
        System.assertEquals(300, actualMainReqList.size());
    }
}
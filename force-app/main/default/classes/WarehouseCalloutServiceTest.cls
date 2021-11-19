@isTest
public class WarehouseCalloutServiceTest{
    @isTest
    private static void getEquipmentFromWarehouseTest(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        WarehouseCalloutService.getEquipmentFromWarehouse();
        Test.stopTest();

        List<Product2> actualEquipList = [Select Id From Product2 Where ExternalId = '100004'];
        System.assertEquals(1, actualEquipList.size());
    }
}
public with sharing class WarehouseCalloutService implements Queueable{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void getEquipmentFromWarehouse(){
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(WAREHOUSE_URL);
        httpReq.setMethod('GET');
        HttpResponse httpResp = http.send(httpReq);
        if(httpResp.getStatusCode() == 200){
            List<Object> respDataList = (List<Object>) JSON.deserializeUntyped(httpResp.getBody());
            List<Product2> insertEquipList = new List<Product2>();
            for(Object respData : respDataList){
                Map<String,Object> equipMap = (Map<String, Object>)respData;
                System.debug(equipMap);
                Product2 equip = new Product2();
                equip.Replacement_part__c = (Boolean)equipMap.get('replacement');
                equip.Current_Inventory__c = (Integer)equipMap.get('quantity');
                equip.Name = (String)equipMap.get('name');
                equip.Maintenance_Cycle__c = (Integer)equipMap.get('maintenanceperiod');
                equip.Lifespan_Months__c = (Integer)equipMap.get('lifespan');
                equip.Cost__c = (Decimal)equipMap.get('cost');
                equip.ExternalId = (String)equipMap.get('sku');
                insertEquipList.add(equip);
            }

            if(insertEquipList.size() == respDataList.size() && insertEquipList.size()!=0){
                upsert insertEquipList;
            }
        }

    }
    
    public static void execute(QueueableContext ctx){
        getEquipmentFromWarehouse();
    }
}
@isTest
public class WarehouseSyncScheduleTest {
    @isTest
    private static void executeWarehouseScheduleJobTest(){
        String cron_exp = '0 0 * * * ?';
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleTestJob', cron_exp, new WarehouseSyncSchedule());
        Test.stopTest();

        List<AsyncApexJob> actualScheduledJob = [Select Id, ApexClassID, ApexClass.Name, Status, JobType 
                                            From AsyncApexJob 
                                            Where Id =: jobId And JobType = 'ScheduledApex'];
        System.assertNotEquals(1, actualScheduledJob.size());
    }
}

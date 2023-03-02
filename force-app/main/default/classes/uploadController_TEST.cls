@isTest
private class uploadController_TEST {

    static List<String> heading=new List<String>();
    static List<String> content=new List<String>();
    static String target;

    private static void prepareTestData() {
        target='Account';
        
        heading.add('Name');
        heading.add('AccountNumber');
        heading.add('AnnualRevenue');

        content.add('Test0001,0001,100');
        content.add('Test0002,0001,abc');
        }

    private static testMethod void testUpload(){
        Test.startTest();
        prepareTestData();
        String fName='Test';
        uploadController.uploadRecord(content,target,heading,fName);
        Test.stopTest();
    }
}
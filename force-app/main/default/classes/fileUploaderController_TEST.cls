@isTest
private class fileUploaderController_TEST {
    static List<String> heading=new List<String>();
    static List<String> content=new List<String>();
    static String target;
    static String bKey;

    private static void prepareTestData() {
        target='Account';
        
        heading.add('Name');
        heading.add('AccountNumber');
        heading.add('AnnualRevenue');

        content.add('Test0001,0001,100');
        content.add('Test0002,0001,abc');

        bKey='Test';
    }

    private static testMethod void testUpload(){
            Test.startTest();
            prepareTestData();
            fileUploaderController.getObj();
            fileUploaderController.getFields(target);
            fileUploaderController.startUploadData(heading, target, content, bKey);
            Test.stopTest();
    }
}
global class batch2 implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([Select Id,Name From Account]);
    }
    global void execute(Database.BatchableContext bc, List<Account> A){
        // process each batch of records
        List<String>emailList=new List<String>();
        List<Messaging.SingleEmailMessage>emailMsgList=new List<Messaging.SingleEmailMessage>();
        emailList.add('kelvin.tam@introv.com');
        Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
        Emailmessage.toaddresses =emailList;
        Emailmessage.subject='Batch 2 Email Test';
        String Message = 'Batch 2 Email Test Message Body<br/>';
        Emailmessage.setHtmlBody(Message);
        emailMsgList.add(Emailmessage);
        Messaging.sendEmail(emailMsgList);
		system.debug('Email is sent Successfully.');

    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}
global class batch1 implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([Select Id,Name From Account]);
    }
    global void execute(Database.BatchableContext bc, List<Account> A){
        // process each batch of records
        for(Account acc: A){
            acc.test__c='A';
        }
        Database.update(A, false);

    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}
public with sharing class TestController {

public Account objAccount {get;set;}

public List<account> accountList{get;set;}

public List<contact> contactList{get;set;}

public TestController (){

accountList = [select Name,Id,AccountNumber,Industry,Phone from Account LIMIT 10];

}

public Pagereference exportAll(){

return new Pagereference('/apex/ExportAll');

}

}
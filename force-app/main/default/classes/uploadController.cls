public with sharing class uploadController {
    @AuraEnabled
    public static Integer allUpload(list<list<string>> input,list<list<string>> headings,list<string> sheet,String obj){
        System.debug(input);
        System.debug(headings);
        System.debug(sheet);
        System.debug(obj);
        integer i=0;
        Integer err=0;
        for(i=0;i<sheet.size();i++){
            err=+uploadRecord(input[i],obj,headings[i],sheet[i]);
        }
        
        Return err;
    }

    @AuraEnabled
    public static Integer uploadRecord(list<string> input,String obj,list<string> heading,String sheetName){
        System.debug(input);
        System.debug(heading);
        Map<String, Schema.SObjectType> gobDescribe= Schema.getGlobalDescribe();
        Set<String> objectKeys = gobDescribe.keySet();
        integer erCount=0;
          

        if (objectKeys.contains(obj.toLowerCase())) {
       
                
                List<sObject> sObjs= new List<sObject>();
                Schema.SObjectType soType = gobDescribe.get(obj); 
                System.debug(soType);
                Map<String, Schema.SobjectField> fmap = soType.getDescribe().fields.getMap();
                Map<Integer,String> fldErrList=new Map<Integer,String>();
                Integer idx=0;

                for (String  a: input) {
                    System.debug(a);
                    sObject sObj = Schema.getGlobalDescribe().get(obj).newSObject();
                    System.debug(sObj);
                    List<String> fValue=a.split(',');
                    Boolean errFlag=false;
                    Integer i=0;
                    String errMeg='';

                    for (string b : heading) {
                        System.debug(b);
                        
                        if (fValue.size()>i) {
                            Schema.SObjectField field = fmap.get(b);
                            Schema.DisplayType FldType = field.getDescribe().getType();
                            System.debug(FldType);
                            try {
                                 if (FldType ==Schema.DisplayType.DOUBLE) {
                                    sObj.put(b,Double.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.BOOLEAN) {
                                    sObj.put(b,Boolean.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.DATE) {
                                    sObj.put(b,Date.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.CURRENCY ||FldType ==Schema.DisplayType.PERCENT) {
                                    sObj.put(b,Decimal.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.DATETIME) {
                                    sObj.put(b,Datetime.valueOf(fValue[i]));   
                                }
                                else if (FldType ==Schema.DisplayType.ID) {
                                    sObj.put(b,Id.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.INTEGER) {
                                    sObj.put(b,Integer.valueOf(fValue[i]));
                                }
                                else if (FldType ==Schema.DisplayType.LONG) {
                                    sObj.put(b,Long.valueOf(fValue[i]));
                                }
                                else {
                                    sObj.put(b,fValue[i]); // String case
                                }
                            } catch (Exception er){
                                System.debug(er);
                                errMeg+=er.getMessage()+' '+b+';';
                                errFlag=true;
                            }
                               
                        }
        
                        i++;

                    }
                    
                    if (!errFlag) {
                        sObjs.add(sObj);
                    }
                    else {
                        fldErrList.put(idx, errMeg);
                    }
                    
                    idx++;
                }
                
            System.debug(fldErrList);
            Database.SaveResult[] lsr =Database.insert(sObjs,false);
            
            
            erCount=saveResult(lsr,heading,input,fldErrList,sheetName);
            
        }
        return erCount;
    }

    public static Integer saveResult(Database.SaveResult[] results,List<String> headings,List<String> content,Map<Integer,String> errList,String fileNmae){
        String csv ='id,Result,Error';
        Integer errCount=0;
        for (string fieldName : headings) {
            csv+=','+fieldName;
        }
        csv+='\n';
        Record__c r =new Record__c();
        Integer idx=0;
        Integer rIdx=0;
        Integer eIdx=0;
        List<Integer> errLine=new List<Integer>(errList.keySet());
        for (string line : content) {
            
            if (errLine.size()>eIdx) {
                if (errLine[eIdx]==idx) {
                    csv+='null,False,'+errList.get(idx)+',';
                    eIdx++;
                    errCount++;
                }
                else {
                    if (results.size()>rIdx) {
                    csv+=results[rIdx].getId()+','+results[rIdx].isSuccess()+','+results[rIdx].getErrors()+',';
                    if (!results[rIdx].isSuccess()) {
                        errCount++;
                    }
                    
                    rIdx++;
                    }
                }
                
            }
            else {
                if (results.size()>rIdx) {
                csv+=results[rIdx].getId()+','+results[rIdx].isSuccess()+','+results[rIdx].getErrors()+',';
                if (!results[rIdx].isSuccess()) {
                        errCount++;
                }
                rIdx++;

                }
            }
            csv+=line+'\n';
            idx++;
        }
        System.debug(errCount);
        insert r;

        ContentVersion file = new ContentVersion(
            ContentLocation = 'S',
            FirstPublishLocationId = r.id,
            versionData = Blob.valueOf( csv ),
            title = 'Upload Result_'+Date.Today().format()+'_'+fileNmae,
            pathOnClient = 'Upload Result'+Date.Today().format()+'.csv'
            );
            
            
        insert file;
        return errCount;
    }

    public static void changeValueType(){

    }
}
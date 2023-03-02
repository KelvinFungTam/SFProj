public with sharing class fileUploaderController {
    @AuraEnabled
    public static List<EntityDefinition> getObj(){
        List<searchableObj__mdt> mcs = [SELECT MasterLabel,value__c,Disable__c FROM searchableObj__mdt where Disable__c=false];
        system.debug(mcs);
        List<String> apiNames = new List<String>();
        for (searchableObj__mdt mc : mcs) {
            apiNames.add(mc.value__c);
        }
        List<EntityDefinition> allObj =new List<EntityDefinition>([SELECT QualifiedApiName,Label FROM EntityDefinition Where QualifiedApiName in:apiNames ORDER BY Label]);
        system.debug('gogogo');
        system.debug(allObj);
        return allObj;
    }

    @AuraEnabled
    public static List<FieldDefinition> getFields(string objectName){
        List<FieldDefinition> objectFields = new List<FieldDefinition>([select QualifiedApiName, Label from FieldDefinition where EntityDefinition.QualifiedApiName =:objectName ORDER BY Label]);
        return objectFields; 
    }

    @AuraEnabled
    public static Integer startUploadData(List<string> heading, string tarObj,List<string> recordValue,string bKey){
        System.debug('Entered');
        Integer  a = recordValue.size();
        System.debug(heading);
        System.debug(recordValue.size());
        System.debug(tarObj);
        System.debug(recordValue);
        System.debug(bKey);
        Map<String, Schema.SObjectType> gobDescribe= Schema.getGlobalDescribe();
        Set<String> objectKeys = gobDescribe.keySet();

        if (objectKeys.contains(tarObj.toLowerCase())) {
            List<sObject> sObjs= new List<sObject>();
            Schema.SObjectType soType = gobDescribe.get(tarObj);

            Map<String, Schema.SobjectField> fmap = soType.getDescribe().fields.getMap();//get field name
            Map<Integer,String> fldErrList = new Map<Integer,String>(); 
            for (String  rd: recordValue) {
                sObject sObj = Schema.getGlobalDescribe().get(tarObj).newSObject();
                List<String> fValue = rd.split(',');

                Boolean errFlag=false;
                Integer i=0;
                String errMeg='';

                for (string col : heading) {
                    //System.debug(col);
                    
                    if (fValue.size()>i) {
                        Schema.SObjectField field = fmap.get(col);
                        Schema.DisplayType FldType = field.getDescribe().getType();
                        //System.debug(FldType);
                        try {
                            if (FldType ==Schema.DisplayType.DOUBLE) {
                                sObj.put(col,Double.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.BOOLEAN) {
                                sObj.put(col,Boolean.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.DATE) {
                                sObj.put(col,Date.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.CURRENCY ||FldType ==Schema.DisplayType.PERCENT) {
                                sObj.put(col,Decimal.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.DATETIME) {
                                sObj.put(col,Datetime.valueOf(fValue[i]));   
                            }
                            else if (FldType ==Schema.DisplayType.ID) {
                                sObj.put(col,Id.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.INTEGER) {
                                sObj.put(col,Integer.valueOf(fValue[i]));
                            }
                            else if (FldType ==Schema.DisplayType.LONG) {
                                sObj.put(col,Long.valueOf(fValue[i]));
                            }
                            else {
                                sObj.put(col,fValue[i]); // String case
                            }
                        } catch (Exception er){
                            //System.debug(er);
                            errMeg+=er.getMessage()+' '+col+';';
                            errFlag=true;
                        }
                        
                    }
                    
                    i++;

                }
                if (!errFlag) {
                    sObjs.add(sObj);
                }
                else {
                    fldErrList.put(1, errMeg);
                }
            }
            System.debug('Error List');
            System.debug(fldErrList);

            Database.SaveResult[] lsr =Database.insert(sObjs,false);
        }


        return a;
    }
}
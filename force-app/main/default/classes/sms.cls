public class sms {
    public static String send(String content) {
        
        // Instantiate a new http object
        Http h = new Http();
        
        String encodedString = EncodingUtil.urlEncode(content,'UTF-8');
        //String url ='https://sms.emma.hk/sms/APIServiceMulti?sendrequest=';
        String url ='https://mms.emma.hk/mms/MMSAPI';
        String para ='sendrequest=';
        para+='%3C%3Fxml+version%3D%221.0%22+encoding%3D%22UTF-8%22%3F%3E%3Csendrequest%3E%3Ccorrelationid%3E123%3C%2Fcorrelationid%3E%3Cusername%3Efrieslandcampina-mms-api%3C%2Fusername%3E%3Cpassword%3Efmms%406151%3C%2Fpassword%3E%3Cphonenumbers%3E%2B85261873324%3C%2Fphonenumbers%3E%3Cscheduledatetime%3E%3C%2Fscheduledatetime%3E%3Cstarttime%3E0%3C%2Fstarttime%3E%3Cendtime%3E24%3C%2Fendtime%3E%3Csubject%3E%3C%21%5BCDATA%5BMMS+Subject%5D%5D%3E%3C%2Fsubject%3E%3Ccampaignname%3E%3C%21%5BCDATA%5BCampaign+name%5D%5D%3E%3C%2Fcampaignname%3E%3Csenderid%3E%3C%21%5BCDATA%5B12585018101%5D%5D%3E%3C%2Fsenderid%3E%3Cfiles%3E%3Cfile%3E%3Cname%3E%3C%21%5BCDATA%5Bsmil.smil%5D%5D%3E%3C%2Fname%3E%3Ccontent%3E3c736d696c3e0a20203c686561643e0a202020203c6c61796f75743e0a2020202020203c726f6f742d6c61796f75742077696474683d2232323022206865696768743d22313630222f3e0a2020202020203c726567696f6e2069643d22696d6167652220746f703d223022206c6566743d223022206865696768743d22353025222077696474683d22383025222f3e0a2020202020203c726567696f6e2069643d22746578742220746f703d2235302522206c6566743d223022206865696768743d22353025222077696474683d22383025222f3e0a202020203c2f6c61796f75743e0a20203c2f686561643e0a20203c626f64793e0a202020203c7061723e0a20202020203c696d67207372633d2264656d6f2e6a70672220726567696f6e3d22696d616765223e3c2f696d673e0a20202020203c74657874207372633d22312e7478742220726567696f6e3d2274657874222f3e0a202020203c2f7061723e0a20203c2f626f64793e0a3c2f736d696c3e0a%3C%2Fcontent%3E%3C%2Ffile%3E%3Cfile%3E%3Cname%3E%3C%21%5BCDATA%5Bdemo.jpg%5D%5D%3E%3C%2Fname%3E%3Ccontent%3E';
        ContentVersion cv= [SELECT Title,VersionData FROM ContentVersion WHERE ContentDocumentId = '0690o00000ECK4jAAH' AND IsLatest = true];
        
        
        
        system.debug(cv);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://testcustomtest-dev-ed.my.salesforce.com/services/data/v48.0/sobjects/ContentVersion/0680o00000FEO0JAAX/VersionData');
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = h.send(req);
        
        system.debug(res.getBody());
        //String img= res.getBodyAsBlob();
        String heximg = EncodingUtil.convertToHex(res.getBodyAsBlob());
        system.debug(heximg);
       
	        
        para+=heximg;
        para+='%3C%2Fcontent%3E%3C%2Ffile%3E%3Cfile%3E%3Cname%3E%3C%21%5BCDATA%5B1.txt%5D%5D%3E%3C%2Fname%3E%3Ccontent%3E54657374204d4d532e20e6b58be8af95%3C%2Fcontent%3E%3C%2Ffile%3E%3C%2Ffiles%3E%3C%2Fsendrequest%3E%0D%0A';
        /*url+='%3C%3Fxml+version%3D%221.0%22+encoding%3D%22UTF-8%22%3F%3E%3Csendrequest%3E%3Ccorrelationid%3E123%3C%2Fcorrelationid%3E%3Cusername%3Efrieslandcampina-friso-promote%3C%2Fusername%3E%3Cpassword%3Effp%401651%3C%2Fpassword%3E%3Cmessages%3E%3Cmessage%3E%3Cscheduledatetime%3E%3C%2Fscheduledatetime%3E%3Cphonenumbers%3E%2B85261873324%3C%2Fphonenumbers%3E%3Ccontent%3E';
url+=encodedString;
url+='%3C%2Fcontent%3E%3Csenderid%3EABC+Company%3C%2Fsenderid%3E%3C%2Fmessage%3E%3C%2Fmessages%3E%3C%2Fsendrequest%3E';*/
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        
        HttpRequest req2 = new HttpRequest();
        req2.setTimeout(120000);
        req2.setEndpoint(url);
        req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req2.setMethod('POST');
        req2.setBody(para);
        
        // Send the request, and return a response
        HttpResponse res2 = h.send(req2);
        Dom.Document doc = res2.getBodyDocument();
        Dom.XMLNode sendresponse = doc.getRootElement();
        
        String correlationid = sendresponse.getChildElement('correlationid', null).getText();
        String batchid = sendresponse.getChildElement('batchid', null).getText();
        String statuscode = sendresponse.getChildElement('statuscode', null).getText();
        String reason = sendresponse.getChildElement('reason', null).getText();
        String submitdatetime = sendresponse.getChildElement('submitdatetime', null).getText();
        
        system.debug('correlationid:'+correlationid);
        system.debug('batchid:'+batchid);
        system.debug('statuscode:'+statuscode);
        system.debug('reason:'+reason);
        system.debug('submitdatetime:'+submitdatetime);
        
        return res2.getBody();
    }
    
}
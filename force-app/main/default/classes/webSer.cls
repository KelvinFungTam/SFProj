@RestResource(urlMapping='/Cases/*')
global with sharing class webSer {
    
    global class reImage{
        global Blob image;
    }
    
    @HttpPost
    global static boolean createCase(){
        system.debug('123');
        system.debug(RestContext.request.requestBody);
        reImage re= (reImage) JSON.deserialize(RestContext.request.requestBody.toString(),reImage.class);
        system.debug('Connected');
        case ca=new case(subject='image test',status='New',origin='Phone',priority='Low');
        insert ca;
       
        Attachment file = new Attachment(
            ParentId = ca.id,
            body =  re.image,
            ContentType='image/jpeg',
            Name = 'Upload Result'+Date.Today().format()+'.jpeg'
            );
            
            
            
        insert file;
      	return true;
    }
}
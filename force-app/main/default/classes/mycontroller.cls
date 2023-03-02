public class mycontroller {
	public String myString; 
    
    public String getMyString() {
        return 'getnyString'; 
    }
    
    public String getStringMethodl(){
        return myString; 
    }
    
    public String getStringMethod2(){
        if (myString ==null){
            myString='method2';
        }
        return myString;
    }
}
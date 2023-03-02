import { LightningElement,wire,track } from 'lwc';
import { loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import jszip from '@salesforce/resourceUrl/zip';
import jsxlsx from '@salesforce/resourceUrl/jsxlsx';
import getObj from '@salesforce/apex/fileUploaderController.getObj';
import getFields from '@salesforce/apex/fileUploaderController.getFields';
import startUploadData from '@salesforce/apex/fileUploaderController.startUploadData';


export default class Fileuploader extends LightningElement {
    @track options;
    @track fields;
    @track fileName;
    @track buttonDis;
    @track targetDis;
    @track fieldDis;
    @track errmsg;
    @track inputDis;
    @track showLoadingSpinner;
    @track fieldAPI;
    @track value ;
    @track headings;
    @track targetObj;
    @track complete;
    @track total;

    stopFlag;
    filesUploaded = [];
    file;
    fileReader;
    workbook;
    MAX_FILE_SIZE = 15000000;
    sheet_name_list;
    binary;
    bytes;
    length;
    @track table;
    content;
    options = [{ label: 'Hi', value: 'Hi' }];
    ext;
    fieldMap;

    connectedCallback() {
        var optionlist=[];
        this.fieldMap = {};
        this.fieldAPI = '';
        this.value = null;
        this.errmsg = 'Please select upload file.'
        this.fileName = 'You have not selected a file yet.';
        this.buttonDis = true;
        this.targetDis = true;
        this.inputDis = false;
        this.fieldDis = true;
        this.headings = [];
        this.targetObj ='';
        this.showLoadingSpinner = false;
        this.stopFlag = false;
        this.complete = '';
        this.total = '';
        this.table = [];

        getObj().then(objL=>{
            console.log("result");
            console.log(objL);
            for(var i=0;i<objL.length;i++){
                var option={};
                option['label']=objL[i]['Label'];
                option['value']=objL[i]['QualifiedApiName'];
                optionlist[i]=option;
            }
            this.options=optionlist;
        }

        ).catch(
            err=>{
                console.log(err);
            }
            
        );

        Promise.all([
            loadScript(this, jsxlsx),
            loadScript(this, jszip)
        ])
            .then(() => {

                console.log('Loaded');
                console.log(XLSX.version);
            })
            .catch(error => {
                console.log('Load fail');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Lib',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.ext = this.fileName.split('.').pop();
            this.value = this.ext;
            switch (this.ext.toLowerCase()) {
                case 'csv':
                case 'xlsx':
                    this.buttonDis=false;
                    this.errmsg='';
                    console.log(this.errmsg);
                    break;
                default:
                    this.errmsg='Please upload csv or xlsx format file!';
                    console.log(this.errmsg);
                    this.buttonDis = true;

            }
        }
    }

    handleUpload(){
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            this.errmsg='File Size is to long';
            return ;
        }
        console.log('Start Upload');
        this.inputDis = true;
        this.buttonDis = true;
        
        this.showLoadingSpinner=true;

        this.fileReader= new FileReader();

        this.fileReader.onloadend = (()=> { 
            this.binary = "";
            this.bytes = new Uint8Array(this.fileReader.result);
            this.length = this.bytes.byteLength;

            for (this.i = 0; this.i < this.length; this.i++) {
                this.binary += String.fromCharCode(this.bytes[this.i]);
            } 

            this.workbook = XLSX.read(this.binary, { type: 'binary' }); 
            this.sheet_name_list = this.workbook.SheetNames;

            //console.log(this.workbook);
            console.log(this.sheet_name_list);
            this.showLoadingSpinner=false;

            this.table=XLSX.utils.sheet_to_json(this.workbook.Sheets[this.sheet_name_list[0]]);
            this.errmsg='It has ' + this.table.length + ' records found.';
            this.total = this.table.length;
            this.headings = [];

            console.log(this.table);
        });
        this.fileReader.readAsArrayBuffer(this.file);
        this.filesUploaded = ''; 
        this.targetDis = false;
        
    }

    updateFields(event) {
        this.fields = [];
        this.fieldAPI = '';
        this.fieldMap = {};
        this.targetObj = event.detail.value;
        this.headings = [];

        this.showLoadingSpinner=true;
        var timeoutID = window.setTimeout(()=>(
            getFields({objectName:this.targetObj}).then(fL=>{
                console.log("Field result");
                console.log(fL);
                var fieldList=[];
                for(var i=0;i<fL.length;i++){
                    var option={};
                    option['label']=fL[i]['Label'];
                    option['value']=fL[i]['QualifiedApiName'];
                    fieldList[i]=option;
                }
                this.fields = fieldList;
                this.fields.push({label:'-Not Used Colume-',value:null});
                switch(this.targetObj.toLowerCase()){
                    case 'contact':
                        this.fields.push({label:'First Name',value:'firstName'});
                        break;
                    case 'account':
                        break;

                }
                this.fields.sort(this.SortByLabel);
                var cL =[];
                for(var x in this.table[0]){
                    this.headings.push(x);
                }
                console.log(this.columns);
                console.log(this.keyF);
                console.log(this.rtable);
                console.log(this.headings.toString());

                this.fieldDis = false;
                this.showLoadingSpinner=false;
            }

            ).catch(
                err=>{
                    console.log(err);
                }
            
        )),1000);
    }

    updateMap(event) {
        var inputFlag = true;
        for(var item in this.fieldMap){
            if(this.fieldMap[item] == event.target.value && item != event.target.name && event.target.value!=null){
                event.target.value = this.fieldMap[event.target.name];
                alert('duplicated');
                inputFlag = false
            }
        }
        
        if(inputFlag){
            const colName = event.target.name;
            this.fieldMap[colName] = event.target.value;
        }
        console.log(this.fieldMap);
    }

    handleImport() {
        this.showLoadingSpinner=true;
        var headingList = [];
        var valueList =[];
        var batchList = [];
        var batchKey = this.makeid(30);
        this.complete = 0;
        
        for(var z in this.fieldMap){
            if(this.fieldMap[z]!=null){
                headingList.push(this.fieldMap[z]);
            }
        }

        if(headingList.length<=0){
            alert('Mapping cannot be blank!');
            this.showLoadingSpinner=false;
            return;
        }

        console.log(headingList);
        var recordCount =1;
        for(var x in this.table){
            var inputStr = '';
            for(var y in this.fieldMap){
                if(this.fieldMap[y] != null){
                    inputStr = inputStr + this.table[x][y] + ',';
                }

            }

            valueList.push(inputStr.slice(0,-1));
            if(recordCount%200 ==0){
                batchList.push(valueList);
                valueList=[];
            }
            recordCount++;
        }

        if(valueList.length>0){batchList.push(valueList);}

        var timercount=0;
        this.uploadDelay(timercount,batchList,headingList,batchKey);
    }

    uploadDelay(count,list,hList,bKey){
        console.log('called');
        console.log(list[count]);
        var listInput = list[count];
        try{
        startUploadData(
            {
                heading:hList,
                recordValue:listInput,
                tarObj:this.targetObj,
                bKey:bKey
            }
        ).then(
            re=>{
                console.log('Done');
                this.complete= this.complete + re;
                if(this.complete == this.total){
                    this.showLoadingSpinner=false;
                    this.fieldDis = true;
                    this.targetDis = true;
                }
                count++;
                if(count<list.length){
                    this.uploadDelay(count,list,hList,bKey);
                }
            }
        ).catch(
            err=>{
                console.log(err);
                this.showLoadingSpinner=false;
            }
        );
        }
        catch(e){
            console.log(e);
        }

    }

    SortByLabel(x,y) {
        return ((x.label == y.label) ? 0 : ((x.label > y.label) ? 1 : -1 ));
      }

    makeid(length) {
        var result           = '';
        var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
           result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
     }
}
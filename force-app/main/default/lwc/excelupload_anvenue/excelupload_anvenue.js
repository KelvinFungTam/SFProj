import { LightningElement, track} from 'lwc';
import { loadScript} from 'lightning/platformResourceLoader';
import jszip from '@salesforce/resourceUrl/zip';
import jsxlsx from '@salesforce/resourceUrl/jsxlsx';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import uploadRecord from '@salesforce/apex/uploadController.uploadRecord'
import allUpload from '@salesforce/apex/uploadController.allUpload'



export default class Uploadxlsx extends LightningElement {
    @track fileName = '';
    @track showLoadingSpinner = false;
    filesUploaded = [];
    file;
    fileReader;
    workbook;
    MAX_FILE_SIZE = 15000000;
    sheet_name_list;
    binary;
    bytes;
    length;
    csvTable;
    headings;
    content;



    connectedCallback() {
        //console.log(TRADE_OBJECT);
        //console.log(JSON.stringify(this.objectInfo.data));
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
        }
    }

    renderedCallback() {
        
    }

    handleSave() {

        if(this.filesUploaded.length > 0) {
            this.count=0;
            this.total=0;
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }

    uploadHelper() {

        this.totalerr=0;
        this.file = this.filesUploaded[0];
       if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            return ;
        }

        this.showLoadingSpinner = true;
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
            this.totalerr=0;

            this.inputlist=[];
            this.allHeadings=[];

            for(this.j=0;this.j<this.sheet_name_list.length;this.j++){
                this.csvTable=XLSX.utils.sheet_to_csv(this.workbook.Sheets[this.sheet_name_list[this.j]]);
                this.content=this.csvTable.split("\n");
                this.headings=this.content[0].split(',');
                console.log(this.headings);
                this.content.shift();
                this.content.pop();
                for(this.k=this.content.length;this.k>0;this.k--){
                    if(this.content[this.k]===",,,,,,,,,,,"){
                        this.content.pop();
                    }
                }
                this.inputlist.push(this.content);
                this.allHeadings.push(this.headings);
                console.log(this.content.length)
                console.log(this.content);
            
                console.log('===')
                console.log(this.inputlist);
                console.log(this.allHeadings);
                /*uploadRecord({input:this.content,obj:'Trade__c',heading:this.headings,sheetName:this.sheet_name_list[this.j]}).then( (eNum)=>{

                    this.totalerr=+eNum;
                    console.log(eNum,this.totalerr)
                    this.fileName ='Update Finished. '+this.totalerr.toString()+' case is fail.';
                    this.showLoadingSpinner = false;
                    console.log('ing')
                }

                ).catch(err=>{
                    console.log(err);
                    this.fileName ='Update Fail. Please contact support';
                    this.showLoadingSpinner = false;
                });*/
            }
            allUpload({input:this.inputlist,headings:this.allHeadings,sheet:this.sheet_name_list,obj:'Trade__c'}).then(eNum=>{
                this.fileName ='Update Finished. '+eNum+' case is fail.';
                this.showLoadingSpinner = false;

             }).catch(err=>{
                console.log(err);
                this.fileName ='Update Fail. Please contact support';
                this.showLoadingSpinner = false;
            });
        });
        
        this.fileReader.readAsArrayBuffer(this.file);
        this.filesUploaded=''; //clear file
        
        
    }
        

    isNumeric(n) {
            return typeof(n)=="number";
      }
    

}
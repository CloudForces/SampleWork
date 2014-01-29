/*************************************************
Apex Class : ForecastCtrl
Description : This controller for 
    Forecasting custom Visual Force pages 
        
**************************************************/
public with sharing class ForecastCtrl {
    
    public String recordId {get;set;}
    public String choice {get;set;}
    public String errMsg{get;set;}
    public Boolean isErr{get;set;}
    public Boolean isManager{get;set;}
    public Boolean showTeamSummary{get;set;}
    public String approvalComments{get;set;} 
    public PageReference pageRef {get;set;}
    public Boolean isSelectForecastSubmitted {get;set;}
    public Boolean checkingTeamRecords {get;set;}
    public TeamTotals summary {get;set;}
    public class forecastException extends Exception {}
    public Forecast__c selectedForecast {get;set;}
    public List<Forecast_Detail__c> pendingFDList {get;set;}
    public List<Forecast_Detail__c> personalFDList {get;set;}
    public List<Forecast_Detail__c> workingList {get;set;}
    public List<Forecast_Detail__c> recordList{get;set;}
    public List<Forecast__c> recSumList {get;set;}
    public List<Forecast__c> sumPersList {get;set;}
    public List<Forecast__c> sumPendingList {get;set;}
    public String pId {get;set;}
    public Map<String, SalesRep> teamMap{get;set;}
    
    
    public ForecastCtrl(ApexPages.StandardController stdController){
        selectedForecast = (Forecast__c)stdController.getRecord();
        init();
    }
    
    public ForecastCtrl(){
        init();
    }
    
    public void isValid(){
        
        for(Forecast_Detail__c f:workingList){
        		if( String.valueOf(f.month6_forecast__c) == null || String.valueOf(f.month6_forecast__c) == ''){ f.month6_forecast__c = 0.0; }
                if( String.valueOf(f.month5_forecast__c) == null || String.valueOf(f.month5_forecast__c) == ''){ f.month5_forecast__c = 0.0; }
                if( String.valueOf(f.month4_forecast__c) == null || String.valueOf(f.month4_forecast__c) == ''){ f.month4_forecast__c = 0.0; }
                if( String.valueOf(f.month3_forecast__c) == null || String.valueOf(f.month3_forecast__c) == ''){ f.month3_forecast__c = 0.0; }
                if( String.valueOf(f.month2_forecast__c) == null || String.valueOf(f.month2_forecast__c) == ''){ f.month2_forecast__c = 0.0; }
                if( String.valueOf(f.month1_forecast__c) == null || String.valueOf(f.month1_forecast__c) == ''){ f.month1_forecast__c = 0.0; }
                if(  (f.month6_forecast__c + f.month5_forecast__c + f.month4_forecast__c + f.month3_forecast__c 
                        + f.month2_forecast__c + f.month1_forecast__c) > f.Budget__c ){
	                errMsg = 'Some of the opportunities have forecasts greater than budget. ';
	                isErr = true;
	                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errMsg));
	                return;	
        		}
    	}
    }

    private void loadPending(){
        Set<String> idChk = new Set<String>();
        Set<Id> fIDSet = new Set<Id>();
        recordList = [SELECT 
                            f.iAd_Type__c, f.StageName__c, f.Split_Percent__c, f.Quarter2_code__c, f.Quarter2_Forecast__c, f.Quarter2_Budget__c, f.Quarter1_code__c, 
                            f.Quarter1_Forecast__c, f.Quarter1_Budget__c, f.Month6_Forecast__c, f.Month6_Code__c, f.Month6_Budget__c, f.Month5_Forecast__c, 
                            f.Month5_Code__c, f.Month5_Budget__c, f.Month4_Forecast__c, f.Month4_Code__c, f.Month4_Budget__c, f.Month3_Forecast__c, f.Month3_Code__c, 
                            f.Month3_Budget__c, f.Month2_Forecast__c, f.Month2_Code__c, f.Month2_Budget__c, f.Month1_code__c, f.Month1_Forecast__c, f.Month1_Budget__c, 
                            f.Id, f.Forecast__r.Quarter2_code__c, f.Forecast__r.Quarter1_code__c, f.Forecast__r.RUS_quarter2_forecast__c, f.Forecast__r.RUS_quarter1_forecast__c, 
                            f.Forecast__r.RUS_month6_forecast__c, f.Forecast__r.RUS_month5_forecast__c, f.Forecast__r.RUS_month4_forecast__c, f.Forecast__r.RUS_month3_forecast__c, 
                            f.Forecast__r.RUS_month2_forecast__c, f.Forecast__r.RUS_month1_forecast__c, f.Forecast__r.Submitted__c, f.Forecast__r.Submit_Date__c, 
                            f.Forecast__r.Sales_Rep__c, f.Forecast__r.Month6_Code__c, f.Forecast__r.Month5_Code__c, f.Forecast__r.Month4_Code__c, 
                            f.Forecast__r.Month3_Code__c, f.Forecast__r.Month2_Code__c, f.Forecast__r.Month1_Code__c, f.Forecast__r.Entry_Period__c, 
                            f.Forecast__r.Comments__c, f.Forecast__r.Approver__c, f.Forecast__r.Approved__c, f.Forecast__r.Approval_Date__c, f.Forecast__r.Id, f.Forecast__c, 
                            f.Comments__c, f.Budget__c, f.Advertiser__c, f.Advertiser__r.Name, f.Opportunity__c, f.Opportunity__r.Id, f.Opportunity__r.Name, f.Forecast__r.Sales_Rep__r.ManagerId, 
                            f.Forecast__r.Approver__r.Id, f.Forecast__r.Sales_Rep__r.Name 
                        FROM Forecast_Detail__c f
                        WHERE ( f.Forecast__r.Approver__r.Id =: UserInfo.getUserId() 
                            or f.Forecast__r.Sales_Rep__r.ManagerId =: UserInfo.getUserId() 
                            or f.Forecast__r.Sales_Rep__c =: UserInfo.getUserId() ) 
                        ORDER BY f.Advertiser__r.Name,  f.Opportunity__r.Name ASC ]; 
        
        recSumList = [SELECT f.Submitted__c, f.Sales_Rep__c, f.Reject_Date__c, f.RUS_quarter2_forecast__c, f.RUS_quarter1_forecast__c, f.RUS_month6_forecast__c, 
                                        f.RUS_month5_forecast__c, f.RUS_month4_forecast__c, f.RUS_month3_forecast__c, f.RUS_month2_forecast__c, f.RUS_month1_forecast__c, f.Quarter2_code__c, 
                                        f.Quarter1_code__c, f.Month6_Code__c, f.Month5_Code__c, f.Month4_Code__c, f.Month3_Code__c, f.Month2_Code__c, f.Month1_Code__c, f.Id, f.Entry_Period__c, 
                                        f.Comments__c, f.Approver__c, f.Approved__c, f.Approval_Date__c, f.Sales_Rep__r.ManagerId, f.Approver__r.Id, f.Sales_Rep__r.Name, f.Submit_Date__c
                                FROM Forecast__c f
                                WHERE ( (f.Sales_Rep__r.ManagerId =: UserInfo.getUserId()  OR f.Approver__r.Id =: UserInfo.getUserId()) AND f.Submitted__c = true )
                                                OR f.Sales_Rep__c =: UserInfo.getUserId() 
                                        ORDER BY f.Entry_Period__c, f.Sales_Rep__r.Name DESC ];
        List<Id> recList = new List<Id>();
        /*
        for(Forecast__c ss: recSumList){
        	recList.add(ss.Id);
        	if(!String.isBlank(String.valueOf(ss.Comments__c))){
	        	while( ss.Comments__c.contains('null')){
					Integer posF = 0;
					if(  ss.Comments__c.contains('null.') ){
						posF = ss.Comments__c.indexOf('null.');
						ss.Comments__c = ss.Comments__c.substring(posF+5);
					}else{
						posF = ss.Comments__c.indexOf('null');
						ss.Comments__c = ss.Comments__c.substring(posF+4);
					}
				}
        	}
        }
        */
        
        for(Forecast__c smp: recSumList){
        	if( smp.Sales_Rep__c == UserInfo.getUserId()){
            	sumPersList.add(smp);
            }else{
            	isManager = true;
            	for(Forecast__c r: recSumList){  
                    if(r.Sales_Rep__r.Id == smp.Sales_Rep__r.Id){
                    	sumPendingList.add(r);
                    } 
                }
                if(sumPendingList.size() > 0){ 
                	if(!idChk.contains(String.valueOf(smp.Id)))
                        {   teamMap.put(smp.Sales_Rep__r.Name, new SalesRep(smp.Id, smp.Sales_Rep__r.Name, sumPendingList)); } 
                	idChk.add(smp.Id);
            	}
            	sumPendingList.clear();
            }
           recList.add(smp.Id);
        }
        getApprovalComments(recList);
        
        if(isManager){
        	showTeamSummary = true;
        	choice = 'Team Forecasts';
        }else{ 
        	showTeamSummary = false;
        	choice = 'My Forecasts'; 
    	}
        for(Forecast_Detail__c fd: recordList){
            if(UserInfo.getUserId() == fd.Forecast__r.Approver__r.Id || UserInfo.getUserId() == fd.Forecast__r.Sales_Rep__r.ManagerId){ 
                if(fd.Forecast__r.Submitted__c && !fd.Forecast__r.Approved__c){
                    pendingFDList.add(fd);
                }     
            }
            if( UserInfo.getUserId() == fd.Forecast__r.Sales_Rep__c){  personalFDList.add(fd);  }
        }
    }
    
    //Updates the List of Forecasts with Approval Comments, if any
	private void getApprovalComments(List<Id> recs){
		try{
        	Map<Id, String> retMap = new Map<Id, String>();
	        Map<ID,ID> objPidMap = new Map<Id,Id>();
	        List<ProcessInstance> pInstanceList = [Select p.TargetObjectId, p.Status, p.Id From ProcessInstance p Where p.TargetObjectId IN: recs];
	        
	        for(ProcessInstance p: pInstanceList){
	        	objPidMap.put(p.TargetObjectId, p.Id);
	        	system.debug( ' p.TargetObjectId ' + p.TargetObjectId + '  p.Status ' + p.Status+ ' p.Id ' + p.Id);
	        }
	        
	        List<ProcessInstanceStep> pStepList = [Select p.StepStatus, p.ProcessInstanceId, p.OriginalActorId, p.CreatedDate, p.Comments 
	        				From ProcessInstanceStep p Where p.Id IN: objPidMap.values()];
	        for(ProcessInstanceStep iT: pStepList){
	        	system.debug( 'ProcessInstanceStep.Comments ' + iT.Comments);
	        	for(ProcessInstance pmp: pInstanceList){
	        		if(iT.ProcessInstanceId == pmp.Id && iT.StepStatus == pmp.Status){
	        			if(!String.isBlank(iT.Comments)) { 
	        				String str = iT.Comments;
	        				retMap.put(pmp.TargetObjectId, String.valueOf(iT.Comments)); 
        				}
	        		}
	        	}
	        }
	        for(Forecast__c fc: recSumList){ 
	        	String temp = String.valueOf( retMap.get(fc.Id)+'. ' +fc.Comments__c ) ;
	        	if(temp.length() > 255){
	        		temp = temp.substring(0, 254);
	        	}
	        	//temp.replaceAll('null.', '');
	        	//temp.replaceAll('null', '');
	        	fc.Comments__c = temp; 
        	}
        }catch(Exception ex){
        	ApexPages.addMessages(ex);
        } 
	    
    }
    
    private void clear(){
            pendingFDList.clear();
            personalFDList.clear();
            workingList.clear();
            recordList.clear();
            teamMap.clear();
            recSumList.clear();
            sumPersList.clear();
            sumPendingList.clear();
    }
    
    private void loadSelected(){
        clear();
        loadPending();
        recordId = Apexpages.currentpage().getParameters().get('rec');
            if(recordId != '' || recordId != null){
                for(Forecast_Detail__c tmp: recordList){
                    if(tmp.Forecast__r.Id == recordId){
                        workingList.add(tmp);
                }
                }
                for(Forecast__c ftmp: recSumList){
                        if(ftmp.Id == recordId){
                                selectedForecast = ftmp;
                                isSelectForecastSubmitted = ftmp.Submitted__c;
                        }
                }
            }else{ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a non empty row'));
            }
    }
    
    public PageReference editDetail(){
	   try{
	        loadSelected();
	        pageRef = new PageReference('/apex/edit_detail');
	        return pageRef;
	   }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    private void clearWorkingList(){
    	List<Forecast_Detail__c> temp = new List<Forecast_Detail__c>();	
        for(Forecast_Detail__c tmp: workingList){
        	for(Forecast_Detail__c fd: recordList){    
	            if(tmp.Id == fd.Id){
	                temp.add( fd );        
	        	}
        	}
        }
        workingList.clear();
        workingList =  temp;
        return;
    }
        
    public PageReference rtnViewDetail(){
	  try{
	    	pageRef = new PageReference('/apex/view_detail'); 
	        return pageRef;	
	  }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    public PageReference viewDetail(){
    	try{
	        clearWorkingList();
	        loadSelected();
	        pageRef = new PageReference('/apex/view_detail'); 
	        return pageRef;
        }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    public PageReference saveDetail(){
		try{
	    	isValid();
	        try{
	            upsert workingList;
	        }catch(Exception ex){
	        	ApexPages.addmessage( new ApexPages.message( ApexPages.severity.Error,String.valueOf( 'Save failed. ' + ex.getMessage() ) ) );
	        }
	        loadSelected();
	        pageRef = new PageReference('/apex/view_detail');
	        return pageRef; 
        }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    public PageReference teamForecast(){
    	try{
	    	choice = 'Team Forecasts';
	    	checkingTeamRecords = true;
	    	pageRef = new PageReference('/apex/team_forecast');
	        return pageRef;	
        }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    public PageReference persForecast(){
    	try{
	    	choice = 'My Forecasts';
	    	checkingTeamRecords = false;
	    	pageRef = new PageReference('/apex/forecast_start');
	        return pageRef;	
        }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    private PageReference beginShow(){
    	try{
	        init();
	        if(isManager){
	        	checkingTeamRecords = true;
	        	teamForecast();	
	        }else{ 
	        	checkingTeamRecords = false;
	        	persForecast(); 
	    	}
	    	return pageRef;
	        
        }catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	persForecast();
	  	return pageRef;
	  }
    }
    
    public PageReference changeForecast(){
		try{
	        if(choice == 'My Forecasts'){
	        	checkingTeamRecords = false;
	        	showTeamSummary = false;
	        	//pageRef = new PageReference('/apex/forecast_start');
	        	//pageRef.setRedirect(true);
	        	return null;       
	        }
	        if(choice == 'Team Forecasts'){
	        	checkingTeamRecords = true;
	        	showTeamSummary = true;
	        	//pageRef = new PageReference('/apex/team_forecast');
	        	//pageRef.setRedirect(true);
	        	return null;
	        }return null;
		}catch(Exception ex){
	  	throw new forecastException('My apologies. I am confused with your last request. Re-setting the this form. Local Adminstrator has been notified. ');
	  	pageRef = new PageReference('/apex/forecast_start');
	  	pageRef.setRedirect(true);
	  	return pageRef;
	  }
    }
    
    private void init(){
        teamMap = new Map<String, SalesRep>(); 
        recSumList = new List<Forecast__c>();
        sumPersList  = new List<Forecast__c>();
        sumPendingList   = new List<Forecast__c>();
        pendingFDList = new List<Forecast_Detail__c>();
        workingList = new List<Forecast_Detail__c>();
        personalFDList = new List<Forecast_Detail__c>();
        errMsg = '';
        pId = '';
        pageRef = new PageReference('/apex/forecast_start');
        summary = new TeamTotals(); 
        isManager = false;
        isErr = false;
        isSelectForecastSubmitted = false;
        loadPending();
    }
    
    public List<SelectOption> getOptionList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('My Forecasts','My Forecasts'));
        options.add(new SelectOption('Team Forecasts','Team Forecasts'));
        return options ;
    }
    
    public PageReference getApprovalInstance(){
       recordId = Apexpages.currentpage().getParameters().get('rec');
       ProcessInstanceWorkitem p = new ProcessInstanceWorkitem();
        try{
            p = [SELECT     p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id 
                    FROM    ProcessInstanceWorkitem p 
                    WHERE   p.ProcessInstance.TargetObjectId =: recordId];
       }catch(Exception ex){
           ApexPages.addMessages(ex);
           return pageRef; 
       } 
       pageRef = new PageReference( '/p/process/ProcessInstanceWorkitemWizardStageManager?id='+String.valueOf(p.Id ) );
       return pageRef;
    }
    
    private class TeamTotals{
    	public Integer p1 {get;set;}
    	public Integer p2 {get;set;}
    	public Integer p3 {get;set;}
    	public Integer p4 {get;set;}
    	public Integer p5 {get;set;}
    	public Integer p6 {get;set;}
    	public Integer q1 {get;set;}
    	public Integer q2 {get;set;}
    	
    	public TeamTotals(){
    		p1 =0;p2 =0;p3 =0;p4 =0;p5 =0;p6 =0;q2 =0;q1 =0;
    	}	
    	public void add(Forecast__c f){
    		p1 += Integer.valueOf(f.RUS_month1_forecast__c);
    		p2 += Integer.valueOf(f.RUS_month2_forecast__c);
    		p3 += Integer.valueOf(f.RUS_month3_forecast__c);
    		p4 += Integer.valueOf(f.RUS_month4_forecast__c);
    		p5 += Integer.valueOf(f.RUS_month5_forecast__c);
    		p6 += Integer.valueOf(f.RUS_month6_forecast__c);
    		q1 += Integer.valueOf(f.RUS_quarter1_forecast__c);
    		q2 += Integer.valueOf(f.RUS_quarter2_forecast__c);
    	}
    }
    
    public class SalesRep{
        public String repId {get;set;}
        public String name {get;set;}
        public List<Forecast__c> fList{ get;set;}
        public SalesRep(String recId, String repName, List<Forecast__c> tmpList){
            repId = recId;
            name = repName;
            fList = new List<Forecast__c>();
            for(Forecast__c tmp: tmpList){ 
                fList.add(tmp); 
            } 
        }
    }
}
/***
    public void approve(){
        try{
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setComments(approvalComments+'Approved');
            pwr.setAction('Approve');
            pwr.setWorkitemId(getApprovalInstance(recordId));
            Approval.ProcessResult result =  Approval.process(pwr);
        }catch(Exception ex){
           ApexPages.addMessages(ex);
           return; 
       }
    }
    
    public void change(String recId){
        try{
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setComments(approvalComments+'Recalled');
            pwr.setAction('Removed');
            pwr.setWorkitemId(getApprovalInstance(recId));
            Approval.ProcessResult result =  Approval.process(pwr);
        }catch(Exception ex){
           ApexPages.addMessages(ex);
           return; 
       }
    }
    
    public void reject(){
        try{
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setComments(approvalComments+'Rejected');
            pwr.setAction('Reject');
            pwr.setWorkitemId(getApprovalInstance(recordId));
            Approval.ProcessResult result =  Approval.process(pwr);
        }catch(Exception ex){
           ApexPages.addMessages(ex);
           return; 
       }
    }
    
    
    
    public void approvalRequest(){
        system.debug('public PageReference approvalRequest() ');
        List<String> appIds = new List<String>();
        String rec = '';
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        try{
            for(Forecast_Detail__c tmp: recordList){
                if(recordId == tmp.Forecast__c){ 
                    
                    system.debug('Forecast_Detail__c recId: ' +tmp.Id);
                    system.debug('Forecast__c <tmp.Forecast__c> recId: ' +tmp.Forecast__c);
                    system.debug('Approver: ' + tmp.Forecast__r.Approver__c);
                    system.debug('ManagerId: ' + tmp.Forecast__r.Sales_Rep__r.ManagerId);
                    
                    rec = tmp.Forecast__c;
                    if(! String.isBlank(String.valueOf(tmp.Forecast__r.Approver__c)) ){
                        appIds.add(String.valueOf(tmp.Forecast__r.Approver__c));    
                    }
                    else if(! String.isBlank(String.valueOf(tmp.Forecast__r.Sales_Rep__r.ManagerId)) ){
                        appIds.add(String.valueOf(tmp.Forecast__r.Sales_Rep__r.ManagerId));    
                    }
                }
            }
            if(appIds.size() > 0){
                req.setComments('Request for approval via forcasting visualforce page.');
                req.setObjectId(rec);
                Approval.ProcessResult result = Approval.process(req);
                system.debug('Approval.ProcessResult: ' +result);
            }else{ throw new forecastException('Record does not have an approver. '); }
        }catch(Exception ex){
            ApexPages.addMessages(ex); 
        } 
    }
    <apex:commandLink action="{!URLFOR($Action.Forecast__c.Submit,recordId)}" value="Submit" style="text-decoration:none" styleClass="btn" rendered="{!!isManager}">
        <apex:param name="rec" assignto="{!recordid}" value="{!recordid}"/>
    </apex:commandLink>
    
    URL to navigate to aprroval screen 
        https://cs30.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id=04in00000000ezU
    
    
***/
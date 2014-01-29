@isTest
private class ForecastCtrlTest {
	
	private static Opportunity opp;
	private static Forecast__c fc;
	private static User salesUsr;
	private static User salesManUsr;
	public static Period currentQuarter, nextQuarter;
	
	static 
    {
    	iAd_Settings__c settings = TestUtil.createIadSettings();
    	currentQuarter = CSUtils.getFiscalQuarter(Date.today(),0);
        nextQuarter = CSUtils.getFiscalQuarter(Date.today(),1);
        
        //Create Sales Users and Manager User
        salesUsr = TestUtil.createUser();
        salesUsr.ProfileId = TestUtil.getProfile().Id;
        salesManUsr = TestUtil.createUser();
        salesUsr.ManagerId = salesManUsr.Id;
        List<User> tUsrList = new List<User>();
        tUsrList.add(salesUsr);
        tUsrList.add(salesManUsr);
        update tUsrList;
        
        //Create Opportuntiy
        opp = TestUtil.createOpp(); 
        opp.iAd_Type__c='i4B';
        opp.OwnerId = salesUsr.Id;
        opp.ForecastCategoryName='Pipeline';
        insert opp;
         
        //Create Forecast and Forecast Detail records, with BatchProcess-SalesForecast.cls
        SalesForecast buildForecast = new SalesForecast();
       	Database.executeBatch(buildForecast);
       	
       	
    }
	
    static testMethod void forecastControllerTest() {
        System.runAs(salesUsr) {
        	Test.startTest();
        	PageReference pageRef = Page.iad_forecast;
	        Test.setCurrentPage(pageRef);
	        ForecastCtrl controller = new ForecastCtrl();
	        PageReference pr = controller.teamForecast();
	        system.assertEquals(true, pr.getURL().startsWith('/apex/team_forecast'));
	        pr = controller.persForecast();
	        system.assertEquals(true, pr.getURL().startsWith('/apex/forecast_start'));
	        pr = controller.viewDetail();
	        system.assertEquals(true, pr.getURL().startsWith('/apex/view_detail'));
	        pr = controller.rtnViewDetail();
	        system.assertEquals(true, pr.getURL().startsWith('/apex/view_detail'));
	        pr = controller.editDetail();
	        system.assertEquals(true, pr.getURL().startsWith('/apex/edit_detail'));
	        Test.stopTest();	
        }
        
        
        
        
    }
}
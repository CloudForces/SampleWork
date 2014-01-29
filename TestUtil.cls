/**
 *
 * TestUtil
 *
 * This is a utility class, designed for use solely in other test classes.
 *
 * Any object creation performed within unit tests should be done here, rather than in the 
 * tests themselves.  This will allow for a single place to update, when there are new 
 * validation rules, workflow changes, etc.
 *
 */

@isTest
public class TestUtil {

    public static Integer acctIncrementor = 0;
    public static Account acct;
	public static Forecast__c forecast;
	
	
    static
    {
        if(Test.isRunningTest()){
            acct = createAccount(); insert acct;
	        List<Currency_Conversion__c> convs = new List<Currency_Conversion__c>{
                new Currency_Conversion__c(Conversion_Rate__c = 1.2, From_Currency__c = 'GBP', To_Currency__c = 'USD', Start_Date__c = Date.valueOf('2010-10-01')),
	            new Currency_Conversion__c(Conversion_Rate__c = 1.2, From_Currency__c = 'GBP', To_Currency__c = 'USD', Start_Date__c = system.today().addDays(-30)),
	            new Currency_Conversion__c(Conversion_Rate__c = 1.3, From_Currency__c = 'EUR', To_Currency__c = 'USD', Start_Date__c = system.today().addDays(-30)),
	            new Currency_Conversion__c(Conversion_Rate__c = 1.4, From_Currency__c = 'GBP', To_Currency__c = 'EUR', Start_Date__c = system.today().addDays(-30)),
	            new Currency_Conversion__c(Conversion_Rate__c = 1.0, From_Currency__c = 'USD', To_Currency__c = 'USD', Start_Date__c = system.today().addDays(-30))
	        }; insert convs;
        }
        
    }

    public static Integer oppIncrementor = 0;

    public static Account createAccount(){ return createAccount(null); }
    public static Account createAccount(String Name){
        if(Name == null) name = 'Test Account '+(acctIncrementor++);
        return new Account(Name = name);
    }

    public static Account mediaAgency;
    public static Account getMediaAgency(){ 
        if(mediaAgency==null){ 
            mediaAgency = createAccount('No Agency Used');
            insert mediaAgency;
        }
        return mediaAgency;
    } 

    public static Profile testProfile;
    public static Profile getProfile(){
        if(testProfile==null){
            testProfile = getProfile('Standard User');
        }
        return testProfile;
    }
    public static Profile getProfile(String Name){
    	if(Name == null) Name = 'Standard User';
        return [SELECT Id FROM Profile WHERE Name = :Name LIMIT 1];
    }

    public static UserRole testRole;
    public static Userrole getRole(){
        if(testRole==null){
            testRole = [SELECT Id FROM UserRole LIMIT 1];
        }
        return testRole;
    }

    public static Integer userIncrementor = 0;
    public static User testUser;
    public static User getUser(){
        if(testUser==null){
        	testUser = createUser();
        }
        return testUser;
    }
    public static User createUser(){
        User u = [SELECT Id FROM User WHERE IsActive = true AND ProfileId = :getProfile('System Administrator').Id AND Id != :UserInfo.getUserId() LIMIT 1];
        User user;
        system.runAs(u){
        	userIncrementor++;
            String r = String.valueOf(Integer.valueOf(Math.random()*99)).leftPad(2,'0');
            String e = 'testuser_'+r+'_'+userIncrementor+'@testdomain.com';
            user = new User(
                Alias             = 'tu'+(r+userIncrementor).left(4),
                Email             = e,
                EmailEncodingKey  = 'UTF-8',
                FirstName         = 'Test',
                LanguageLocaleKey = 'en_US',
                LastName          = 'User '+r,
                LocaleSidKey      = 'en_US',
                ProfileId         = getProfile().Id,
                TimeZoneSidKey    = 'America/New_York',
                Username          = e,
                UserRoleId        = getRole().Id
            );
            insert user;
        }
        return user;
    }

    public static Opportunity testOpp;
    public static Opportunity getOpp(){
        if(testOpp==null){
            testOpp = createOpp();
        }
        return testOpp;
    }
    
    public static iAd_Settings__c createIadSettings() 
    {
    	iAd_Settings__c setting = new iAd_Settings__c();
    	List<iAd_Settings__c> iads = [select id from iAd_Settings__c where name='settings' ];
    	if(iads.size()==0)
    	{
	    	setting.Name='settings';
	    	setting.TakeoverDailyThreshold__c=1;
	    	insert setting;
    	}
    	else
    	{
    		return iads[0];
    	}
    	return setting;
    }
    
    public static Opportunity createOpp(){ return createOpp(null,null); }
    public static Opportunity createOpp(String name){ return createOpp(null,name); }
    
    public static Opportunity createOpp(Id AccountId, String Name)
    {
        if(AccountId == null) AccountId = acct.Id;
        if(Name == null) Name = 'Test '+(oppIncrementor++);
        return new opportunity(
            AccountId                         = AccountId,
            Account_Manager__c                = getUser().Id,
            Ad_Classification__c              = 'Alcohol',
            Attached_RFP__c                   = 'Yes',
            Billing_Type__c                   = 'Standard',
            Campaign_KPIs__c                  = 2,
            CloseDate                         = system.today() - 21,
            Core_Objective__c                 = 'Sample Data',
            Country__c                        = 'US',
            Currency__c                       = 'GBP',
            Ease_of_Doing_Business__c         = 2,
            Events_Season__c                  = 'None',
            Exchange_Rate_Date__c             = system.today().addDays(-22),
            ForecastCategoryName              = 'Pipeline',
            iAd_Type_1__c                     = 'i4B',
            Ideation_Support__c               = 'None',
            Inventory_Approved__c             = false,
            Media_Agency__c                   = getMediaAgency().Id,
            Name                              = Name,
            NBM__c                            = 'Custom',
            Overall_Client_Temperature__c     = 2,
            Production_Fee_Type__c            = 'N/A',
            Requested_Campaign_End_Date__c    = Date.today().addDays(3),
            Requested_Campaign_Start_Date__c  = Date.today().addDays(2),
            Scheduled_Meeting_RFP_Due_Date__c = Date.today(),
            StageName                         = 'In Discussions',
            Focus_Account__c = 'No',
            Pre_Sales_Sales_Marketing_Support__c='None',
            recordTypeId='012700000001a3K',
            Amount_LC__c=100
        );
    }

    public static Line_Item__c createLine(){ return createLine(null); }
    public static Line_Item__c createLine(Id OppId)
    {
        if(OppId == null){ 
            Opportunity opp = getOpp(); 
            if(opp.Id==null){ insert opp; } 
            OppId = opp.Id; 
        }
        return new Line_Item__c(
            End_Date__c               = system.today()-7,
            //Local_Currency__c         = 'GBP',
            //MSA_Currency__c           = 'EUR', 
            Opp_Exchange_Rate_Date__c = system.today(),
            Opportunity_Name__c       = OppId,
            Start_Date__c             = system.today()-14,
            Placement_Type__c='Standard Media',
            pricing_Type__c='CPM',
            Net_Cost_LC__c=10,
            recordTypeId=CSUtils.getRecordTypeId('Line_Item__c', 'Line Item External'),
            CPM_Rate__c=12
        );
    }

}
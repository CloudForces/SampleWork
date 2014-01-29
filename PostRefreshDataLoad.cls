/*
List of of command in the sequence:
PostRefreshDataLoad.Reset();
PostRefreshDataLoad.LoadNonTargetingData1();
PostRefreshDataLoad.LoadNonTargetingData2();
PostRefreshDataLoad.LoadTargetingFields();
PostRefreshDataLoad.LoadTargetingFieldMappings1();
PostRefreshDataLoad.LoadTargetingFieldMappings2();
PostRefreshDataLoad.setupPushTopicAndIAdSetting();
PostRefreshDataLoad.setupUsers();
*/

public class PostRefreshDataLoad{
	
	static string fileName = '';
	static List<Map<string, string>> rows =null;
	static Map<string, Schema.SObjectField> fieldsMap =null;
	static List<sObject> sobjs =null;
	static string typeName ='';
	
	public static void Reset(){
		List<Account> acct =[Select id from Account];
		delete acct;
		
		List<Contact> contacts =[select id from Contact];
		delete contacts;
		
		List<Default__c> defaults =[Select id from Default__c];
		delete defaults;
		
		List<Currency_Conversion__c> currencies =[Select id from Currency_Conversion__c];
		delete currencies;
		
		List <Interface_Option__c> options =[select id from Interface_Option__c];
		delete options;
		
		List <Targeting_Field__c> tFields =[select id from Targeting_Field__c];
		delete tFields;
		
		List <Targeting_Field_Mappings__c> tFieldsMaps =[select id from Targeting_Field_Mappings__c];
		delete tFieldsMaps;
		
		List<PostRefreshDataLoader__c> prdl = [select id from PostRefreshDataLoader__c];
		delete prdl;
	}
	public static void LoadNonTargetingData1(){
		typeName=fileName = 'Account';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Account.fields.getMap();
		sobjs = new List<Account>();
		populateSObjectList();
		insert sobjs;
		List<Account> accts = sobjs;
		
		typeName=fileName = 'Contact';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Contact.fields.getMap();
		sobjs = new List<Contact>();
		sobjs = populateSObjectList();
		integer i=0;
		for(sObject s: sobjs)
		{
			s.put('AccountId', accts[i++].Id);
		}
		insert sobjs;
		
	}
	public static void LoadNonTargetingData2() 
	{
		fileName = 'Default';
		typeName='Default__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Default__c.fields.getMap();
		sobjs = new List<Default__c>();
		sobjs = populateSObjectList();
		insert sobjs;
		
		fileName = 'CurrencyConvert';
		typeName='Currency_Conversion__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Currency_Conversion__c.fields.getMap();
		sobjs = new List<Currency_Conversion__c>();
		sobjs = populateSObjectList();
		insert sobjs;
		
		fileName = 'InterfaceOptions';
		typeName='Interface_Option__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Interface_Option__c.fields.getMap();
		sobjs = new List<Interface_Option__c>();
		sobjs = populateSObjectList();
		insert sobjs;
	}
	
	public static void LoadTargetingFields() 
	{
		Map<string, string> tfIdsMap= new Map<string, string>();
		fileName = 'TargetingFields';
		typeName='Targeting_Field__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Targeting_Field__c.fields.getMap();
		sobjs = new List<Targeting_Field__c>();
		sobjs = populateSObjectList();
		insert sobjs;
		integer j=0;
		
		List<PostRefreshDataLoader__c> records = new List<PostRefreshDataLoader__c>();
		for(Map<string, string> m: rows)
		{
			tfIdsMap.put(m.get('Id').trim(), string.valueof(sobjs[j].get('Id')));
			PostRefreshDataLoader__c temp = new PostRefreshDataLoader__c();
			temp.OldTargetingFieldId__c = m.get('Id').trim();
			temp.NewTargetingFieldId__c = string.valueof(sobjs[j].get('Id'));
			records.add(temp);
			j++;
		}
		insert records;
	}
	public static void LoadTargetingFieldMappings1() 
	{
		Map<string, string> tfIdsMap= new Map<string, string>();
		List<PostRefreshDataLoader__c> records = [select OldTargetingFieldId__c, NewTargetingFieldId__c from PostRefreshDataLoader__c];
		for(PostRefreshDataLoader__c temp: records)
		{
			tfIdsMap.put(temp.OldTargetingFieldId__c, temp.NewTargetingFieldId__c);
		}
		fileName = 'TargetingFieldsMappings1';
		typeName='Targeting_Field_Mappings__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Targeting_Field_Mappings__c.fields.getMap();
		sobjs = new List<Targeting_Field_Mappings__c>();
		sobjs = populateSObjectList();
		for(sObject s: sobjs)
		{
			string oldFkey = string.valueOf(s.get('Targeting_Field__c'));
			string newFkey = tfIdsMap.get(oldFkey);
			s.put('Targeting_Field__c', newFkey);
		}
		insert sobjs;
	}
	
	public static void LoadTargetingFieldMappings2() 
	{
		Map<string, string> tfIdsMap= new Map<string, string>();
		List<PostRefreshDataLoader__c> records = [select OldTargetingFieldId__c, NewTargetingFieldId__c from PostRefreshDataLoader__c];
		for(PostRefreshDataLoader__c temp: records)
		{
			tfIdsMap.put(temp.OldTargetingFieldId__c, temp.NewTargetingFieldId__c);
		}
		fileName = 'TargetingFieldsMappings2';
		typeName='Targeting_Field_Mappings__c';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.Targeting_Field_Mappings__c.fields.getMap();
		sobjs = new List<Targeting_Field_Mappings__c>();
		sobjs = populateSObjectList();
		for(sObject s: sobjs)
		{
			string oldFkey = string.valueOf(s.get('Targeting_Field__c'));
			string newFkey = tfIdsMap.get(oldFkey);
			s.put('Targeting_Field__c', newFkey);
		}
		insert sobjs;
	}
	
	public static void setupPushTopicAndIAdSetting()
	{
		TestUtil.createIadSettings();
		try
		{
			//Set up the streaming API by executing the following command from the Developer Console:
			PushTopic t = new PushTopic(Name='Transactions',QUery='SELECT Id, Name, URL_short__c, Request_ID__c FROM Transaction_Log__c',NotifyForFields='All',NotifyForOperations='Create',IsActive=true,ApiVersion=27.0); 
			insert t;
		}
		catch(Exception e)
		{
			system.debug('Topic is already setup.'); 
		}
	}
	
	public static void setupUsers()
	{
		fileName = 'Users';
		typeName='User';
		rows = ReadFile();
		fieldsMap = Schema.SObjectType.User.fields.getMap();
		sobjs = new List<User>();
		sobjs = populateSObjectList();
		
		string sbxNm=UserInfo.getUserName().substring(UserInfo.getUserName().lastIndexOf('.'));
		List<sObject> createUsers = new List<sObject>();
		List<sObject> updateUsers = new List<sObject>();
		for(sobject s: sobjs)
		{
			s.put('UserName', s.get('Email')+sbxNm);
			
			if(s.get('Id')==null || s.get('Id')=='')
				createUsers.add(s);
			else
				updateUsers.add(s);
		}
		insert createUsers;
		update updateUsers;
	}
	
	public static List<sObject> populateSObjectList()
	{
		if(rows.size()>0)
		{
			for(Map<string, string> m : rows)
			{
				sObject a = createObject();
				for(string fieldNm: m.keySet())
				{
					Schema.SObjectField f = fieldsMap.get(fieldNm);
					Schema.DescribeFieldResult fr = f.getDescribe();
					string fieldType = String.valueOf(fr.getType());
					if(fieldNm=='ID')system.debug('fieldType='+fieldType+'*****');
					
					if(fr.isCreateable() || (typeName=='User' && fieldNm=='ID'))
					{
						string fvalue = m.get(fieldNm);
						if( fvalue != null)
						{
							if(fieldNm=='ID')system.debug('fvalue='+fvalue);
							fvalue = fvalue.trim().replace('$$$',',');
							if( fieldType== 'STRING' || fieldType== 'PICKLIST' || fieldType== 'REFERENCE' || fieldType=='TEXTAREA' || fieldType=='EMAIL' || fieldType=='ID')
							{
								a.put(fieldNm, fvalue.replace('"',''));
							}
							if( fieldType== 'DATETIME')
							{
								a.put(fieldNm, DateTime.valueOf(fvalue));
							}
							if( fieldType== 'DATE')
							{
								string d = fvalue;
								if(d != null && d!='') 
								{
									string[] dparts = d.split('/');
									if(dparts.size()==3) 
									d='20'+dparts[2]+'-'+dparts[0]+'-'+dparts[1];
									a.put(fieldNm, Date.valueOf(d));
								}
							}
							if( fieldType== 'DOUBLE')
							{
								a.put(fieldNm, Double.valueOf(fvalue));
							}
							if( fieldType== 'CURRENCY')
							{
							}
							if( fieldType== 'BOOLEAN' || fieldType=='CHECKBOX')
							{
								a.put(fieldNm, fvalue=='1' || fvalue=='TRUE'?true:false);
							}
						}
					}
				}
				sobjs.add(a);
			}
		}
		return sobjs;
	}
	
	public static List<Map<string, string>> ReadFile() 
	{
		StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name =:fileName];
        blob tempB = defaultResource.Body;
        
       	String contentFile = tempB.toString();
       	String[] filelines = contentFile.split('xxx@');
       
       	string header = filelines[0];
       	string[] columns = header.split(',');
       	//system.debug('header='+header+' columns size='+columns.size());
    	
    	rows = new List<Map<string, string>>();
       	for (Integer i=1;i<filelines.size();i++)
        {
        	String[] inputvalues = filelines[i].split(',');
        	Map<string, string> map1 = new Map<string, string>();
        	for(Integer j=0; j<columns.size(); ++j)
        	{
        		map1.put(columns[j], inputvalues[j]);
        	}
        	rows.add(map1);
        }
        return rows;
	}
	
	public static sObject createObject() 
	{
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) 
        {
            system.debug('NOT A VALID TYPE');
        }
        
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(); 
    }
}
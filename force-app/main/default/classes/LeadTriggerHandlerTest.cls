@IsTest
private class LeadTriggerHandlerTest {

	@TestSetup
	static void makeData(){
		insert new List<Country__c> {
			new Country__c(Name = 'Slovakia', Capital__c = 'Bratislava', ISOCode2__c = 'SK', ISOCode3__c = 'SVK', Region__c = 'Europe'),
			new Country__c(Name = 'Spain', Capital__c = 'Madrid', ISOCode2__c = 'ES', ISOCode3__c = 'ESP', Region__c = 'Europe'),
			new Country__c(Name = 'Japan', Capital__c = 'Tokyo', ISOCode2__c = 'JP', ISOCode3__c = 'JPN', Region__c = 'Asia')
		};
	}

	@IsTest
	static void should_throwException_when_noAccessToCountryObject() {
		System.runAs(UnitTestUtils.buildStandardUser()){
			String errorMessage;
			try {
				insert buildLead('Smith', 'Test1 Ltd', 'Slovakia', 'SK');
			} catch (Exception e) {
				errorMessage = e.getMessage();
			}

			System.assert(errorMessage.containsIgnoreCase(System.Label.NoPermissionReadCountry), 'Exception containing message "No permission to read for Country" should be thrown.');
		}
	}

	@IsTest
	static void should_updateCountryInfo_when_newLeads() {
		System.runAs(UnitTestUtils.buildCountryInfoUser()){
			Lead lead1 = buildLead('Smith', 'Test1 Ltd', 'Slovakia', 'SK');
			Lead lead2 = buildLead('Chin', 'Test2 Ltd', 'Japan', 'JP');
			insert new List<Lead> { lead1, lead2 };

			System.assertEquals('SVK', [SELECT Country__r.ISOCode3__c FROM Lead WHERE Id =: lead1.Id].Country__r.ISOCode3__c, 'Lead1 should have Slovakia Country Info');
			System.assertEquals('JPN', [SELECT Country__r.ISOCode3__c FROM Lead WHERE Id =: lead2.Id].Country__r.ISOCode3__c, 'Lead2 should have Japan Country Info');
		}
	}

	@IsTest
	static void should_updateCountryInfo_when_leadsUpdated() {
		System.runAs(UnitTestUtils.buildCountryInfoUser()){
			Lead lead1 = buildLead('Smith', 'Test1 Ltd', 'Slovakia', 'SK');
			Lead lead2 = buildLead('Chin', 'Test2 Ltd', 'Japan', 'JP');
			insert new List<Lead>{ lead1, lead2 };

			lead1.Country = 'Spain';
			lead2.Country = null;
			if (LeadTriggerHandler.COUNTRY_CODES_ENABLED) {
				lead1.put(LeadTriggerHandler.COUNTRY_CODE_FIELD, 'ES');
				lead2.put(LeadTriggerHandler.COUNTRY_CODE_FIELD, null);
			}
			update new List<Lead>{ lead1, lead2 };

			System.assertEquals('ESP', [SELECT Country__r.ISOCode3__c FROM Lead WHERE Id =: lead1.Id].Country__r.ISOCode3__c, 'Lead1 Country Info should be changed to Spain');
			System.assertEquals(null, [SELECT Country__c FROM Lead WHERE Id =: lead2.Id].Country__c, 'Lead2 Country Info should be removed');
		}
	}

	private static Lead buildLead(String lastName, String company, String country, String countryCode) {
		Lead lead = new Lead(LastName = lastName, Company = company, Country = country);
		if (LeadTriggerHandler.COUNTRY_CODES_ENABLED) {
			lead.put(LeadTriggerHandler.COUNTRY_CODE_FIELD, countryCode);
		}
		return lead;
	}
}
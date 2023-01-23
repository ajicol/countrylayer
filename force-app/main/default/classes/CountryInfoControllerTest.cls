@IsTest
private class CountryInfoControllerTest {

	private class MockError implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			if (req.getEndpoint().endsWith('&access_key=')) {
				HttpResponse res = new HttpResponse();
				res.setBody('{"success": false,"error": {"code": 101,"type": "invalid_access_key",'
							+ '"info": "You have not supplied a valid API Access Key. '
							+ '[Technical Support: support@apilayer.com]"}');
				res.setStatusCode(200);
				return res;
			} else {
				System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
				return null;
			}
		}
	}

	@IsTest
	static void should_runSchedulableWithoutErrors(){
		System.runAs(UnitTestUtils.buildCountryInfoUser()) {
			String errorMessage;
			setMockOK();

			try {
				Test.startTest();
				CountryInfoController.scheduleCountryUpdateOncePerDay();
				Test.stopTest();
			} catch (Exception e) {
				errorMessage = e.getMessage();
			}

			System.assertEquals(null, errorMessage, 'Error should not be thrown');
		}
	}

	@IsTest
	static void should_throwError_when_incorrectAPIKey(){
		System.runAs(UnitTestUtils.buildCountryInfoUser()) {
			CountrylayerCalloutService.apiKeyParameter = '&access_key=';
			Test.setMock(HttpCalloutMock.class, new MockError());
			String errorMessage;

			try {
				Test.startTest();
				CountryInfoController.updateCountries();
				Test.stopTest();
			} catch (Exception e) {
				errorMessage = e.getMessage();
			}

			System.assert(errorMessage.contains('You have not supplied a valid API Access Key'), 'Callout exception should be thrown');
		}
	}

	@IsTest
	static void should_insertCountries(){
		System.runAs(UnitTestUtils.buildCountryInfoUser()) {
			setMockOK();

			Test.startTest();
			CountryInfoController.updateCountries();
			Test.stopTest();

			List<Country__c> countries = [SELECT ISOCode2__c, ISOCode3__c FROM Country__c LIMIT 300];
			System.assertEquals(250, countries.size(), '250 Country records should be created');
			System.assert(String.isNotBlank(countries[26].ISOCode2__c), 'ISOCode2 should be filled in for a record.');
			System.assert(String.isNotBlank(countries[125].ISOCode3__c), 'ISOCode3 should be filled in for a record.');
		}
	}

	@IsTest
	static void should_updateCountries(){
		System.runAs(UnitTestUtils.buildCountryInfoUser()) {
			Country__c usa = new Country__c(Name = 'USA', ISOCode2__c = 'US', ISOCode3__c = 'USA');
			Country__c spain = new Country__c(Name = 'Espana', ISOCode2__c = 'ES', ISOCode3__c = 'ESP');
			insert new List<Country__c> { usa, spain };
			setMockOK();

			Test.startTest();
			CountryInfoController.updateCountries();
			Test.stopTest();

			usa = [SELECT Name FROM Country__c WHERE Id =: usa.Id LIMIT 1];
			spain = [SELECT Name FROM Country__c WHERE Id =: spain.Id LIMIT 1];

			System.assertEquals('United States of America', usa.Name, 'Name USA should be updated to United States of America');
			System.assertEquals('Spain', spain.Name, 'Name Espana should be updated to Spain');
		}
	}

	@IsTest
	static void should_throwError_when_noUpdatePermissionForCountry(){
		System.runAs(UnitTestUtils.buildStandardUser()) {
			String errorMessage;

			try {
				Test.startTest();
				CountryInfoController.updateCountries();
				Test.stopTest();
			} catch (Exception e) {
				errorMessage = e.getMessage();
			}

			System.assertEquals(System.Label.NoPermissionUpsertCountry, errorMessage, 'Permission exception should be thrown');
		}
	}

	private static void setMockOK() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('CountryLayerTestResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);
	}
}
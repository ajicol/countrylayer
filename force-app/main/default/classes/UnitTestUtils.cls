@IsTest
public without sharing class UnitTestUtils {

	public static User buildStandardUser() {
		User result = new User();

		String orgId = UserInfo.getOrganizationId();
		Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));

		result.Username = randomInt + '@test' + orgId + '.org';
		result.Email = result.Username;
		result.ProfileId = [SELECT Id FROM Profile WHERE Name = :'Standard User' LIMIT 1].Id;

		result.FirstName = 'Tom';
		result.LastName = 'Terry';
		result.Alias = 'Tom';
		result.EmailEncodingKey = 'ISO-8859-1';
		result.TimeZoneSidKey = 'America/Los_Angeles';
		result.LanguageLocaleKey = 'en_US';
		result.LocaleSidKey = 'en_US';

		insert result;

		return result;
	}

	public static User buildCountryInfoUser() {
		User result = buildStandardUser();

		Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name =: 'CountryInfoUser' LIMIT 1].Id;

		System.runAs([SELECT Id FROM User WHERE Id = : UserInfo.getUserId()][0]) {
			Database.insert(new PermissionSetAssignment(AssigneeId = result.Id, PermissionSetId = permissionSetId));
		}

		return result;
	}
}
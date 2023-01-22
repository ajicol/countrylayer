public class CountryInfoUpdate implements Queueable, Database.AllowsCallouts {

	public class CountryInfoException extends Exception {}

	public void execute(QueueableContext context) {
		if (!isUpsertPermittedForCountry()) {
			throw new Exceptions.PermissionException(System.Label.NoPermissionUpsertCountry);
		}
		List<Models.CountryInfo> countryInfos = CountrylayerCalloutService.getCountries();
		if (countryInfos == null || countryInfos.isEmpty()) {
			return;
		}

		List<Country__c> countries = new List<Country__c>();
		for (Models.CountryInfo countryInfo : countryInfos) {
			Country__c country = createCountry(countryInfo);
			if (country != null) {
				countries.add(country);
			}
		}

		if (!countries.isEmpty()) {
			upsert countries ISOCode2__c;
		}
	}

	private Country__c createCountry(Models.CountryInfo countryInfo) {
		if (countryInfo == null || String.isBlank(countryInfo.alpha2Code)) {
			return null;
		}
		return new Country__c(
			Name = countryInfo.name,
			Capital__c = countryInfo.capital,
			ISOCode2__c = countryInfo.alpha2Code,
			ISOCode3__c = countryInfo.alpha3Code,
			Region__c = countryInfo.region
			);
	}

	private Boolean isUpsertPermittedForCountry() {
		return Schema.SObjectType.Country__c.isCreateable()
				&& Schema.SObjectType.Country__c.isUpdateable()
				&& Schema.SObjectType.Country__c.fields.Name.isCreateable()
				&& Schema.SObjectType.Country__c.fields.Name.isUpdateable()
				&& Schema.SObjectType.Country__c.fields.Capital__c.isCreateable()
				&& Schema.SObjectType.Country__c.fields.Capital__c.isUpdateable()
				&& Schema.SObjectType.Country__c.fields.ISOCode2__c.isCreateable()
				&& Schema.SObjectType.Country__c.fields.ISOCode2__c.isUpdateable()
				&& Schema.SObjectType.Country__c.fields.ISOCode3__c.isCreateable()
				&& Schema.SObjectType.Country__c.fields.ISOCode3__c.isUpdateable()
				&& Schema.SObjectType.Country__c.fields.Region__c.isCreateable()
				&& Schema.SObjectType.Country__c.fields.Region__c.isUpdateable();
	}
}
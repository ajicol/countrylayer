public with sharing class LeadTriggerHandler {

	public static final Boolean COUNTRY_CODES_ENABLED = Lead.getSObjectType().getDescribe().fields.getMap().keySet().contains(COUNTRY_CODE_FIELD.toLowerCase());
	public static final String COUNTRY_CODE_FIELD = 'CountryCode';

	public void onBeforeInsert(List<Lead> newLeads){
		List<Lead> leadsToProcess = new List<Lead>();
		Set<String> countries = new Set<String>();
		for (Lead lead : newLeads) {
			if (countryIsNotEmpty(lead)) {
				leadsToProcess.add(lead);
				countries.add(COUNTRY_CODES_ENABLED ? (String)lead.get(COUNTRY_CODE_FIELD) : lead.Country);
			}
		}

		updateCountryInfoOnLeads(leadsToProcess, countries);
	}

	public void onBeforeUpdate(Map<Id, Lead> oldLeads, Map<Id, Lead> newLeads){
		List<Lead> leadsToProcess = new List<Lead>();
		Set<String> countries = new Set<String>();
		for(Id leadId : newLeads.keySet()) {
			if(countryHasChanged(leadId, oldLeads, newLeads)) {
				Lead lead = newLeads.get(leadId);
				leadsToProcess.add(lead);
				countries.add(COUNTRY_CODES_ENABLED ? (String)lead.get(COUNTRY_CODE_FIELD) : lead.Country);
			}
		}

		updateCountryInfoOnLeads(leadsToProcess, countries);
	}

	private void updateCountryInfoOnLeads(List<Lead> leads, Set<String> countryIdentifiers) {
		if (leads.isEmpty()) {
			return;
		}
		Map<String, Country__c> identifierToCountry = getIdentifierToCountryMap(countryIdentifiers);

		for (Lead lead : leads) {
			if ((!COUNTRY_CODES_ENABLED && lead.Country == null) || (COUNTRY_CODES_ENABLED && lead.get(COUNTRY_CODE_FIELD) == null)) {
				lead.Country__c = null;
			} else if (!identifierToCountry.isEmpty()) {
				lead.Country__c = identifierToCountry.get(COUNTRY_CODES_ENABLED ? (String)lead.get(COUNTRY_CODE_FIELD) : lead.Country).Id;
			}
		}
	}

	private Boolean countryIsNotEmpty(Lead lead) {
		return ((COUNTRY_CODES_ENABLED && lead.get(COUNTRY_CODE_FIELD) != null)
		        || (!COUNTRY_CODES_ENABLED && String.isNotBlank(lead.Country)));
	}

	private Boolean countryHasChanged(Id leadId, Map<Id, Lead> oldLeads, Map<Id, Lead> newLeads) {
		return (COUNTRY_CODES_ENABLED && oldLeads.get(leadId).get(COUNTRY_CODE_FIELD) != newLeads.get(leadId).get(COUNTRY_CODE_FIELD))
		       || (!COUNTRY_CODES_ENABLED && oldLeads.get(leadId).Country != newLeads.get(leadId).Country);
	}

	private Map<String, Country__c> getIdentifierToCountryMap(Set<String> countryIdentifiers) {
		Map<String, Country__c> result = new Map<String, Country__c>();
		if (countryIdentifiers.isEmpty()) {
			return result;
		}
		
		if (!isReadPermittedForCountry()) {
			throw new Exceptions.PermissionException(System.Label.NoPermissionReadCountry);
		}
		List<Country__c> countries = [SELECT Name, Capital__c, ISOCode2__c, ISOCode3__c, Region__c
		                              FROM Country__c
		                              WHERE ISOCode2__c IN: countryIdentifiers OR Name IN: countryIdentifiers
		                              LIMIT 500];

		for (Country__c country : countries) {
			result.put((COUNTRY_CODES_ENABLED ? country.ISOCode2__c : country.Name), country);
		}

		return result;
	}

	private Boolean isReadPermittedForCountry() {
		return Schema.SObjectType.Country__c.isAccessible()
		       && Schema.SObjectType.Country__c.fields.Name.isAccessible()
		       && Schema.SObjectType.Country__c.fields.Capital__c.isAccessible()
		       && Schema.SObjectType.Country__c.fields.ISOCode2__c.isAccessible()
		       && Schema.SObjectType.Country__c.fields.ISOCode3__c.isAccessible()
		       && Schema.SObjectType.Country__c.fields.Region__c.isAccessible();
	}
}

public class CountrylayerCalloutService {

	private static final String URL = 'http://api.countrylayer.com/v2/all';
	private static final String FILTERS_PARAMETER = '?filters=name;alpha2Code;alpha3Code;capital;region;subregion;regionalBlocs';
	private static final String ERROR_FRAGMENT = '"error":';
	@TestVisible private static String apiKeyParameter = '&access_key={0}';

	public class CountrylayerCalloutException extends Exception {}

	public static List<Models.CountryInfo> getCountries() {
		List<Models.CountryInfo> result = new List<Models.CountryInfo>();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(URL + FILTERS_PARAMETER + getApiKeyParameter());
		request.setMethod('GET');

		HttpResponse response = http.send(request);
		String responseBody = response.getBody();
		Integer statusCode = response.getStatusCode();
		if(statusCode == 200 && responseBody != null && !responseBody.containsIgnoreCase(ERROR_FRAGMENT)) {
			result = (List<Models.CountryInfo>) JSON.deserialize(responseBody, List<Models.CountryInfo>.class);
		} else {
			String errorMsg = String.format(System.Label.CountrylayerCalloutError, new List<String>{ String.valueOf(statusCode), responseBody });
			throw new CountrylayerCalloutException(errorMsg);
		}

		return result;
	}

	private static String getApiKeyParameter() {
		Countrylayer_Setting__mdt countrylayerApiKeyRecord = Countrylayer_Setting__mdt.getInstance('API_Key');
		String apiKey= countrylayerApiKeyRecord == null ? '' : countrylayerApiKeyRecord.Value__c;
		return String.format(apiKeyParameter, new List<String>{ apiKey });
	}
}
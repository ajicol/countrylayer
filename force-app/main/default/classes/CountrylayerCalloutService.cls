public class CountrylayerCalloutService {

	private static final String URL = 'http://api.countrylayer.com/v2/all';
	private static final String FILTERS_PARAMETER = '?filters=name;alpha2Code;alpha3Code;capital;region;subregion;regionalBlocs';
	@TestVisible private static String API_KEY_PARAMETER = '&access_key=7512d85ee14d4a8304b802233b427421';

	public class CountrylayerCalloutException extends Exception {}

	public static List<Models.CountryInfo> getCountries() {
		List<Models.CountryInfo> result = new List<Models.CountryInfo>();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(URL + FILTERS_PARAMETER + API_KEY_PARAMETER);
		request.setMethod('GET');

		HttpResponse response = http.send(request);
		String responseBody = response.getBody();
		Integer statusCode = response.getStatusCode();
		if(statusCode == 200 && responseBody != null && !responseBody.containsIgnoreCase('"error":')) {
			result = (List<Models.CountryInfo>) JSON.deserialize(responseBody, List<Models.CountryInfo>.class);
		} else {
			String errorMsg = String.format(System.Label.CountrylayerCalloutError, new List<String>{ String.valueOf(statusCode), responseBody });
			throw new CountrylayerCalloutException(errorMsg);
		}

		return result;
	}
}
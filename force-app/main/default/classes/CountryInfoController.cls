public class CountryInfoController {

	public static void scheduleCountryUpdateOncePerDay() {
		String chronExpression = '0 0 22 * * ? *';
		System.schedule('Country Info Update', chronExpression, new ScheduableCountryInfoUpdate());
	}

	public static void updateCountries() {
		System.enqueueJob(new CountryInfoUpdate());
	}
}
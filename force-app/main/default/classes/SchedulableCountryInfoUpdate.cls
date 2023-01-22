public class SchedulableCountryInfoUpdate implements Schedulable {

	public void execute(SchedulableContext context) {
		System.enqueueJob(new CountryInfoUpdate());
	}
}
public class ScheduableCountryInfoUpdate implements Schedulable {

	public void execute(SchedulableContext context) {
		System.enqueueJob(new CountryInfoUpdate());
	}
}
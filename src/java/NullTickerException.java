

public class NullTickerException extends Exception {
	
	public NullTickerException() {
		System.out.println("\n\nNo Ticker Entered\n\n");
		this.printStackTrace();
	}
	
}

package bin;









import java.io.IOException;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;




public class FinlOrder {

	SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMM dd, yyyy HH:mm:ss a");
	public int size				= 0;
	public FinlStock stock		= null;
	public double sharePrice 	= 0.0;
	public Date date = null;
	private String type;
	private boolean execute		= false;

	////////////////////////////////////////////
	//////////*FinlOrder Constructors*//////////
	////////////////////////////////////////////


	/* automatically executes */
	public FinlOrder(int size, FinlStock stock) {
		this.size = size;
		this.stock = stock;
	}

	public FinlOrder()	{	//constructor for building from PDF

	}

	//getters and setters//

	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	//gets whether the order has been executed
	public boolean getExecute() {
		return this.execute;
	}
	public void setExecute(boolean execute) {
		this.execute = execute;
	}
}

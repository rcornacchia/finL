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

	DateFormat dateFormat 		= new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	public int size				= 0;
	public FinlStock stock		= null;
	public double sharePrice 	= 0.0;
	public Date date 			= null;
	private boolean execute;


	public FinlOrder(int size, FinlStock stock, boolean execute) {
		this.execute = execute;
		this.size = size;
		this.stock = stock;

		if(this.execute) { 				//user wants to execute the order
			this.execute = false;		//now set execute to false (we havent yet executed)
			execute();
		}
		else this.execute = false;		//reiterate execute is false
	}

	public void execute() {
		if(!this.execute) {						//order hasnt been executed
			this.stock = this.stock.refresh();	//refresh stock price info
			this.sharePrice = this.stock.finlQuote.price.doubleValue();
			this.date = new Date();
			this.execute = true;				//execute to true (we've executed the order)
		}
		else if(this.execute) {	//order has been executed
			System.out.println("Order already executed!");
			return;			//do nothing
		}
	}
}

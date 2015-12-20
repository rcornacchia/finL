package bin;


import java.io.IOException;
import java.math.BigDecimal;
import java.util.Calendar;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;



public class FinlOrder {


	private int size;
	private FinlStock stock;
	private double sharePrice;
	private Calendar time;
	private boolean execute = false;


	public FinlOrder(int size, FinlStock stock, boolean execute) {
		this.size = size;
		this.stock = stock;

		if(execute) { 				//user wants to execute the order
			this.execute = false;	//set execute to false (we havent yet executed)
			execute();
		}
		else this.execute = false;
	}

	private void execute() {
		if(!execute) {		//order hasnt been executed
			this.stock = this.stock.refresh();	//refresh stock price info
			this.sharePrice = this.stock.finlQuote.price.doubleValue();
			this.time = Calendar.getInstance();
			this.execute = true;	//reset execute to true (we've executed the order)
		}
		else if(execute) {	//order has been executed
			return;			//do nothing
		}
	}
}

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
	public String type			= "buy";
	private boolean execute;

	////////////////////////////////////////////
	//////////*FinlOrder Constructors*//////////
	////////////////////////////////////////////


	/* automatically executes */
	public FinlOrder(int size, FinlStock stock) {

	}


	/* execute the order */
	/*    buy or sell    */
	public void execute() {
		if(size == 0) {
			System.out.println("wtf dude?");
			return;
		}
		else if(this.size > 0) {
			executeBuy();
		}
		else if(this.size < 0) {
			executeSell();
		}
	}

	/* executeSell() method */
	private void executeSell() {
		if(!this.execute) {						//order hasnt been executed
			this.stock = this.stock.refresh();	//refresh the stock info
			this.sharePrice = this.stock.finlQuote.price.doubleValue();
			this.date = new Date();
			this.execute = true;
		}
		else if(this.execute) {	//order has been executed
			System.err.println("Order already executed!\nNothing Done.");
			return;				//do nothing
		}
	}

	/* executeBuy() method */
	private void executeBuy() {
		if(!this.execute) {						//order hasnt been executed
			this.stock = this.stock.refresh();	//refresh stock price info
			this.sharePrice = this.stock.finlQuote.price.doubleValue();
			this.date = new Date();
			this.execute = true;				//execute to true (we've executed the order)
		}
		else if(this.execute) {	//order has been executed
			System.err.println("Order already executed!\nNothing Done.");
			return;				//do nothing
		}
	}

	//gets whether the order has been executed
	public boolean getExecuteStatus() {
		return this.execute;
	}
}

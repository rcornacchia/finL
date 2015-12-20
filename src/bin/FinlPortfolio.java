


package bin;




import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;


public class FinlPortfolio {

	ArrayList<FinlOrder> orders = new ArrayList<FinlOrder>();	//list of all orders
	ArrayList<Holding> holdings = new ArrayList<Holding>();		//list of all positions


	String userID;
	double accountCash;
	double accountValue;



	public FinlPortfolio() {

	}


	public void order(int size, String ticker, boolean execute) {
		FinlStock orderStock = new FinlStock(ticker);
		FinlOrder order = new FinlOrder(size, orderStock, execute);

	}

	public void order(int size, String ticker) {
		FinlStock orderStock = new FinlStock(ticker);
		FinlOrder order = new FinlOrder(size, orderStock);

		orders.add(order);	//add the order to the portfolio's list
		//this.Holding position = new this.Holding(order);

		}



	class Holding {

		public int size;
		public double avgPrice;
		public double pnl;
		public FinlStock stock;


		public Holding(FinlOrder order) {
			if(checkList(order)) {

			}

		}


		private boolean checkList(FinlOrder order) {
			for(int i = 0; i < holdings.size(); i++) {
				Holding listStock = holdings.get(i);
				if(listStock.stock.symbol.equals(order.stock.symbol)) {
					return true;	//stock is in the portfolio
				}
			}
			return false;			//stock is not in the portfolio
		}
	}



}

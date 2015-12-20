


package bin;





import java.io.IOException;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;


public class FinlPortfolio {

	DateFormat dateFormat 		= new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

	private ArrayList<FinlOrder> orders;		//list of all orders
	private ArrayList<FinlOrder> unexecutedOrders;
	private ArrayList<Holding> holdings;		//list of all positions

	double accountCash = 0.0;
	double accountValue = 0.0;



	public FinlPortfolio(double initialCash) {
		this.accountCash = initialCash;
		orders = new ArrayList<FinlOrder>();		//list of all orders
		unexecutedOrders = new ArrayList<FinlOrder>();	//all unexecuted orders
		holdings = new ArrayList<Holding>();		//list of all positions
	}


	public void order(int size, String ticker, boolean execute) {
		FinlStock orderStock = new FinlStock(ticker);
		FinlOrder order = new FinlOrder(size, orderStock, execute);
		double orderValue = orderStock.finlQuote.price.doubleValue() * size;

		if(accountCash < orderValue) {
			return;
		}
		else {
			if(execute) {
				orders.add(order);
				new FinlPortfolio.Holding(order);
			}
			else {
				unexecutedOrders.add(order);	//if the order is created but not executed,
			}									//add it to the unexecuted list
		}
	}	//end execute optional order() method

	public void order(int size, String ticker) {
		FinlStock orderStock = new FinlStock(ticker);
		double orderValue = orderStock.finlQuote.price.doubleValue() * size;

		if(accountCash < orderValue) {
			return;
		}
		else {
			FinlOrder order = new FinlOrder(size, orderStock);
			orders.add(order);	//add the order to the portfolio's list
			new FinlPortfolio.Holding(order);
			}
		}	//end order() method


	public void addCash(double amount) {
		accountCash += amount;
	}



	class Holding {

		public int positionSize;
		public double avgPrice;
		public double pnl;
		public Date lastOrder;
		public FinlStock stock;

		public Holding(FinlOrder order) {
			if(checkHoldings(order) == null) {	//if the portfolio doesnt contain the stock being ordered:
				generateNewHolding(order);
			}
			else {								//if the portfolio contains the stock being ordered:
				addToHolding(order);
			}
			checkUnexecutedHoldings();			//every time a new holding is added, also check to see
												//if any unexecuted orders have been executed

		}

		private void addToHolding(FinlOrder order) {

			this.avgPrice = (((Math.abs(this.positionSize))*this.avgPrice)	//weighted avg of holding's price
							+ (order.size*order.sharePrice))/2;	//and new order's price
			this.positionSize += order.size;
			this.pnl = (this.positionSize*order.sharePrice) 	//difference between the value of our position
						- (this.positionSize*this.avgPrice);	//now and what we paid for it
			this.lastOrder = order.date;
			this.stock = order.stock;

			accountValue += (order.size*order.sharePrice);
			//no need to add to the list
		}

		private void generateNewHolding(FinlOrder order) {
			this.positionSize = order.size;
			this.avgPrice = order.sharePrice;
			this.pnl = 0;
			this.lastOrder = order.date;
			this.stock = order.stock;

			accountValue += (this.avgPrice*this.positionSize);

			holdings.add(this);	//add this new holding to the list
		}

		private void checkUnexecutedHoldings() {
			for(int i = 0; i < unexecutedOrders.size(); i++) {
				FinlOrder order = unexecutedOrders.get(i);
				if(order.getExecuteStatus()) {
					new FinlPortfolio.Holding(order);
				}
			}
		}


		//checks if the stock is in the portfolio
		private Holding checkHoldings(FinlOrder order) {
			for(int i = 0; i < holdings.size(); i++) {
				Holding listStock = holdings.get(i);
				if(listStock.stock.symbol.equals(order.stock.symbol)) {
					return listStock;	//stock is in the portfolio
				}
			}
			return null;				//stock is not in the portfolio
		}
	}



}

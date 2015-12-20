


package bin;





import java.io.FileWriter;
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
	private ArrayList<Holding> holdings;		//list of all positions

	private double accountValue = 0.0;
	private String portfolioName = "defaultPortfolio";

	public FinlPortfolio() {

		orders = new ArrayList<FinlOrder>();		//list of all orders
		holdings = new ArrayList<Holding>();		//list of all positions
	}

	public void buy(FinlOrder order) {
		if(order.getExecute() == true) { //order has been executed
			System.err.println("Order already executed!\nNothing Done.");
			return;				//do nothing
		}
		order.setType("buy");
		order.stock.refresh();	//refresh stock information
		order.sharePrice = order.stock.finlQuote.ask.doubleValue();
		order.date = new Date();
		order.setExecute(true);
		orders.add(order);
		new FinlPortfolio.Holding(order);
	}

	public void sell(FinlOrder order) {
		if(order.getExecute() == true) { //order has been executed
			System.err.println("Order already executed!\nNothing Done.");
			return;				//do nothing
		}
		order.setType("sell");
		order.stock.refresh();
		order.sharePrice = order.stock.finlQuote.bid.doubleValue();
		order.date = new Date();
		order.setExecute(true);
		orders.add(order);
		new FinlPortfolio.Holding(order);
	}


	public void setPortfolioName(String name) {
		this.portfolioName = name;
	}

	public void csvExport(){
		try {
			String fileName = this.portfolioName;
			csvOrdersExport(fileName);
			csvHoldingsExport(fileName);


		} catch (IOException e) {
			System.err.println("\n\nSomething is wrong with the file"
					+ "export\n\n");
			e.printStackTrace();
		}
	}

	private void csvHoldingsExport(String fileName) throws IOException {
		fileName += "_holdings.csv";

		FileWriter writer = new FileWriter(fileName);

		writer.append("Portfolio Name: "); writer.append(",");
		writer.append(this.portfolioName); writer.append("\n");
		writer.append("Account Value: "); writer.append(",");
		writer.append(Double.toString(this.accountValue));
		writer.append("\n\n");

		writer.append("Stock Name"); writer.append(",");
		writer.append("Total Position Size"); writer.append(",");
		writer.append("Average Price"); writer.append(",");
		writer.append("Position P & L"); writer.append(",");
		writer.append("Last Execution Date"); writer.append("\n");

		for(int i = 0; i < holdings.size(); i++) {
			Holding listHolding = holdings.get(i);
			writer.append(listHolding.stock.symbol);
			writer.append(",");
			writer.append(Integer.toString(listHolding.positionSize));
			writer.append(",");
			writer.append(Double.toString(listHolding.avgPrice));
			writer.append(",");
			writer.append(Double.toString(listHolding.pnl));
			writer.append(",");
			writer.append(listHolding.lastOrder.toString());
			writer.append("\n");
		}
		writer.flush();
		writer.close();

	}


	public void csvOrdersExport(String fileName) throws IOException {
		fileName += "_orders.csv";

		FileWriter writer = new FileWriter(fileName);

		writer.append("Stock Name");
		writer.append(",");
		writer.append("Order Size");
		writer.append(",");
		writer.append("Execution Price");
		writer.append(",");
		writer.append("Execution Date");
		writer.append("\n");

		for(int i = 0; i < orders.size(); i++) {
			FinlOrder listOrder = orders.get(i);
			writer.append(listOrder.stock.symbol);
			writer.append(",");
			writer.append(Integer.toString(listOrder.size));
			writer.append(",");
			writer.append(Double.toString(listOrder.sharePrice));
			writer.append(",");
			writer.append(listOrder.date.toString());
			writer.append("\n");
		}
		writer.flush();
		writer.close();
	}

	class Holding {

		public int positionSize;
		public double percentOfPortfolio;
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
		}

		private void addToHolding(FinlOrder order) {

			if(order.getType().equals("sell"))
				this.positionSize -= order.size;
			else if (order.getType().equals("buy"))
				this.positionSize += order.size;
			else System.err.println("Order Type Not Set");


			this.avgPrice = (((Math.abs(this.positionSize))*this.avgPrice)	//weighted avg of holding's price
					+ (order.size*order.sharePrice))/2;						//and new order's price

			this.pnl = (this.positionSize*order.sharePrice) 	//difference between the value of our position
					- (this.positionSize*this.avgPrice);	//now and what we paid for it
			this.lastOrder = order.date;
			this.stock = order.stock;

			accountValue += (order.size*order.sharePrice);
			this.percentOfPortfolio = this.positionSize/accountValue;
			//no need to add to the list, order already exists and we are just modifying
		}

		private void generateNewHolding(FinlOrder order) {
			if(order.getType().equals("sell"))
				this.positionSize -= order.size;
			else if (order.getType().equals("buy"))
				this.positionSize += order.size;
			else System.err.println("Order Type Not Set");

			this.avgPrice = order.sharePrice;
			this.pnl = 0;
			this.lastOrder = order.date;
			this.stock = order.stock;
			accountValue += (this.avgPrice*this.positionSize);
			this.percentOfPortfolio = this.positionSize/accountValue;

			holdings.add(this);	//add this new holding to the list
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
	}	//end Holdings class
}

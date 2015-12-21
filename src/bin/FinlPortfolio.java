package bin;




import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.ParseException;
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

	public FinlPortfolio(String name) {
		this.setPortfolioName(name);
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

	public void updateCompositions() {
		for(int i = 0; i < holdings.size(); i++) {
			Holding listStock = holdings.get(i);
			listStock.percentOfPortfolio
				= Math.abs(listStock.positionValue/accountValue);
		}
	}


	public void printHoldings() {

		System.out.println("\n\n" + this.portfolioName
				+ "\n _______________________________________________________");
		System.out.format("|Account Value\t|\tPositions\t|\tTrades\t|\n|  $"
				+ "%.2f" + "\t|\t"
				+ this.holdings.size() + "\t\t|\t" + this.orders.size() +
				"\t|\n ––––––––––––––––––––––––––––––––––––––––––––––––––––––"
				+ "\n\n\n---------\nHoldings:\n---------\n",
				this.accountValue);

		for(int i = 0; i < holdings.size(); i++) {
			Holding listStock = holdings.get(i);
			System.out.println(listStock.stock.companyName
					+ "\n_______________________________");
			System.out.println("Symbol:\t\t" + listStock.stock.symbol);
			System.out.println("Total Shares:\t" + listStock.positionShares);
			System.out.format("Total Value:\t$%.2f\n", listStock.positionValue);
			System.out.format("Average Price:\t$%.2f\n", listStock.avgPrice);
			System.out.format("Position P&L:\t$%.2f\n", listStock.pnl);
			System.out.format("Weight:\t\t%.2f%%\n", listStock.percentOfPortfolio*100);
			System.out.println("Last Trade:\t" + listStock.lastOrder.toString()
			+ "\n_______________________________\n\n");
		}
		System.out.flush();
	}

	public void csvPortfolioBuilder() {
		String csvHoldings = "./defaultPortfolio_holdings.csv";
		String csvOrders = "./defaultPortfolio_orders.csv";

		BufferedReader holdingReader = null;
		BufferedReader orderReader = null;

		try {
			holdingReader = new BufferedReader(new FileReader(csvHoldings));
			orderReader = new BufferedReader(new FileReader(csvOrders));


			holdingImporter(this, holdingReader);
			orderImporter(this, orderReader);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NumberFormatException e) {
			System.err.println("Date Exception in CSV Importing");
		} catch (ParseException e) {
			System.err.println("Date Exception in CSV Importing");
		} finally {
			if (holdingReader != null) {
				try {
					holdingReader.close();
				} catch (IOException e) {
					System.err.println("IO Exception in CSV Importing");
				}
			}
			if (orderReader != null) {
				try {
					orderReader.close();
				} catch (IOException e) {
					System.err.println("IO Exception in CSV Importing");
				}
			}
		}
	}

	private BufferedReader holdingImporter(FinlPortfolio importedPortfolio,
			BufferedReader holdingReader) throws NumberFormatException, IOException, ParseException {

		int lineNum = 1;
		String line = "";
		String cvsSplitBy = ",";

		//build Portfolio: Holdings
		while ((line = holdingReader.readLine()) != null) {
			if(!(lineNum++ < 5)) {		//if the line is a header line, do this

				//create new holding object to put into Portfolio
				Holding holdingObject = new Holding();
				String[] arrayHolding = line.split(cvsSplitBy);							// use comma as separator

				String weightString = arrayHolding[5];
				//we multiplied by 100 to get to %, so we divide to get regular double for consistency
				double weight = Double.parseDouble(weightString.substring(0, weightString.length()-1))/100;

				holdingObject.stock = new FinlStock(arrayHolding[0]);					//stock
				holdingObject.positionShares = (int) (dollarToDouble(arrayHolding[1]));	//shares
				holdingObject.positionValue = dollarToDouble(arrayHolding[2]);			//value
				holdingObject.avgPrice = dollarToDouble(arrayHolding[3]);				//average price
				holdingObject.pnl = dollarToDouble(arrayHolding[4]);					//p&l

				//calculations above^
				holdingObject.percentOfPortfolio = weight;								//weight
				holdingObject.lastOrder = new Date(arrayHolding[6]);

				importedPortfolio.holdings.add(holdingObject);		//add the holding object to the holdings list

			}	//end build object
		}	//end holdings lister
		return holdingReader;
	}

	private BufferedReader orderImporter(FinlPortfolio importedPortfolio,
			BufferedReader orderReader) throws NumberFormatException, IOException, ParseException {

		int lineNum = 1;
		String line = "";
		String cvsSplitBy = ",";

		while ((line = orderReader.readLine()) != null) {
			if(!(lineNum++ < 2)) {		//if the line is a header line, do this

				//create new order Object to put into portfolio
				FinlOrder orderObject = new FinlOrder();

				String[] arrayOrder = line.split(cvsSplitBy);
				orderObject.stock = new FinlStock(arrayOrder[0]);			//stock ticker
				orderObject.setType(arrayOrder[1]);							//order type
				orderObject.size = Integer.parseInt(arrayOrder[2]);			//order size
				orderObject.sharePrice = dollarToDouble(arrayOrder[3]);		//execution price
				orderObject.date = new Date(arrayOrder[4]);

				importedPortfolio.orders.add(orderObject);
			}
		}
		return orderReader;
	}

	public double dollarToDouble(String s){
		String dollarRemoved = s.substring(1);
		double dollarRemovedDouble = Double.parseDouble(dollarRemoved);
		return dollarRemovedDouble;
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
		writer.append("$" + Double.toString(this.accountValue));
		writer.append("\n\n");

		writer.append("Stock Name"); writer.append(",");
		writer.append("Total Shares"); writer.append(",");
		writer.append("Total Value"); writer.append(",");
		writer.append("Average Price"); writer.append(",");
		writer.append("Position P & L"); writer.append(",");
		writer.append("Percent of Portfolio"); writer.append(",");
		writer.append("Last Execution Date"); writer.append("\n");

		for(int i = 0; i < holdings.size(); i++) {
			Holding listHolding = holdings.get(i);
			writer.append(listHolding.stock.symbol);
			writer.append(",");
			writer.append(Integer.toString(listHolding.positionShares));
			writer.append(",");
			writer.append("$" + Double.toString(listHolding.positionValue));
			writer.append(",");
			writer.append("$" + Double.toString(listHolding.avgPrice));
			writer.append(",");
			writer.append("$" + Double.toString(listHolding.pnl));
			writer.append(",");
			writer.append(Double.toString((listHolding.percentOfPortfolio)*100) + "%");
			writer.append(",");
			writer.append(listHolding.lastOrder.toString());
			writer.append("\n");
		}
		writer.flush();
		writer.close();

	}

	private void csvOrdersExport(String fileName) throws IOException {
		fileName += "_orders.csv";

		FileWriter writer = new FileWriter(fileName);

		writer.append("Stock Name"); writer.append(",");
		writer.append("Order Type"); writer.append(",");
		writer.append("Order Size"); writer.append(",");
		writer.append("Execution Price"); writer.append(",");
		writer.append("Execution Date");
		writer.append("\n");

		for(int i = 0; i < orders.size(); i++) {
			FinlOrder listOrder = orders.get(i);
			writer.append(listOrder.stock.symbol);
			writer.append(",");
			writer.append(listOrder.getType());
			writer.append(",");
			writer.append(Integer.toString(listOrder.size));
			writer.append(",");
			writer.append("$" + Double.toString(listOrder.sharePrice));
			writer.append(",");
			writer.append(listOrder.date.toString());
			writer.append("\n");
		}
		writer.flush();
		writer.close();
	}

	class Holding {

		public int positionShares;
		public double positionValue;
		public double percentOfPortfolio;
		public double avgPrice;
		public double pnl;
		public Date lastOrder;
		public FinlStock stock;

		private Holding(FinlOrder order) {
			Holding position = checkHoldings(order);
			if(position == null) 				//if the portfolio doesnt contain the stock being ordered:
				generateNewHolding(order);
			else {								//if the portfolio contains the stock being ordered:
				position.addToHolding(order);
			}
			updateCompositions();
		}

		private Holding() {						//used when importing from the csv

		}

		private void addToHolding(FinlOrder order) {
			int tempSize = Math.abs(this.positionShares);
			double tempAvg = this.avgPrice;


			if(order.getType().equals("sell"))
				this.positionShares -= order.size;
			else if (order.getType().equals("buy"))
				this.positionShares = this.positionShares + order.size;
			else System.err.println("Order Type Not Set");

			double weightedAverage = (((tempAvg * tempSize)
					+ (order.sharePrice * order.size)))/(tempSize + order.size);
			this.avgPrice = weightedAverage;					//and new order's price
			this.pnl = (this.positionShares * order.sharePrice) 	//difference between the value of our position
					- (this.positionShares * this.avgPrice);	//now and what we paid for it
			this.lastOrder = order.date;
			this.stock = order.stock;
			this.positionValue = this.avgPrice * this.positionShares;

			if(order.getType().equals("buy"))
				accountValue += (order.size * order.sharePrice);
			else if (order.getType().equals("sell"))
				accountValue += (order.size * order.sharePrice);

			this.percentOfPortfolio = Math.abs(this.positionValue/accountValue);

			//no need to add to the list, order already exists and we are just modifying
		}	//end addToHoldings()

		private void generateNewHolding(FinlOrder order) {
			if(order.getType().equals("sell"))
				this.positionShares -= order.size;
			else if (order.getType().equals("buy"))
				this.positionShares += order.size;
			else System.err.println("Order Type Not Set");

			this.avgPrice = order.sharePrice;
			this.pnl = 0;
			this.lastOrder = order.date;
			this.stock = order.stock;
			this.positionValue = this.avgPrice * this.positionShares;

			if(order.getType().equals("buy"))
				accountValue += (order.size * order.sharePrice);
			else if (order.getType().equals("sell"))
				accountValue += (order.size * order.sharePrice);

			this.percentOfPortfolio = Math.abs(this.positionValue/accountValue);
			holdings.add(this);	//add this new holding to the list
		}	//end generateNewHolding()

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

package bin;




import java.io.IOException;
import java.math.BigDecimal;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;




public class StockTester {

	public static void main(String[] args) {
		String ticker = "MSFT";
//		FinlPortfolio default_portfolio = new FinlPortfolio();
//		FinlStock stk;
//		stk = new FinlStock("TSLA");
//		String s;
//		s = stk.getRequest("price");
//		s = new FinlStock("AAPL").getRequest("price");
//		System.out.println(s);

		orderTest(ticker);

		FinlPortfolio testPortfolio = new FinlPortfolio();

		testPortfolio.csvPortfolioBuilder();

		testPortfolio.printHoldings();

		//portfolioTest(ticker);


	}	//end main()



	private static void portfolioTest(String ticker) {
		System.out.println("\n\n\n\n");
		FinlPortfolio testPortfolio = new FinlPortfolio();


		FinlOrder testOrder1 = new FinlOrder(10, new FinlStock(ticker));
		FinlOrder testOrder3 = new FinlOrder(20, new FinlStock(ticker));
		FinlOrder testOrder2 = new FinlOrder(10, new FinlStock("FB"));


		testPortfolio.buy(testOrder1);
		testPortfolio.buy(testOrder1);
		testPortfolio.buy(testOrder2);
		testPortfolio.buy(testOrder3);

		testPortfolio.csvExport();
		testPortfolio.printHoldings();


		//new FinlStock("AAPL").printStock();
	}

	private static void orderTest(String ticker) {
		FinlStock orderStock = new FinlStock(ticker);
		System.out.println(orderStock.symbol + "\n");

		FinlOrder testOrder1 = new FinlOrder(10, orderStock);
		FinlPortfolio testPortfolio = new FinlPortfolio();

		testPortfolio.buy(testOrder1);

		orderStock.printStock();
		testOrder1.printOrder();

	}


	private static void stockTest(String ticker) {
		FinlStock testStock = new FinlStock("DPZ");
		String result = testStock.getRequest("price");
		testStock.printStock();
		//System.out.println(result + "\n\n");
		//testStock.printStock();
		new FinlStock("DPZ").printStock();

	}


}


package bin;




import java.io.IOException;
import java.math.BigDecimal;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;




public class StockTester {

	public static void main(String[] args) {

		//method1();
		method2();

	}	//end main()


	private static void method1() {

		FinlPortfolio testPortfolio = new FinlPortfolio("test");

		testPortfolio.buy(new FinlOrder(10, new FinlStock("AAPL")));
		testPortfolio.buy(new FinlOrder(10, new FinlStock("FB")));
		testPortfolio.buy(new FinlOrder(10, new FinlStock("MSFT")));
		testPortfolio.buy(new FinlOrder(10, new FinlStock("TSLA")));
		testPortfolio.buy(new FinlOrder(10, new FinlStock("FB")));
		testPortfolio.buy(new FinlOrder(10, new FinlStock("MBLY")));

		testPortfolio.printHoldings();
		testPortfolio.csvExport();



	}


	private static void method2() {
		FinlPortfolio testPortfolio2 = new FinlPortfolio("default");
		testPortfolio2.csvPortfolioBuilder("test");

		testPortfolio2.printHoldings();
		//testPortfolio2.csvExport();

	}






	private static void portfolioTest(String ticker) {
		System.out.println("\n\n\n\n");
		FinlPortfolio testPortfolio = new FinlPortfolio("test2");


		FinlOrder testOrder1 = new FinlOrder(10, new FinlStock(ticker));
		FinlOrder testOrder3 = new FinlOrder(20, new FinlStock(ticker));
		FinlOrder testOrder2 = new FinlOrder(10, new FinlStock("FBs"));


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
		FinlPortfolio testPortfolio = new FinlPortfolio("test3");

		testPortfolio.buy(testOrder1);

		orderStock.printStock();
		testOrder1.printOrder();

	}

	private static void stockTest(String ticker) {
		FinlStock testStock1 = new FinlStock("DPZ");
		FinlStock testStock2 = new FinlStock("AAPL");
		double result1 = testStock1.getRequest("price");
		double result2 = testStock2.getRequest("price");

		if(result1 > result2) {
			testStock1.printStock();
		}
		else testStock2.printStock();
	}
}

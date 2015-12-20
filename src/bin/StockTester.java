
package bin;






import java.io.IOException;
import java.math.BigDecimal;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;




public class StockTester {

	public static void main(String[] args) {
		try {
			stockTest();
			orderTest();
			portfolioTest();
		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()



	private static void portfolioTest() {
		FinlPortfolio testPortfolio = new FinlPortfolio();


	}

	private static void orderTest() {
		FinlStock orderStock = new FinlStock("FB");
		FinlOrder testOrder = new FinlOrder(10, orderStock, false);
		FinlOrder testOrder2 = new FinlOrder(-10, orderStock, false);

		//buy
		int x = testOrder.size;
		String name = testOrder.stock.symbol;
		System.out.println(x);
		System.out.println(name);
		testOrder.execute();
		System.out.println("Date: " + testOrder.date);
		testOrder.execute();
		System.out.println("\n\n");

		//sell
		int y = testOrder2.size;
		String name2 = testOrder2.stock.symbol;
		System.out.println(y);
		System.out.println(name2);
		testOrder2.execute();
		System.out.println("Date: " + testOrder2.date);
		testOrder2.execute();
	}

	private static void stockTest() {
		FinlStock testStock = new FinlStock("DPZ");
		String result = testStock.getRequest("price");
		testStock.printStock();
		//System.out.println(result + "\n\n");
		//testStock.printStock();
		new FinlStock("DPZ").printStock();

	}


}

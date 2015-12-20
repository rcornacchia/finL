
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
			String ticker;
			String[] tickers
					= {"FB", "AAPL", "MSFT"};
			for(int i = 0; i < tickers.length; i++) {
				ticker = tickers[i];
				stockTest(ticker);
				orderTest(ticker);
				portfolioTest(ticker);
			}
		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()



	private static void portfolioTest(String ticker) {
		System.out.println("\n\n\n\n");
		FinlPortfolio testPortfolio = new FinlPortfolio();

		FinlOrder testOrder = new FinlOrder(10, new FinlStock("FB"));
		testPortfolio.buy(testOrder);

		FinlOrder testOrder2 = new FinlOrder(10, new FinlStock("AAPL"));
		testPortfolio.sell(testOrder2);

		testPortfolio.order(10, ticker);
		testPortfolio.order(50, ticker);
		testPortfolio.order(-20, ticker);
		testPortfolio.order(10, "FB");
		testPortfolio.order(50, "FB");
		testPortfolio.order(-20, "FB");

		try {
			testPortfolio.csvOrdersExport("test");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private static void orderTest(String ticker) {
		FinlStock orderStock = new FinlStock("FB");
		FinlOrder testOrder = new FinlOrder(10, orderStock);

		//buy
		int x = testOrder.size;
		String name = testOrder.stock.symbol;
		System.out.println(x);
		System.out.println(name);
		testOrder.execute();
		System.out.println("Date: " + testOrder.date);
		testOrder.execute();
		System.out.println("\n\n");
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

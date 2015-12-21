
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
			String ticker = "MSFT";
//			String[] tickers
//			= {"FB", "AAPL", "MSFT"};
//			for(int i = 0; i < tickers.length; i++) {
//				ticker = tickers[i];
//				//stockTest(ticker);
//				//orderTest(ticker);
//			}
			portfolioTest(ticker);

		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()



	private static void portfolioTest(String ticker) {
		System.out.println("\n\n\n\n");
		FinlPortfolio testPortfolio = new FinlPortfolio();


		FinlOrder testOrder1 = new FinlOrder(10, new FinlStock(ticker));
		FinlOrder testOrder2 = new FinlOrder(10, new FinlStock("FB"));


		testPortfolio.buy(testOrder1);
		testPortfolio.buy(testOrder1);
		testPortfolio.buy(testOrder2);

		//testPortfolio.csvExport();
		testPortfolio.printHoldings();


		//new FinlStock("AAPL").printStock();
	}

	private static void orderTest(String ticker) {
		FinlStock orderStock = new FinlStock("FB");
		System.out.println(orderStock.symbol + "\n");
		FinlOrder testOrder = new FinlOrder(10, orderStock);
		System.out.println(testOrder.stock.symbol);


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

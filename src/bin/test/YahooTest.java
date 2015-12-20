package bin.test;



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





		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()

	private static void orderTest() {

	}

	private static void stockTest() {
		FinlStock testStock = new FinlStock("DPZ");
		String result = testStock.getRequest("price");

		//System.out.println(result + "\n\n");
		//testStock.printStock();


		new FinlStock("DPZ");

	}


}

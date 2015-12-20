
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
		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()




	private static void orderTest() {
		FinlStock orderStock = new FinlStock("FB");
		FinlOrder testOrder = new FinlOrder(10, orderStock, false);

		int x = testOrder.size;
		String name = testOrder.stock.symbol;
		System.out.println(x);
		System.out.println(name);


		testOrder.execute();
		System.out.println("Date: " + testOrder.date);
		testOrder.execute();


	}

	private static void stockTest() {
		FinlStock testStock = new FinlStock("DPZ");
		String result = testStock.getRequest("price");

		//System.out.println(result + "\n\n");
		//testStock.printStock();


		new FinlStock("DPZ");

	}


}

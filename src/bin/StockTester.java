
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
			FinlStock testStock = new FinlStock("DPZ");
			String result = testStock.getRequest("price");

			System.out.println(result + "\n\n");
			testStock.printStock();
		} catch (NullPointerException NPE) {
			NPE.printStackTrace();
		}
	}	//end main()


}

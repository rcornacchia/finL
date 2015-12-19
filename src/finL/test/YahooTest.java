

package finL.test;

import java.io.IOException;
import java.math.BigDecimal;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;

public class YahooTest { 
	
	
	
	public static void main(String[] args) { 
		try {
			stockTest();
			fxTest();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
		
		
		
		
	}
	
	
	private static void fxTest() throws IOException {
		FxQuote usdeur = YahooFinance.getFx(FxSymbols.USDEUR);
		FxQuote usdgbp = YahooFinance.getFx("USDGBP=X");
		System.out.println(usdeur);
		System.out.println(usdgbp);
		
	}


	public static void stockTest() throws IOException { 
			Stock stock = YahooFinance.get("AAPL");
			BigDecimal price = stock.getQuote().getPrice();
			BigDecimal change = stock.getQuote().getChangeInPercent();
			BigDecimal peg = stock.getStats().getPeg();
			BigDecimal dividend = stock.getDividend().getAnnualYieldPercent();
			
			stock.print();
	}

		
}

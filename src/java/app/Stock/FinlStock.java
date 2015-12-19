

package bin.app.Stock;

import java.io.IOException;
import java.math.BigDecimal;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;

public class FinlStock { 
	
	
	/*////ticker////*/
	private String		symbol; 
	
	/*Quote & Prices*/
	/*////Prices////*/
	private BigDecimal 	price;
	private BigDecimal 	priceOpen;
	private BigDecimal 	pricePrevClose;
	private long	 	priceMA200;
	private BigDecimal	priceMA50;
	private BigDecimal	priceDayHigh;
	private BigDecimal	priceDayLow;	
	private BigDecimal	bid;
	private BigDecimal 	ask;
	private long	 	avgVolume;
	/*Price Movement*/
	private BigDecimal	change;			//change from current price to previous close
	private BigDecimal	changePercent;	//change from current price to previous close, in percent
	private BigDecimal	changeFromMA200;
	private BigDecimal	changeFromMA50;
	private BigDecimal	changeFromYearHigh;
	private BigDecimal	changeFromYearLow; 
	
	/*Fundamentals*/
	private BigDecimal 	bookValuePerShare;
	private BigDecimal 	ebitda;
	private BigDecimal	eps;
	private BigDecimal	epsEstimateCurrentYear;
	private BigDecimal	epsEstimateNextQuarter;
	private BigDecimal	epsEstimateNextYear;
	private BigDecimal	marketCap;
	private BigDecimal	oneYearTargetPrice; 
	private BigDecimal	pe; 
	private BigDecimal	peg;
	private BigDecimal	priceBook; 
	private BigDecimal	priceSales;
	private BigDecimal	revenue;
	private BigDecimal	roe;
	private long		sharesFloat; 
	private long		sharesOutstanding; 
	private long		sharesOwned;
	
	
	////////////////////////////////////////////
	//////////////*Constructors*////////////////
	////////////////////////////////////////////
	public FinlStock() throws NullTickerException {
		throw new NullTickerException();
	}
	
	public FinlStock(String ticker) throws IOException {
		yahoofinance.Stock stock = YahooFinance.get(ticker);
		populate(stock);
	}
	
	////////////////////////////////////////////
	//////////////*Stock Methods*///////////////
	////////////////////////////////////////////
	public void populate(Stock stock) throws IOException { 
		stock.getQuote();
		System.out.println(stock.toString());
		stock.print();
	}
	
	
	////////////////////////////////////////////
	////////////*Dividend SubClass*/////////////	
	////////////////////////////////////////////
	public class FinlDividend {
		private BigDecimal 	annualYield;
		private BigDecimal 	annualYieldPercent;
		private BigDecimal	exDivDate;
		private BigDecimal	payDate;

		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	public static void main(String[] args) {
		try {
			FinlStock finlTester = new FinlStock("BAC");
			FinlStock finlTester2 = new FinlStock();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NullTickerException NTE) {
			NTE.printStackTrace();
		}
	}
	
		
}

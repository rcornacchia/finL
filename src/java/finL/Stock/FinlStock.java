

package java.finL.Stock;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Calendar;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;

public class FinlStock { 
	
	
	/*////ticker////*/
	private String		symbol; 
	
	
	
	/*Fundamentals*/
	public BigDecimal 	bookValuePerShare;
	public BigDecimal 	ebitda;
	public BigDecimal	eps;
	public BigDecimal	epsEstimateCurrentYear;
	public BigDecimal	epsEstimateNextQuarter;
	public BigDecimal	epsEstimateNextYear;
	public BigDecimal	marketCap;
	public BigDecimal	oneYearTargetPrice; 
	public BigDecimal	pe; 
	public BigDecimal	peg;
	public BigDecimal	priceBook; 
	public BigDecimal	priceSales;
	public BigDecimal	revenue;
	public BigDecimal	roe;
	public long			sharesFloat; 
	public long			sharesOutstanding; 
	public long			sharesOwned;
	
	
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
	////////////*Quotes SubClass*/////////////	
	////////////////////////////////////////////
	public class FinlQuote { 
		
		/*Quote & Prices*/
		private StockQuote quote;
		/*////Prices////*/
		public BigDecimal 	price;
		public BigDecimal 	priceOpen;
		public BigDecimal 	pricePrevClose;
		public BigDecimal	priceMA200;
		public BigDecimal	priceMA50;
		public BigDecimal	priceDayHigh;
		public BigDecimal	priceDayLow;	
		public BigDecimal	bid;
		public BigDecimal 	ask;
		public long	 		avgVolume;
		/*Price Movement*/
		public BigDecimal	change;			//change from current price to previous close
		public BigDecimal	changePercent;	//change from current price to previous close, in percent
		public BigDecimal	changeFromMA200;
		public BigDecimal	changeFromMA50;
		public BigDecimal	changeFromYearHigh;
		public BigDecimal	changeFromYearLow; 
		
		public FinlQuote(String symbol) {
			yahoofinance.Stock stock = new Stock(symbol);
			quote = stock.getQuote();
			this.populatePrice();
			this.populateMovement();
		}	//end constructor FinlQuote(String symbol)
		
		public FinlQuote(Stock stock) {
			quote = stock.getQuote();
			this.populatePrice();
			this.populateMovement();
		}	//end constructor FinlQuote(String symbol)

		private void populatePrice() {
			price = this.quote.getPrice();
			priceOpen = this.quote.getOpen();
			pricePrevClose = this.quote.getPreviousClose();
			priceMA200 = this.quote.getPriceAvg200();
			priceMA50 = this.quote.getPriceAvg50();
			priceDayHigh = this.quote.getDayHigh();
			priceDayLow = this.quote.getDayLow();
			bid = this.quote.getBid();
			ask = this.quote.getAsk();
			avgVolume = this.quote.getAvgVolume();
		}	//end populatePrice()
		
		private void populateMovement() {
			change = this.quote.getChange();
			changePercent = this.quote.getChangeInPercent();
			changeFromMA200 = this.quote.getChangeFromAvg200();
			changeFromMA50 = this.quote.getChangeFromAvg50();
			changeFromYearHigh = this.quote.getChangeFromYearHigh();
			changeFromYearLow = this.quote.getChangeFromYearLow();
		}	//end populateMovement()

		
		
	}
	
	
	////////////////////////////////////////////
	////////////*Dividend SubClass*/////////////	
	////////////////////////////////////////////
	public class FinlDividend {

		/*Dividend Data*/
		private StockDividend dividend;
		
		public BigDecimal 	annualYield;
		public BigDecimal 	annualYieldPercent;
		public Calendar	exDivDate;
		public Calendar	payDate;
		public String 		exDivDate_String;
		public String 		payDate_String;

		/*Pass a Stock Object*/
		public FinlDividend(Stock stock) { 
			StockDividend dividend 	= stock.getDividend();
			
			annualYield 			= this.dividend.getAnnualYield();
			annualYieldPercent 		= this.dividend.getAnnualYieldPercent();
			exDivDate 				= this.dividend.getExDate();
			payDate 				= this.dividend.getPayDate();
			exDivDate_String 		= this.exDivDate.toString();
			payDate_String 			= this.payDate.toString();
		}	//end constructor FinlDividend(Stock stock)
		
		/*Pass a Stock Symbol*/
		public FinlDividend(String symbol) {
			yahoofinance.Stock stock = new Stock(symbol);
			StockDividend dividend 	= stock.getDividend();
			
			annualYield 			= this.dividend.getAnnualYield();
			annualYieldPercent 		= this.dividend.getAnnualYieldPercent();
			exDivDate 				= this.dividend.getExDate();
			payDate 				= this.dividend.getPayDate();
			exDivDate_String 		= this.exDivDate.toString();
			payDate_String 			= this.payDate.toString();
		}	//end constructor FinlDividend(String symbol)
	} 	//end dividend subclass
	
	
	
	
	
	
	
	
	
	
	
	
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

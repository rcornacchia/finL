package bin;


import java.io.IOException;
import java.io.PrintStream;
import java.math.BigDecimal;
import java.util.Calendar;

import yahoofinance.YahooFinance;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;

public class FinlStock {

	public String symbol;
	public String companyName;
	public boolean valid = true;	//valid stock

	private yahoofinance.Stock stock;
	public FinlQuote finlQuote;
	public FinlFundamentals finlFundamentals;
	public FinlDividend finlDividend;

	////////////////////////////////////////////
	//////////*FinlStock Constructor*///////////
	///////////Gets all sub-objects/////////////
	public FinlStock(String ticker) {
		setStock(ticker);
		if(this.stock.getName().equals("N/A")) {
			System.err.println(ticker + " Not Found!");
			this.valid = false;
		}

		this.finlQuote 					= new FinlStock.FinlQuote(stock);
		this.finlFundamentals 			= new FinlStock.FinlFundamentals(stock);
		this.finlDividend 				= new FinlStock.FinlDividend(stock);
	}

	private void setStock(String ticker) {
		try{
			this.symbol = ticker;

			PrintStream defaultOutputStream = System.out;	//save output stream
			System.setOut(null);							//redirect console output
			this.stock = YahooFinance.get(this.symbol);		//assign stock w/ suppressed output
			this.companyName = this.stock.getName();
			System.setOut(defaultOutputStream);				//reset output stream to default

		} catch (IOException IOE) {
			IOE.printStackTrace();
		}
	}

	public FinlStock refresh() {
		return new FinlStock(this.symbol);
	}

	public void printStock() {
		this.stock.print();
	}

	/* Ocaml request parser */
	public double getRequest(String request) {
		if(!this.valid) {
			System.err.println("Stock Is Not Valid!");
			return 0;
		}
		double result;
		try {
			result = this.finlFundamentals.fundamentalCheck(request);
			if(result != 0)
				return result;
			result = this.finlQuote.quoteCheck(request);
			if(result != 0)
				return result;
			result = this.finlDividend.dividendCheck(request);
			if(result != 0)
				return result;
		} catch (NullPointerException NTE) {
			System.err.println("Error!");
			NTE.printStackTrace();
			return 0.0;
		}
		return result;
	}


	////////////////////////////////////////////
	//////////*Fundamentals SubClass*///////////
	////////////////////////////////////////////
	public class FinlFundamentals {

		/*Fundamentals Object*/
		private StockStats fundamentals;

		/*Fundamentals*/
		public BigDecimal 	bookValuePerShare;
		public BigDecimal 	ebitda;
		public BigDecimal	eps;
		public BigDecimal	marketCap;
		public BigDecimal	pe;
		public BigDecimal	peg;
		public BigDecimal	priceBook;
		public BigDecimal	priceSales;
		public BigDecimal	revenue;
		public BigDecimal	roe;
		public BigDecimal	sharesFloat;
		public BigDecimal	sharesOutstanding;

		/*Estimates*/
		public BigDecimal	epsEstimateCurrentYear;
		public BigDecimal	epsEstimateNextQuarter;
		public BigDecimal	epsEstimateNextYear;
		public BigDecimal	oneYearTargetPrice;

		////////////////////////////////////////////
		//////////////*Constructors*////////////////
		////////////////////////////////////////////

		public FinlFundamentals(yahoofinance.Stock stock) {
			fundamentals = stock.getStats();
			this.populateStatistics();
			this.populateEstimates();
		}	//end constructor FinlQuote(String symbol)

		private void populateStatistics() {
			bookValuePerShare 	= this.fundamentals.getBookValuePerShare();
			ebitda 				= this.fundamentals.getEBITDA();
			eps 				= this.fundamentals.getEps();
			marketCap 			= this.fundamentals.getMarketCap();
			pe 					= this.fundamentals.getPe();
			peg 				= this.fundamentals.getPeg();
			priceBook 			= this.fundamentals.getPriceBook();
			priceSales 			= this.fundamentals.getPriceSales();
			revenue 			= this.fundamentals.getRevenue();
			roe 				= this.fundamentals.getROE();
			sharesFloat 		= BigDecimal.valueOf(this.fundamentals.getSharesFloat());
			sharesOutstanding 	= BigDecimal.valueOf(this.fundamentals.getSharesOutstanding());

		}	//end populateStatistics()

		private void populateEstimates() {
			epsEstimateCurrentYear 	= this.fundamentals.getEpsEstimateCurrentYear();
			epsEstimateNextQuarter 	= this.fundamentals.getEpsEstimateNextQuarter();
			epsEstimateNextYear		= this.fundamentals.getEpsEstimateNextYear();
			oneYearTargetPrice		= this.fundamentals.getOneYearTargetPrice();
		}	//end populateEstimates()

		private double fundamentalCheck(String request) {
			if(request.equalsIgnoreCase("bookValuePerShare"))
				return this.bookValuePerShare.doubleValue();
			else if(request.equalsIgnoreCase("ebitda"))
				return this.ebitda.doubleValue();
			else if(request.equalsIgnoreCase("eps"))
				return this.eps.doubleValue();
			else if(request.equalsIgnoreCase("marketCap"))
				return this.marketCap.doubleValue();
			else if(request.equalsIgnoreCase("pe"))
				return this.pe.doubleValue();
			else if(request.equalsIgnoreCase("peg"))
				return this.peg.doubleValue();
			else if(request.equalsIgnoreCase("priceBook"))
				return this.priceBook.doubleValue();
			else if(request.equalsIgnoreCase("priceSales"))
				return this.priceSales.doubleValue();
			else if(request.equalsIgnoreCase("revenue"))
				return this.revenue.doubleValue();
			else if(request.equalsIgnoreCase("roe"))
				return this.roe.doubleValue();
			else if(request.equalsIgnoreCase("sharesFloat"))
				return this.sharesFloat.doubleValue();
			else if(request.equalsIgnoreCase("sharesOutstanding"))
				return this.sharesOutstanding.doubleValue();
			else if(request.equalsIgnoreCase("epsEstimateCurrentYear"))
				return this.epsEstimateCurrentYear.doubleValue();
			else if(request.equalsIgnoreCase("epsEstimateNextQuarter"))
				return this.epsEstimateNextQuarter.doubleValue();
			else if(request.equalsIgnoreCase("epsEstimateNextYear"))
				return this.epsEstimateNextYear.doubleValue();
			else if(request.equalsIgnoreCase("oneYearTargetPrice"))
				return this.oneYearTargetPrice.doubleValue();
			else return 0.0;
		}	//end fundamentalsCheck()
	}

	////////////////////////////////////////////
	////////////*Quotes SubClass*/////////////
	////////////////////////////////////////////
	public class FinlQuote {

		/*Quote & Prices*/
		private StockQuote 	quote;
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
		public BigDecimal	avgVolume;
		/*Price Movement*/
		public BigDecimal	change;			//change from current price to previous close
		public BigDecimal	changePercent;	//change from current price to previous close, in percent
		public BigDecimal	changeFromMA200;
		public BigDecimal	changeFromMA50;
		public BigDecimal	changeFromYearHigh;
		public BigDecimal	changeFromYearLow;


		////////////////////////////////////////////
		//////////////*Constructors*////////////////
		////////////////////////////////////////////

		public FinlQuote(yahoofinance.Stock stock) {
			quote = stock.getQuote();
			this.populatePrice();
			this.populateMovement();
		}	//end constructor FinlQuote(String symbol)

		////////////////////////////////////////////
		/////////////*Populate Methods*/////////////
		////////////////////////////////////////////
		private void populatePrice() {
			price 				= this.quote.getPrice();
			priceOpen 			= this.quote.getOpen();
			pricePrevClose 		= this.quote.getPreviousClose();
			priceMA200 			= this.quote.getPriceAvg200();
			priceMA50 			= this.quote.getPriceAvg50();
			priceDayHigh 		= this.quote.getDayHigh();
			priceDayLow 		= this.quote.getDayLow();
			bid 				= this.quote.getBid();
			ask 				= this.quote.getAsk();
			avgVolume 			= BigDecimal.valueOf(this.quote.getAvgVolume());
		}	//end populatePrice()

		private void populateMovement() {
			change 				= this.quote.getChange();
			changePercent 		= this.quote.getChangeInPercent();
			changeFromMA200 	= this.quote.getChangeFromAvg200();
			changeFromMA50 		= this.quote.getChangeFromAvg50();
			changeFromYearHigh 	= this.quote.getChangeFromYearHigh();
			changeFromYearLow 	= this.quote.getChangeFromYearLow();
		}	//end populateMovement()

		public double quoteCheck(String request) {
			if(request.equalsIgnoreCase("price"))
				return this.price.doubleValue();
			else if(request.equalsIgnoreCase("priceOpen"))
				return this.priceOpen.doubleValue();
			else if(request.equalsIgnoreCase("pricePrevClose"))
				return this.pricePrevClose.doubleValue();
			else if(request.equalsIgnoreCase("priceMA200"))
				return this.priceMA200.doubleValue();
			else if(request.equalsIgnoreCase("priceMA50"))
				return this.priceMA50.doubleValue();
			else if(request.equalsIgnoreCase("priceDayHigh"))
				return this.priceDayHigh.doubleValue();
			else if(request.equalsIgnoreCase("priceDayLow"))
				return this.priceDayLow.doubleValue();
			else if(request.equalsIgnoreCase("bid"))
				return this.bid.doubleValue();
			else if(request.equalsIgnoreCase("avgVolume"))
				return this.avgVolume.doubleValue();
			else if(request.equalsIgnoreCase("change"))
				return this.change.doubleValue();
			else if(request.equalsIgnoreCase("changePercent"))
				return this.changePercent.doubleValue();
			else if(request.equalsIgnoreCase("changeFromMA200"))
				return this.changeFromMA200.doubleValue();
			else if(request.equalsIgnoreCase("changeFromMA50"))
				return this.changeFromMA50.doubleValue();
			else if(request.equalsIgnoreCase("changeFromYearHigh"))
				return this.changeFromYearHigh.doubleValue();
			else if(request.equalsIgnoreCase("changeFromYearLow"))
				return this.changeFromYearLow.doubleValue();
			else return 0.0;
		}	//end quoteCheck()
	}	//end FinlQuote subclass

	////////////////////////////////////////////
	////////////*Dividend SubClass*/////////////
	////////////////////////////////////////////
	public class FinlDividend {

		/*Dividend Object*/
		private StockDividend dividend;

		/*Dividend Data*/
		public BigDecimal 	annualYield;
		public BigDecimal 	annualYieldPercent;
		public Calendar	exDivDate;
		public Calendar	payDate;
		public String 		exDivDate_String;
		public String 		payDate_String;

		/*Pass a Stock Object*/
		public FinlDividend(yahoofinance.Stock stock) {
			dividend 				= stock.getDividend();

			annualYield 			= this.dividend.getAnnualYield();
			annualYieldPercent 		= this.dividend.getAnnualYieldPercent();
			exDivDate 				= this.dividend.getExDate();
			payDate 				= this.dividend.getPayDate();
		}	//end constructor FinlDividend(Stock stock)

		public double dividendCheck(String request) {
			if(request.equalsIgnoreCase("annualYield"))
				return this.annualYield.doubleValue();
			else if(request.equalsIgnoreCase("annualYieldPercent"))
				return this.annualYieldPercent.doubleValue();
//			else if(request.equalsIgnoreCase("payDate"))
//				return this.payDate.toString();
//			else if(request.equalsIgnoreCase("exDivDate"))
//				return this.exDivDate.toString();
			else return 0.0;
		}	//end dividendCheck()
	} 	//end FinlDividend subclass
}	//End FinlStock.java

package bin;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Calendar;

import yahoofinance.Stock;
import yahoofinance.YahooFinance;
import yahoofinance.quotes.fx.FxQuote;
import yahoofinance.quotes.fx.FxSymbols;
import yahoofinance.quotes.stock.StockDividend;
import yahoofinance.quotes.stock.StockQuote;
import yahoofinance.quotes.stock.StockStats;

public class FinlStock {

	public String symbol;

	private yahoofinance.Stock stock;
	public FinlQuote finlQuote;
	public FinlFundamentals finlFundamentals;
	public FinlDividend finlDividend;

	////////////////////////////////////////////
	//////////*FinlStock Constructor*///////////
	///////////Gets all sub-objects/////////////
	public FinlStock(String ticker) {

		try {
			this.symbol 					= ticker;
			this.stock					 	= YahooFinance.get(symbol);

			this.finlQuote 					= new FinlStock.FinlQuote(stock);
			this.finlFundamentals 			= new FinlStock.FinlFundamentals(stock);
			this.finlDividend 				= new FinlStock.FinlDividend(stock);

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void printStock() {
		this.stock.print();
	}

	/* Ocaml request parser */
	public String getRequest(String request) {
		String result;
		try {
			result = this.finlFundamentals.fundamentalCheck(request);
			if(result != null)
				return result;
			result = this.finlQuote.quoteCheck(request);
			if(result != null)
				return result;
			result = this.finlDividend.dividendCheck(request);
			if(result != null)
				return result;
		} catch (NullPointerException NTE) {
			result = null;
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
		public long			sharesFloat;
		public long			sharesOutstanding;

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
			sharesFloat 		= this.fundamentals.getSharesFloat();
			sharesOutstanding 	= this.fundamentals.getSharesOutstanding();

		}	//end populateStatistics()

		private void populateEstimates() {
			epsEstimateCurrentYear 	= this.fundamentals.getEpsEstimateCurrentYear();
			epsEstimateNextQuarter 	= this.fundamentals.getEpsEstimateNextQuarter();
			epsEstimateNextYear		= this.fundamentals.getEpsEstimateNextYear();
			oneYearTargetPrice		= this.fundamentals.getOneYearTargetPrice();
		}	//end populateEstimates()

		private String fundamentalCheck(String request) {
			if(request.equalsIgnoreCase("bookValuePerShare"))
				return this.bookValuePerShare.toString();
			else if(request.equalsIgnoreCase("ebitda"))
				return this.ebitda.toString();
			else if(request.equalsIgnoreCase("eps"))
				return this.eps.toString();
			else if(request.equalsIgnoreCase("marketCap"))
				return this.marketCap.toString();
			else if(request.equalsIgnoreCase("pe"))
				return this.pe.toString();
			else if(request.equalsIgnoreCase("peg"))
				return this.peg.toString();
			else if(request.equalsIgnoreCase("priceBook"))
				return this.priceBook.toString();
			else if(request.equalsIgnoreCase("priceSales"))
				return this.priceSales.toString();
			else if(request.equalsIgnoreCase("revenue"))
				return this.revenue.toString();
			else if(request.equalsIgnoreCase("roe"))
				return this.roe.toString();
			else if(request.equalsIgnoreCase("sharesFloat"))
				return Long.toString(this.sharesFloat);
			else if(request.equalsIgnoreCase("sharesOutstanding"))
				return Long.toString(this.sharesOutstanding);
			else if(request.equalsIgnoreCase("epsEstimateCurrentYear"))
				return this.epsEstimateCurrentYear.toString();
			else if(request.equalsIgnoreCase("epsEstimateNextQuarter"))
				return this.epsEstimateNextQuarter.toString();
			else if(request.equalsIgnoreCase("epsEstimateNextYear"))
				return this.epsEstimateNextYear.toString();
			else if(request.equalsIgnoreCase("oneYearTargetPrice"))
				return this.oneYearTargetPrice.toString();
			else return null;
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
		public long	 		avgVolume;
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
			avgVolume 			= this.quote.getAvgVolume();
		}	//end populatePrice()

		private void populateMovement() {
			change 				= this.quote.getChange();
			changePercent 		= this.quote.getChangeInPercent();
			changeFromMA200 	= this.quote.getChangeFromAvg200();
			changeFromMA50 		= this.quote.getChangeFromAvg50();
			changeFromYearHigh 	= this.quote.getChangeFromYearHigh();
			changeFromYearLow 	= this.quote.getChangeFromYearLow();
		}	//end populateMovement()

		public String quoteCheck(String request) {
			if(request.equalsIgnoreCase("price"))
				return this.price.toString();
			else if(request.equalsIgnoreCase("priceOpen"))
				return this.priceOpen.toString();
			else if(request.equalsIgnoreCase("pricePrevClose"))
				return this.pricePrevClose.toString();
			else if(request.equalsIgnoreCase("priceMA200"))
				return this.priceMA200.toString();
			else if(request.equalsIgnoreCase("priceMA50"))
				return this.priceMA50.toString();
			else if(request.equalsIgnoreCase("priceDayHigh"))
				return this.priceDayHigh.toString();
			else if(request.equalsIgnoreCase("priceDayLow"))
				return this.priceDayLow.toString();
			else if(request.equalsIgnoreCase("bid"))
				return this.bid.toString();
			else if(request.equalsIgnoreCase("avgVolume"))
				return Long.toString(this.avgVolume);
			else if(request.equalsIgnoreCase("change"))
				return this.change.toString();
			else if(request.equalsIgnoreCase("changePercent"))
				return this.changePercent.toString();
			else if(request.equalsIgnoreCase("changeFromMA200"))
				return this.changeFromMA200.toString();
			else if(request.equalsIgnoreCase("changeFromMA50"))
				return this.changeFromMA50.toString();
			else if(request.equalsIgnoreCase("changeFromYearHigh"))
				return this.changeFromYearHigh.toString();
			else if(request.equalsIgnoreCase("changeFromYearLow"))
				return this.changeFromYearLow.toString();
			else return null;
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
			exDivDate_String 		= this.exDivDate.toString();
			payDate_String 			= this.payDate.toString();
		}	//end constructor FinlDividend(Stock stock)

		public String dividendCheck(String request) {
			if(request.equalsIgnoreCase("annualYield"))
				return this.annualYield.toString();
			else if(request.equalsIgnoreCase("annualYieldPercent"))
				return this.annualYieldPercent.toString();
			else if(request.equalsIgnoreCase("payDate"))
				return this.payDate.toString();
			else if(request.equalsIgnoreCase("exDivDate"))
				return this.exDivDate.toString();
			else if(request.equalsIgnoreCase("payDate"))
				return this.payDate.toString();
			else return null;
		}	//end dividendCheck()
	} 	//end FinlDividend subclass




}	//End FinlStock.java

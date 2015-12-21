package bin;






import java.text.SimpleDateFormat;
import java.util.Date;




public class FinlOrder {

	public int size				= 0;
	public FinlStock stock		= null;
	public double sharePrice 	= 0.0;
	public Date date = null;
	private String type;
	private boolean execute		= false;

	////////////////////////////////////////////
	//////////*FinlOrder Constructors*//////////
	////////////////////////////////////////////


	/* automatically executes */
	public FinlOrder(int size, FinlStock stock) {
		this.size = size;
		this.stock = stock;
		if(!this.stock.valid) {		//stock is not a valid stock
			this.execute = true;	//order cannot be executed
		}
	}

	public FinlOrder()	{	//constructor for building from PDF

	}

	public void printOrder() {
		if(this.execute) {
			System.out.println("\n\n" + this.stock.companyName
					+ " (" + this.type.toUpperCase() + " Order Executed)"
					+ "\n_______________________________\n");
			System.out.println("Symbol:\t\t\t" + this.stock.symbol);
			System.out.println("Order Size Value:\t" + this.size);
			System.out.format("Execution Price:\t$%.2f\n", this.sharePrice);
			System.out.println("Trade Date:\t\t" + this.date.toString()
			+ "\n_______________________________\n\n");
		}
		else {
			System.out.println("\n\n" + this.stock.companyName
					+ "(Order Not Yet Executed)"
					+ "\n_______________________________\n");
			System.out.println("Symbol:\t\t\t" + this.stock.symbol);
			System.out.println("Order Size Value:\t" + this.size);
			System.out.println("Order Type:\t\tOrder Not Yet Executed");
			System.out.println("Execution Price:\tOrder Not Yet Executed");
			System.out.println("Trade Date:\t\tOrder Not Yet Executed"
					+ "\n_______________________________\n\n");
		}
		System.out.flush();
	}

	//getters and setters//

	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	//gets whether the order has been executed
	public boolean getExecute() {
		return this.execute;
	}
	public void setExecute(boolean execute) {
		this.execute = execute;
	}



}

package bin;

public class WhenLoop implements Runnable { 

	String stock1;
	String stock2;
	String operator;

	public WhenLoop(String stk1, String op, String stk2) {
		this.stock1 = stk1;
		this.stock2 = stk2;
		this.operator = op;
	}

	public void run() {
	
		System.out.println(this.operator);
	}

}
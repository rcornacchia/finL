package bin;

public class WhenLoop implements Runnable { 

	private boolean conditional;

	public WhenLoop(boolean c) {
		this.conditional = c;
	}

	public void run() {
		System.out.println(this.conditional);
	}

}
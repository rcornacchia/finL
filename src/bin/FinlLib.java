package bin;

public class FinlLib { 

	public static boolean num_to_boolean(int x) {
		if (x != 0) { return true; } else { return false; }
	}

	public static boolean num_to_boolean(double x) { 
		if (x != 0) { return true; } else { return false; }
	}

	public static int boolean_to_int(boolean b) {
		if (b) { return 1; } else { return 0; }
	}

	public static boolean compare_strings(String s1, String op, String s2) {
		if (s1.equals(s2)) {
			switch (op) {
				case "==":return true;
				case "<":return false; 
				case "<=":return true;
				case ">":return false;
				case ">=":return true;
			}
		} else {
			switch (op) {
				case "==":return false;
				case "<": if (s1.compareTo(s2) < 0) { return false; } else { return true; }
				case "<=": if (s1.compareTo(s2) < 0) { return false; } else { return true; }
				case ">":if (s1.compareTo(s2) > 0) { return false; } else { return true; }
				case ">=":if (s1.compareTo(s2) > 0) { return false; } else { return true; }
			}
		}
		return false;
	}

}
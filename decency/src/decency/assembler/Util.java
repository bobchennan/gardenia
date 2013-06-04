package decency.assembler;

public class Util {
	// convert num to binary with certain width.
	public static String widen(int num, int width) {
		String s = Integer.toBinaryString(num);
		return new String(s.substring(s.length() - width));// TO DO
	}

	// add 0 to the end of string until the length of string is 32.
	public static String widen(String s, int width) {
		StringBuffer sb = new StringBuffer(s);
		for (int i = s.length(); i < width; ++i)
			sb.append("0");
		return sb.toString();// TO DO
	}
}

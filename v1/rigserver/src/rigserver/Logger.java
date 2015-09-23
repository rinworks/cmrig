package rigserver;

import java.io.FileNotFoundException;
import java.io.PrintStream;

public class Logger {
	private static PrintStream output;

	public static void setupConsole() {
		output = System.out;
	}

	public static void setupFile(String name) throws FileNotFoundException {
		output = new PrintStream(name);
	}
	
	public static void log(String arg) {
		output.print(arg);
	}
	
	public static void logln(String arg) {
		output.println(arg);
	}

	public static void logln() {
		output.println();
	}
}

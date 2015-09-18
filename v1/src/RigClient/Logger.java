import java.io.*;
import java.text.*;
import java.util.*;

public class Logger {
  public static final int CONSOLE = 0;
  public static final int FILE = 1;
  
  public static final SimpleDateFormat FORMAT = new SimpleDateFormat("yyyyMMdd-HH:mm:ss");
  
  private static PrintStream output;
  
  public static void setup(int out) {
    switch(out) {
      case FILE:
        Date d = new Date();
        String file = FORMAT.format(d);
        try {
          output = new PrintStream(file + ".txt");
          break;
        } catch (FileNotFoundException ignored) {}
      case CONSOLE:
      default:
        output = System.out;
    }
  }
}
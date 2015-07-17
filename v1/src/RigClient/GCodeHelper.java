public class GCodeHelper {
  public static final String GO_TO_HOME = "G28 X Y\n";
  public static final String WAIT_FOR_FINISH = "G4 P0\n";
  public static final String MOVE_PREFIX = "G0";
  public static final String WAIT_PREFIX = "G4";

  /**
   * Parses the passed-in G code to establish how many lines of g codes there
   * are, and splits the code by line.
   * 
   * @param gCode
   * @param lineBreak
   */
  public static String[] parseGCode(String gCode, String lineBreak) {
    if (gCode.endsWith(lineBreak))
      gCode = gCode.substring(0, gCode.length() - 1); // gets rid of
                              // trailing \n for
                              // split

    String[] lines = gCode.split(lineBreak);
    for (int i = 0; i < lines.length; i++) {
      lines[i] += lineBreak;
    }

    return lines;
  }

  public static String getMoveGCode(float x, float y) {
    String xS = String.format("%.2f", x);
    String yS = String.format("%.2f", y);
    return MOVE_PREFIX + " X" + xS + " Y" + yS + "\n";
  }

  public static String getWaitGCode(int mil) {
    return WAIT_PREFIX + " P" + mil + "\n";
  }
}


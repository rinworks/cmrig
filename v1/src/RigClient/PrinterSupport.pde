public enum PrinterType {
  PRINTRBOT, ROSTOCKMAX
}

public enum SerialResponse {
  SUCCESS, WAIT, FAIL
}

public interface PrinterHelper {
  public String initialize();
  public String waitForFinish();
  public boolean positionValid(float x, float y);
  public SerialResponse handleRx(String rxString);
}

public class PrintrBotHelper implements PrinterHelper {
  public static final float X_BOUND = 152.4f;
  public static final float Y_BOUND = 152.4f;
  
  public String initialize() {
    return "G28 X Y\n";
  }
  
  // TODO: Is this really necessary?
  public String waitForFinish() {
    return "G4 P0\n";
  }
  
  public boolean positionValid(float x, float y) {
    boolean xOkay = x >= 0 && x <= X_BOUND;
    boolean yOkay = y >= 0 && y <= Y_BOUND;
    return xOkay && yOkay;
  }
  
  public SerialResponse handleRx(String rxString) {
    if(rxString.contains(SerialRig.OK)) { // line completed
      return SerialResponse.SUCCESS;
    } else {
      return SerialResponse.FAIL;
    }
  }
  
  public float matrixWidth() {
    return X_BOUND;
  }
  
  public float matrixHeight() {
    return Y_BOUND;
  }
}

public class RostockMaxHelper implements PrinterHelper {
  private static final int Z_OFFSET = 50;
  
  public static final float BED_RADIUS = 120f;
  public static final float BUFFER = 10f;
  
  public String initialize() {
    String home = "G28 X0 Y0 Z0\n";
    String setZ = GCodeHelper.REL_MOVEMENT
      + GCodeHelper.MOVE_PREFIX + " Z" + (-Z_OFFSET);
    return home + setZ;
  }
  
  public String waitForFinish() {
    return "M400\n";
  }
  
  public boolean positionValid(float x, float y) {
    return (x*x+y*y) <= Math.pow(BED_RADIUS - BUFFER,2);
  }
  
  // TODO: buff this up
  public SerialResponse handleRx(String rxString) {
    if(rxString.contains(SerialRig.OK)) {
      return SerialResponse.SUCCESS;
    } else if(rxString.contains(SerialRig.WAIT)) {
      return SerialResponse.WAIT;
    } else {
      return SerialResponse.FAIL;
    }
  }
  
}
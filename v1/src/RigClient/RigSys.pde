import processing.core.*;

/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
public class RigSys {
  public static final int L1SIM = 0; // L1 Simulator, within Processing
  public static final int PRINTCORE = 1; // Calls the Printcore process
  public static final int GCODE = 2; // Pure GCode emitter, using Processing's Serial library
  public static final int SERIAL = 3; // Serial output, works with camera and
                    // lights
  
  // TERRIBLY INACCURATE, CHANGES FOR EACH PICTURE AND Z-VALUE
  public static final float SUPEREYES_PIC_SIZE_X = 12.5f;
  public static final float SUPEREYES_PIC_SIZE_Y = 9f;
  
  public static final float TEST = 35f;

  private PApplet app;

  public RigSys(PApplet app) {
    this.app = app;
  }

  /**
   * Opens a new simulated rig.
   *
   * @returns null if the type is not that of a sim rig
   */
  public Rig openSimRig(int type, float boundsX, float boundsY, float initX, float initY, float picSizeX, float picSizeY,
      String in, String out) {
    switch (type) {
      case L1SIM:
        return new L1SimRig(boundsX, boundsY, initX, initY, picSizeX, picSizeY, in, out);
      default:
        return null;
    }
  }
  
  /**
   * Opens a new real rig.
   *
   * @param type the type of real rig
   * @param directory the directory to save images under
   * @returns null if the type is not that of a real rig  
   */
  public Rig openRealRig(int type, String directory) {
    switch (type) {
      case GCODE:
        return new GCodeRig(app, "output/" + directory);
      case SERIAL:
        try {
          return new SerialRig(app, "COM5", PrinterType.ROSTOCKMAX, "MICROSCOPE", "COM4", 640, 480, directory);
        } catch (SerialPortException e) {
          System.err.println("Printer not connected.");
        }/* catch (RuntimeException e) {
          System.err.println("Arduino not connected.");
        }*/
        return null;
      case PRINTCORE:
        return new PrintcoreRig("supercalifragilistictest.g");
      default:
        return null;
    }
  }

  /**
   * Opens a new rig, given the parent applet, the type of rig,
   * <b><i>default</i></b> configurations details.
   * 
   * @param app
   * @param type
   * @return
   */
  public Rig openDefaultRig(int type, String dir) {
    switch (type) {
    case GCODE:
    case SERIAL:
    case PRINTCORE:
      return openRealRig(type, dir);
    case L1SIM:
    default:
      return openSimRig(type, app.width, app.height, 110f, 110f, 200f, 200f, "fossil.jpg", dir);
    }
  }

  public RigUtils utils() {
    return new RigUtils();
  }
}

/**
 * Interface for all varieties of the CM Rig.
 *
 * @author Sarang Joshi
 */
public interface Rig {
  public void draw();
  public void go();
  public void addMove(float x, float y);
  public void addTakePicture();
  public void addLightSwitch(String id, boolean isOn);
  
  public float getPicSizeX();
  public float getPicSizeY();
}
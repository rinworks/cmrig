import processing.core.*;

boolean sound = false;
boolean debug = true;
boolean deepdebug = false;

Minim minim;
AudioSample beep;

GlobalConfigData globalConfig;

/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
public class RigSys {
  public static final int L1SIM = 0; // L1 Simulator, within Processing
  //public static final int PRINTCORE = 1; // Calls the Printcore process
  //public static final int GCODE = 2; // Pure GCode emitter, using Processing's Serial library
  public static final int SERIAL = 3; // Serial output, works with camera and
                    // lights
  
  // TERRIBLY INACCURATE, CHANGES FOR EACH PICTURE AND Z-VALUE
  public static final float SUPEREYES_PIC_SIZE_X = 12.5f;
  public static final float SUPEREYES_PIC_SIZE_Y = 9f;
  
  public static final float DINO = 4.5f;

  private PApplet app;
  
  private RigUtils utils;

  /**
   * Creates a new Rig system.
   */
  public RigSys(PApplet app) {
    this.app = app;
    this.utils = new RigUtils();
    
    // Beep debugging
    if(sound) {
      minim = new Minim(app);
      beep = minim.loadSample("beep.mp3", 512);
    }
    
    // Logging
    //Logger.setup(Logger.CONSOLE);
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
   * @param directory the directory to save images under
   */
  public Rig openRealRig(String directory) {
    try {
      return new SerialRig(app, 640, 480, directory);
    } catch (SerialPortException e) {
      System.err.println("Printer not connected.");
    }
    return null;
  }

  /**
   * Opens a new rig, given the parent applet, the type of rig, with
   * <b><i>default</i></b> configuration details from the global 
   * configuration.
   * 
   * @param type
   * @return
   */
  public Rig openDefaultRig(int type, String dir) {
    switch (type) {
    case SERIAL:
      return openRealRig(dir);
    case L1SIM:
    default:
      return openSimRig(type, app.width, app.height, 110f, 110f, 200f, 200f, "fossil.jpg", dir);
    }
  }

  public RigUtils utils() {
    return utils;
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
  
  public String[] lights();
  
  public float getPicSizeX();
  public float getPicSizeY();
}
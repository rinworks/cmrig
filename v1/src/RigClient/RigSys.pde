/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
public class RigSys {
  public static final int L1SIM     = 0; // L1 Simulator, within Processing
  public static final int PRINTCORE = 1; // Calls the Printcore process
  public static final int SERIAL = 2; // Serial output, works with camera and lights
  public static final int GCODE = 3; // Pure GCode spitter

  private float boundsX, boundsY;
  private float picSize;

  // initX and initY are relative to the bounds
  public Rig openRig(PApplet app, int type, float boundsX, float boundsY, float initX, float initY, float picSize) {
    this.boundsX = boundsX;
    this.boundsY = boundsY;
    this.picSize = picSize;
    
    switch(type) {
      case GCODE:
        return new GCodeRig(app, "output");
      case SERIAL:
        return new SerialRig(app, "COM3", "MICROSCOPE", 640, 480);
      case PRINTCORE:
        return new PrintcoreRig("supercalifragilistictest.g");
      case L1SIM:
      default:
        return new L1SimRig(boundsX, boundsY, initX, initY, picSize, "fossil.jpg"); 
    }
  }
  
  public RigUtils utils() {
    return new RigUtils(boundsX, boundsY, picSize);
  }
}

/**
 * Interface for all varieties of the CM Rig.
 *
 * @author Sarang Joshi
 */
public interface Rig {
  // Default
  void draw();
  // Go
  void go();
  // Step Setup
  void addMove(float x, float y);
  void addTakePicture();
  void addLightSwitch(String id, boolean isOn);
}

public class GCodeHelper {
}

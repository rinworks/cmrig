/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
public class RigSys {
  public static final int L1SIM     = 0;
  public static final int PRINTCORE = 1;

  public RigSys() {
    
  }
  
  // initX and initY are relative to the bounds
  public Rig openRig(int type, float boundsX, float boundsY, float initX, float initY, float picSize) {
    switch(type) {
      case PRINTCORE:
        return new PrintcoreRig(boundsX, boundsY, picSize, "supercalifragilistictest.g"); 
      case L1SIM:
      default:
        return new L1SimRig(boundsX, boundsY, initX, initY, picSize, "fossil.jpg"); 
    }
  }
  
  public RigUtils getUtils() {
    return new RigUtils();
  }
}

public interface Rig {
  // Default
  void draw();
  // Ticking
  void go();
  void tick();
  // Steps
  void addMove(float x, float y);
  void addTakePicture();
  void addLightSwitch(String id, boolean isOn);
  // Getters
  float getZoneWidth();
  float getZoneHeight();
  float getPicSize();
}

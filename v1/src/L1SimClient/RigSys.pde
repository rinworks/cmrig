/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
class RigSys {
  public static final int L1SIM     = 0;
  public static final int REALRIG   = 1;

  public RigSys() {
    
  }
  
  // initX and initY are relative to the bounds
  Rig openRig(int type, float initX, float initY, float picSize, String name) {
    switch(type) {
      case L1SIM:
      default:
       return new L1SimRig(width, height, initX, initY, picSize, name); 
    }
  }
  
  RigUtils getUtils() {
    return new RigUtils();
  }
}

interface Rig {
  // Default
  void draw();
  // Ticking
  void go();
  void tick();
  // Operations
  void change(float dX, float dY);
  PImage takePicture();
  // Steps
  void addMove(float x, float y);
  void addTakePicture();
  void addLightSwitch(String id, boolean isOn);
  // Getters
  int getZoneWidth();
  int getZoneHeight();
  float getPicSize();
}

/**
 * A utilities class in support of the {@link RigSys} object, providing functionality
 * to setup a rig.
 *
 * @author Sarang Joshi
 */
public class RigUtils {
  /**
   * Sets up a matrix pattern to fully capture the given image.
   *
   * @param r  the Rig to operate on
   * @param x  start value of x
   * @param y  start value of y
   * @param width  width of the matrix
   * @param height  height of the matrix
   * @return the number of pictures taken
   */
  public String setupMatrix(Rig r, float x, float y, float width, float height) {
    if (r != null) {
      int nX = ceil(width/r.getPicSizeX()) + 1; // # of pictures in the x 
      int nY = ceil(height/r.getPicSizeY()) + 1; // # of pictures in the y
      for (int j = 0; j < nY; j++) { // row-major
        float picY = y + r.getPicSizeY()/2f + j*(r.getPicSizeY() - ((r.getPicSizeY() * nY - height)/(nY - 1)));
        for (int i = 0; i < nX; i++) {
          float picX = x + r.getPicSizeX()/2f + i*(r.getPicSizeX() - ((r.getPicSizeX() * nX - width)/(nX - 1)));
          r.addMove(picX, picY);
          r.addTakePicture(String.format("%02d", 1+j) + "-" + String.format("%03d", 1+i));
          int id1 = (int) random(3, 7);
          int id2 = (int) random(3, 7);
          boolean value1 = random(0, 2) < 1.0;
          boolean value2 = random(0, 2) < 1.0;
          r.addLightSwitch(""+id1, value1);
          r.addLightSwitch(""+id2, value2);
        }
      }
      return nX + " pictures per row, " + nY + " rows";
    }
    return "";
  }

  void setupGlobalConfiguration(String configName) {
    GlobalConfigManager gcm = new GlobalConfigManager();
    //String[] configNames = gcm.list();
    //println(configNames);
    globalConfig =  gcm.getConfig(configName);
    if (globalConfig == null) {
      throw new RuntimeException("Configuration not found: "+configName);
    }
    println("Config \"" + globalConfig + "\":\n"+configName);
    //String[] cameras = Capture.list();
    //println(cameras);
  }

  void allLights(Rig r, boolean on) {
    if (r != null && r.lights() != null) {
      for (String id : r.lights()) {
        r.addLightSwitch(id, on);
      }
    }
  }
}
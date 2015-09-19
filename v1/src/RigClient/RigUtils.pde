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
   */
  public void setupMatrix(Rig r, boolean lightsOn, float x, float y, float width, float height) {
    if (r != null) {
      String[] l = r.lights();
      for(String light : l) {
        r.addLightSwitch(light, lightsOn);
      }
      
      int nX = ceil(width/r.getPicSizeX()) + 1; // # of pictures in the x 
      int nY = ceil(height/r.getPicSizeY()) + 1; // # of pictures in the y
      for (int j = 0; j < nY; j++) { // row-major
        float picY = y + r.getPicSizeY()/2f + j*(r.getPicSizeY() - ((r.getPicSizeY() * nY - height)/(nY - 1)));
        for (int i = 0; i < nX; i++) {
          float picX = x + r.getPicSizeX()/2f + i*(r.getPicSizeX() - ((r.getPicSizeX() * nX - width)/(nX - 1)));
          r.addMove(picX, picY);
          r.addTakePicture();
        }
      }
    }
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
  
  void basicSetup(Rig r) {
    String[] l = r.lights();
    if(l != null) {
      for(String id : r.lights()) {
        r.addLightSwitch(id, false);
      }
    }
  }
}
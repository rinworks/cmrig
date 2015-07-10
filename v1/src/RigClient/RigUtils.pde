/**
 * A utilities class in support of the {@link RigSys} object, providing functionality
 * to setup a rig.
 *
 * @author Sarang Joshi
 */
public class RigUtils {
  float zoneWidth, zoneHeight;
  float picSize;
  
  public RigUtils(float zoneWidth, float zoneHeight, float picSize) {
    this.zoneWidth = zoneWidth;
    this.zoneHeight = zoneHeight;
    this.picSize = picSize;
  }
  
  ///// SETUP ALGORITHMS /////
  /**
   * Sets up a matrix pattern to fully capture the given image.
   *
   * @param r  the Rig to operate on
   */
  public void setupMatrix(Rig r) {
    int nX = ceil(zoneWidth/picSize);
    int nY = ceil(zoneHeight/picSize);
    for(int j = 0; j < nY; j++) {
      float y = picSize/2.0 + j*(picSize - ((picSize * nY - zoneHeight)/(nY - 1)));
      for(int i = 0; i < nX; i++) {
        float x = picSize/2.0 + i*(picSize - ((picSize * nX - zoneWidth)/(nX - 1)));
        r.addMove(x, y);
        r.addTakePicture();
      }
    }
  }
  
  /**
   * Ideal for L1Sim rig.
   */
  public void setup1(Rig r) {
    r.addLightSwitch("NW", false);
    r.addLightSwitch("NW", true);
    r.addMove(350, 350);
    r.addLightSwitch("SW", false);
    r.addTakePicture();
  }
  
  /**
   * Ideal for real rig.
   */
  public void setup2(Rig r) {
    r.addMove(100, 100);
    r.addTakePicture();
    r.addMove(150, 0);
    r.addTakePicture();
  }
  
  public void setup3(Rig r) {
    r.addMove(100, 100);
  }
}

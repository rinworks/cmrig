/**
 * A utilities class in support of the {@link RigSys} object, providing functionality
 * to setup a rig.
 *
 * @author Sarang Joshi
 */
public class RigUtils {
  ///// SETUP ALGORITHMS /////
  /**
   * Sets up a matrix pattern to fully capture the given image.
   *
   * @param r  the Rig to operate on
   */
  public void setupMatrix(Rig r, float x, float y, float width, float height) {
    int nX = ceil(width/r.getPicSizeX()) + 1; // # of pictures in the x 
    int nY = ceil(height/r.getPicSizeY()) + 1; // # of pictures in the y
    for(int j = 0; j < nY; j++) { // row-major
      float picY = y + r.getPicSizeY()/2f + j*(r.getPicSizeY() - ((r.getPicSizeY() * nY - height)/(nY - 1)));
      for(int i = 0; i < nX; i++) {
        float picX = x + r.getPicSizeX()/2f + i*(r.getPicSizeX() - ((r.getPicSizeX() * nX - width)/(nX - 1)));
        r.addMove(picX, picY);
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
  
  public void setupNothing(Rig r) {
  }
  
  public void setup3(Rig r) {
    r.addMove(100, 100);
    r.addTakePicture();
  }
}

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
   * @param r  the Rig to oper
   */
  public void setupMatrix(Rig r) {
    int nX = ceil(r.getZoneWidth()/r.getPicSize());
    int nY = ceil(r.getZoneHeight()/r.getPicSize());
    for(int j = 0; j < nY; j++) {
      float y = r.getPicSize()/2.0 + j*(r.getPicSize() - ((r.getPicSize() * nY - r.getZoneHeight())/(nY - 1)));
      for(int i = 0; i < nX; i++) {
        float x = r.getPicSize()/2.0 + i*(r.getPicSize() - ((r.getPicSize() * nX - r.getZoneWidth())/(nX - 1)));
        r.addMove(x, y);
        r.addTakePicture();
      }
    }
  }
  
  public void test1(Rig r) {
    r.addLightSwitch("NW", false);
    r.addLightSwitch("NW", true);
    r.addMove(350, 350);
    r.addLightSwitch("SW", false);
    r.addTakePicture();
  }
  
  public void test2(Rig r) {
    r.addMove(100, 100);
    r.addTakePicture();
    r.addMove(150, 0);
    r.addTakePicture();
  }
}

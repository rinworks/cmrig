class RigUtils {
  public RigUtils() {
  }

  ///// SETUP ALGORITHMS /////
  void setupMatrix(Rig r) {
    int nX = ceil(r.getZoneWidth()/r.getPicSize());
    int nY = ceil(r.getZoneHeight()/r.getPicSize());
    for(int j = 0; j < nY; j++) {
      float y = r.getPicSize()/2.0 + j*(r.getPicSize() - ((r.getPicSize() * nY - r.getZoneHeight())/(nY - 1)));
      for(int i = 0; i < nX; i++) {
        float x = r.getPicSize()/2.0 + i*(r.getPicSize() - ((r.getPicSize() * nX - r.getZoneWidth())/(nX - 1)));
        r.addMove(x + L1SimRig.MARGIN, y + L1SimRig.MARGIN);
        r.addTakePicture();
      }
    }
  }
  
  void setup1(Rig r) {
    r.addLightSwitch("NW", false);
    r.addLightSwitch("NW", true);
    r.addMove(350, 350);
    r.addLightSwitch("SW", false);
    r.addTakePicture();
  }
}

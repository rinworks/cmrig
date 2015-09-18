import java.util.*;

boolean debug = true;

RigSys rs;
Rig rig;

void setup() {
  size(640, 480);
  
  rs = new RigSys(this);
  rig = rs.openDefaultRig(RigSys.SERIAL, "fossil-3");
  
  float val = (float) (RostockMaxHelper.BED_RADIUS)/sqrt(2.0);
  float startX = -20f, startY = -20f, wid = 40f, hei = 40f;
  //rs.utils().setupMatrix(rig, startX, startY, wid, hei); //<>//
  
  rig.addMove(20, 20);
  for(int i = 3; i <= 6; i++) {
    rig.addLightSwitch(i + "", true);
  }
  rig.addTakePicture();
  
  if(rig != null)
    rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}
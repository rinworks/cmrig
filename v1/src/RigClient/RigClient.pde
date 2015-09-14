import java.util.*;

boolean debug = true;

RigSys rs;
Rig rig;

void setup() {
  size(640, 480);
  
  rs = new RigSys(this);
  rig = rs.openDefaultRig(RigSys.SERIAL, "fossil-2");
  
  float val = (float) (RostockMaxHelper.BED_RADIUS)/sqrt(2.0);
  rs.utils().setupMatrix(rig, -val, -val, val*2, val*2); //<>//
  
  if(rig != null)
    rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}
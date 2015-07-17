import java.util.*;

boolean debug = true;

RigSys rs;
Rig rig;

void setup() {
  size(640, 480);
  
  rs = new RigSys(this);
  rig = rs.openDefaultRig(RigSys.SERIAL, "fern-3");
  
  rs.utils().setupMatrix(rig, 50f, 50f, 50f, 50f);
  rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}

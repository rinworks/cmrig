import java.util.*;

boolean debug = true;

RigSys rs;
Rig rig;

void setup() {
  size(660, 500);
  
  rs = new RigSys();
  //rig = rs.openRig(this, RigSys.PRINTCORE, 152.4f, 152.4f, 0f, 0f, 60f);
  //rig = rs.openRig(this, RigSys.L1SIM, width, height, 110f, 110f, 200f);
  rig = rs.openRig(this, RigSys.SERIAL, 152.4f, 152.4f, 0f, 0f, 60f);
  
  rs.utils().setupMatrix(rig);
  rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}

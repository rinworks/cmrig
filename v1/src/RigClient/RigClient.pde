import java.util.*;

boolean debug = true;

RigSys rs;
RigUtils ru;
Rig rig;

void setup() {
  size(660, 500);
  
  rs = new RigSys();
  ru = rs.getUtils();
  rig = rs.openRig(RigSys.L1SIM, width, height, 110f, 110f, 200f);
  //rig = rs.openRig(RigSys.PRINTCORE, 152.4f, 152.4f, 0f, 0f, 60f);
  
  ru.setupMatrix(rig);
  
  rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}

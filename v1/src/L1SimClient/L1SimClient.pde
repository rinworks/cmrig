import java.util.*;

boolean debug = true;

RigSys rs;
RigUtils ru;
Rig rig;

void setup() {
  size(660, 500);
  
  rs = new RigSys();
  ru = rs.getUtils();
  rig = rs.openRig(RigSys.L1SIM, 110f, 110f, 200f, "fossil.jpg");
  
  //ru.setupMatrix(rig);
  ru.setup1(rig);
  rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}

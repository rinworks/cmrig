import rigserver.*;
import jssc.*;
import cc.arduino.*;
import processing.video.*;

RigSys sys;
Rig rig;

void setup(){
  size(640, 480);
  
  sys = new RigSys(this);
  sys.utils().setupGlobalConfiguration("RostockMakerFaireSJ");
  rig = sys.openDefaultRig(RigSys.SERIAL, width, height, "test");
  
  rig.addMove(10, 10);
  rig.addTakePicture("1");
  
  if(rig!= null)
    rig.go();
}
void draw(){
  background(127f);
  if(rig != null)
    rig.draw();
}
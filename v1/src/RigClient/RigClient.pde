import ddf.minim.*; //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.*;

RigSys rs;
Rig rig;

void setup() {
  size(640, 480);
  
  rs = new RigSys(this);
  rs.utils().setupGlobalConfiguration("RostockMakerFaireSJ");
  
  rig = rs.openDefaultRig(RigSys.SERIAL, width, height, "makerfaire-demo");
  
  rs.utils().allLights(rig, false);
  //println(rs.utils().setupMatrix(rig, -60, -60, 120, 120));
  
  if(rig != null)
    rig.go();
}

void draw() {
  background(127.0);
  if(rig != null)
    rig.draw();
}
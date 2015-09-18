import ddf.minim.*; //<>// //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.*;

boolean debug = true;

RigSys rs;
Rig rig;

void setup() {
  size(640, 480);
  
  rs = new RigSys(this);
  rs.utils().setupGlobalConfiguration("RostockMakerFaire");
  rig = rs.openDefaultRig(RigSys.SERIAL, "test");
  
  rs.utils().setupNothing(rig);
  
  if(rig != null)
    rig.go();
}

void draw() {
  background(127.0);
  rig.draw();
}
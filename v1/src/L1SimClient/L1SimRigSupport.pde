class MovePath {
  List<PVector> points;
  
  public MovePath(float sx, float sy) {
    points = new ArrayList<PVector>();
    addPoint(sx, sy);
  }
  
  void addPoint(float x, float y) {
    points.add(new PVector(x, y));
  }
  
  void draw() {
    stroke(255);
    for(int i = 0; i < points.size() - 1; i++) {
      line(points.get(i).x, points.get(i).y,
        points.get(i+1).x, points.get(i+1).y);
    }
  }
}

class PicturePath {
  float x, y;
  
  public PicturePath(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void draw() {
    stroke(255, 0, 0);
    fill(255, 0, 0);
    ellipse(x, y, 16, 16);
  }
}

interface Step {
  void init();
  void tick();
  boolean isFinished();
  void finish();
  String finishMessage();
  void draw();
}

class Move implements Step {
  float endX, endY;
  float tickX, tickY;
  int nOfTicks;
  float buffer;
  MovePath path;
  L1SimRig rig;
  
  public Move(float x, float y, L1SimRig r) {
    endX = x;
    endY = y;
    rig = r;
  }
  
  void init() {
    float dX = endX - rig.x;
    float dY = endY - rig.y;
    float d = sqrt(dX * dX + dY * dY);
    if(round(d) != 0) {
      nOfTicks = (int)(d / 0.8); 
    } else {
      nOfTicks = L1SimRig.DEFAULT_TICKS;
    }
    tickX = dX/nOfTicks;
    tickY = dY/nOfTicks;
    buffer = (sqrt(tickX * tickX + tickY * tickY) / 2.0f) + EPSILON;
    path = new MovePath(rig.x, rig.y);
  }
  
  void tick() {
    rig.change(tickX, tickY);
    path.addPoint(rig.x, rig.y);
  }
  
  void finish() {
  }
  
  boolean isFinished() {
    return dist(rig.x, rig.y, endX, endY) <= buffer;
  }
  
  String finishMessage() {
    return "Moved to " + (endX) + ", " + (endY) + ".";
  }
  
  void draw() {
    if(path != null)
      path.draw();
  }
}

class Picture implements Step {
  int nOfTicks;
  int tick;
  PicturePath path;
  int picN;
  L1SimRig rig;
  
  public Picture(int nOfTicks, int n, L1SimRig r) {
    this.nOfTicks = nOfTicks;
    this.picN = n;
    this.rig = r;
  }
  
  void init() {
    tick = 0;
    path = new PicturePath(rig.x, rig.y);
    
    PImage cropImage = rig.takePicture();
    cropImage.save("output/picCrop" + picN + ".jpg");
  }
  
  void tick() {
    tick++;
  }
  
  void finish() {
  }
  
  boolean isFinished() {
    return tick == nOfTicks;
  }
  
  String finishMessage() {
    return "Picture taken.";
  }
  
  void draw() {
    if(path != null)
      path.draw();
  }
}

class LightSwitch implements Step {
  String id;
  int nOfTicks;
  boolean isOn;
  int tick;
  L1SimRig rig;
  
  public LightSwitch(String id, boolean isOn, int nOfTicks, L1SimRig r) {
    this.id = id;
    this.nOfTicks = nOfTicks;
    this.isOn = isOn;
    this.rig = r;
  }
  
  void init() {
    tick = 0;
  }
  void tick(){
    tick++;
  }
  void finish() {
    if(isOn)rig.on(id);
    else rig.off(id);
  }
  boolean isFinished() {
    return nOfTicks == tick;
  }
  void draw() {
  }
  String finishMessage() {
    return "Light id " + id + " switched o" + (isOn ? "n." : "ff.");
  }
}

class Light {
  public static final int SIZE = 10;
  
  boolean isOn;
  float x, y;
  String id;
  
  public Light(float x, float y, String id) {
    this.x = x;
    this.y = y;
    this.isOn=true;
    this.id = id;
  }
  
  void toggle() {
    isOn = !isOn;
  }
  
  void on(){isOn=true;}
  void off(){isOn=false;}
  
  void draw() {
    if(isOn) {
      stroke(255);
      fill(255);
    } else {
      stroke(0);
      fill(0);
    }
    ellipse(x, y, SIZE, SIZE);
  }
}

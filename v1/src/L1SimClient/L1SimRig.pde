class L1SimRig implements Rig {
  static final int DEFAULT_CAM_SIZE = 20;
  static final int MARGIN = 10;
  static final int FPS = 60;
  static final int DEFAULT_TICKS = 30;
  
  // The zone in which the Rig can operate
  int zoneX, zoneY, zoneWidth, zoneHeight;
  
  // Rig state
  float x, y;
  int size;
  float picSize;
  float imgScaleX, imgScaleY;
  
  // Steps
  Queue<Step> steps;
  List<Step> pastSteps;
  Step curr = null;
  boolean paused = true;
  int picN = 0;
  
  PImage img;
  Light[] lights;
  
  public L1SimRig(int boundsX, int boundsY, float x, float y, float picSize, String name) {
    this.zoneX = MARGIN;
    this.zoneY = MARGIN;
    this.zoneWidth = boundsX - 2*MARGIN;
    this.zoneHeight = boundsY - 2*MARGIN;
    this.x = x;
    this.y = y;
    this.size = DEFAULT_CAM_SIZE;
    this.picSize = picSize;
    
    img = loadImage("input/" + name);
    
    // how much the real image is scaled down by
    imgScaleX = (float)zoneWidth / (float)img.width;
    imgScaleY = (float)zoneHeight / (float)img.height;  
    
    steps = new LinkedList<Step>();
    pastSteps = new ArrayList<Step>();
    setupLights();
  }
  
  //// GETTERS ////
  float getX(){return x;} float getY(){return y;} float getPicSize(){return picSize;}
  int getZoneWidth(){return zoneWidth;} int getZoneHeight(){return zoneHeight;}
  
  //// LIGHTS ////
  void setupLights() {
    lights = new Light[4];
    lights[0] = new Light(Light.SIZE/2, Light.SIZE/2, "NW");
    lights[1] = new Light(zoneWidth+MARGIN+Light.SIZE/2, Light.SIZE/2, "NE");
    lights[2] = new Light(zoneWidth+MARGIN+Light.SIZE/2, zoneHeight+MARGIN+Light.SIZE/2, "SE");
    lights[3] = new Light(Light.SIZE/2, zoneHeight+MARGIN+Light.SIZE/2, "SW");
  }
  
  void on(String id) {
    for(Light l : lights)
      if(l.id.equals(id))
        l.on();
  }
  
  void off(String id) {
    for(Light l : lights)
      if(l.id.equals(id))
        l.off();
  }
  
  //// OPERATIONS ////
  // Coarse movement
  void change(float dX, float dY) {
    x+=dX;
    y+=dY;
  }
  
  boolean isInZone() {
    return !(x < zoneX || y < zoneY || x+size > zoneX+zoneWidth || y+size > zoneY+zoneHeight); 
  }
  
  // Picture-taking
  PImage takePicture() {
    int cropW = round(picSize / imgScaleX);
    int cropH = round(picSize / imgScaleY);
    int cropX = round((x - MARGIN - picSize/2) / imgScaleX);
    int cropY = round((y - MARGIN - picSize/2) / imgScaleY);
    
    return img.get(cropX, cropY, cropW, cropH);
  }
  
  //// SETUP ////
  void addMove(float x, float y) {
    steps.add(new Move(x, y, this));
  }
  void addTakePicture() {
    steps.add(new Picture(FPS, picN, this));
    picN++;
  }
  void addLightSwitch(String id, boolean isOn) {
    steps.add(new LightSwitch(id, isOn, FPS, this));
  }
  
  //// TICK-BASED OPERATIONS ////
  // Goes through the compiled moves sequentially
  void go() {
    if(!steps.isEmpty()) {
      curr = steps.remove();
      pastSteps.add(curr);
      curr.init();
      paused = false;
      if(debug)println("Go!");
    }
  }
  
  // One tick
  void tick() {
    if(!paused) {
      try {
        if(curr.isFinished()) {
          curr.finish();
          if(debug)println(curr.finishMessage());
          curr = steps.remove();
          pastSteps.add(curr);
          curr.init();
        } else {
          curr.tick();
        }
      } catch (NoSuchElementException e) {
        if(debug)println("Done.");
        paused = true;
      }
    }
  }
  
  //// DRAWING, OUTPUT ////
  void draw() {
    drawImage();
    drawZone();
    drawPaths();
    drawCam();
    drawLights();
    
    // non-drawing
    tick();
  }
  
  void drawImage() {
    image(img, MARGIN, MARGIN, zoneWidth, zoneHeight);
  }
  
  void drawZone() {
    noFill();
    rectMode(CORNER);
    stroke(0);
    rect(zoneX, zoneY, zoneWidth, zoneHeight);
  }
  
  // Draws actual rig camera
  void drawCam() {
    stroke(0);
    fill(#000000);
    rectMode(CENTER);
    rect(x, y, size, size);
    
    //if(debug){fill(255);text(round(x)+", "+round(y),x,y);}
  }
  
  void drawPaths() {
    for(Step s : pastSteps) {
      s.draw();
    }
  }
  
  void drawLights() {
    for(Light l : lights) {
      l.draw();
    }
  }
}


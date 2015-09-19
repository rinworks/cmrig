import processing.video.*;
import cc.arduino.*;

public class SerialRig implements Rig, StepFinishedListener {
  public static final int WAIT_MILLIS = 2500;
  public static final int LIGHT_MILLIS = 800;
  public static final int FEED_RATE = 3000;
  
  Queue<SerialStep> steps;
  SerialStep step;
  
  // Printer
  SerialPort printerPort;
  
  // Camera
  int picN = 0;
  Capture cam1;
  
  // Lights
  String[] lightIds;
  Arduino ino;
  
  // Saving
  String dir;
  
  public PrinterHelper printerHelper;
  
  public static final String OK = "ok";
  public static final String WAIT = "wait";
  public static final String ERROR = "error";
   //<>//
  public SerialRig(PApplet app, //<>//
      int camWidth, int camHeight, String directory)
      throws SerialPortException/*, RuntimeException*/ {
        
    this.steps = new LinkedList<SerialStep>();
    this.step = null;    
    this.dir = directory;
    
    // Printer
    if(globalConfig.printerType == PrinterType.PRINTRBOT) this.printerHelper = new PrintrBotHelper();
    else if(globalConfig.printerType == PrinterType.ROSTOCKMAX) this.printerHelper = new RostockMaxHelper();
    
    this.printerPort = new SerialPort(globalConfig.printerPort);
    printerPort.openPort();
    printerPort.setParams(globalConfig.printerBaudRate, 8, 1, 0);
    if(debug)println("Printer connected.");
    
    steps.add(new SerialGCodeStep(this, printerPort, printerHelper, printerHelper.initialize()));
    
    // Camera
    if(cameraExists(globalConfig.mainCamera)) {
      this.cam1 = new Capture(app, camWidth, camHeight, globalConfig.mainCamera);
      if(debug)println("Camera connected.");
      cam1.start();
    } else {
      this.cam1 = null;
      if(debug)println("Camera not connected.");
    }
    
    // Lights
    try {
      ino = new Arduino(app, globalConfig.arduinoPort, 57600);
      for(int i = 0; i < 13; i++) {
        ino.pinMode(i, Arduino.OUTPUT);
        ino.digitalWrite(i, Arduino.HIGH);
      }
      if(debug)println("Arduino connected.");
      lightIds = globalConfig.lights;
    } catch (Exception e) {
      ino = null;
      if(debug)println("Arduino not connected.");
    } 
  }
  
  public boolean gCodeValid() {
    //Queue<SerialStep> temp = new LinkedList<SerialStep>();
    for(SerialStep s : steps) {
      if(s instanceof SerialMove) {
        SerialMove move = (SerialMove) s;
        if(!printerHelper.positionValid(move.getX(), move.getY())) return false;
      }
    }
    return true;
  }
  
  public void draw() {
    if(cam1 != null) {
      if(cam1.available()) {
        cam1.read();
      }
      image(cam1, 0, 0);
    } else {
      text("No camera connected.", 0, 0);
    }
  }
  
  // Go
  public void go() {
    if(gCodeValid()) {
      if(!steps.isEmpty()) {
        step = steps.remove();
        if(debug)announce();
        step.go();
      }
    }
  }
  
  /**
   * Implementation of the StepFinishedListener method
   */
  public void stepFinished(boolean success) {
    if(success) {
      if(debug)println("--- FINISHED ---");
      if(debug)beep.trigger();
      if(!steps.isEmpty()) {
        step = steps.remove();
        if(debug)announce();
        step.go();
      } else {
        finish(true);
      }
    } else {
      finish(false);
    }
  }
  
  /**
   * Finishes the execution.
   */
  public void finish(boolean success) {
    if(debug)println(success ? "Done!" : "Aborted.");
    try {
      if(printerPort.isOpened())
        printerPort.closePort();
      
      if(debug)println("Printer port closed.");
    } catch (SerialPortException e) {
    }
  }
  
  public void announce() {
    println("--- NOW EXECUTING: " + step + " ---");
  }
  
  // Step Setup
  public void addMove(float x, float y) {
    steps.add(new SerialMove(this, printerPort, printerHelper, x, y));
    steps.add(new SerialWait(this, SerialRig.WAIT_MILLIS));
    //steps.add(new SerialGCodeStep(this, printerPort, printerHelper, GCodeHelper.getWaitGCode(SerialRig.WAIT_MILLIS)));
  }
  public void addTakePicture() {
    // Only take a picture if there's a camera connected
    if(cam1 != null) {
      picN++;
      //steps.add(new SerialGCodeStep(this, printerPort, printerHelper, GCodeHelper.getWaitGCode(SerialRig.WAIT_MILLIS)));
      steps.add(new SerialWait(this, SerialRig.WAIT_MILLIS));
      steps.add(new SerialPicture(this, cam1, picN, dir));
    }
  }
  public void addLightSwitch(String id, boolean isOn) {
    // Only add a light switch if the Arduino has been connected
    if(ino!=null) steps.add(new SerialLightSwitch(this, ino, Integer.parseInt(id), isOn));
    steps.add(new SerialWait(this, LIGHT_MILLIS));
  }
  
  public String[] lights() {
    return lightIds;
  }
  
  /**
   * @param name the name of the camera
   * @return if the given camera is connected
   */
  public boolean cameraExists(String name) {
    String[] cameras = Capture.list();
    for(String camera : cameras) {
      if(camera.contains(name)) return true;
    }
    return false;
  }
  
  public float getPicSizeX() { return RigSys.DINO; }
  public float getPicSizeY() { return RigSys.DINO; }
}
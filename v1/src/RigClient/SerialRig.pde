import processing.video.*;
import cc.arduino.*;

public class SerialRig implements Rig, StepFinishedListener {
  public static final int WAIT_MILLIS = 2000;
  
  Queue<SerialStep> steps;
  SerialStep step;
  
  // Printer
  SerialPort printerPort;
  
  // Camera
  int picN = 0;
  Capture video;
  
  // Lights
  Arduino ino;
  
  // Saving
  String dir;
  
  public PrinterHelper printerHelper;
  
  public static final String OK = "ok";
  public static final String WAIT = "wait";
  
  public SerialRig(PApplet app, //<>//
      String printerPortName, PrinterType type,
      String cameraName, String arduinoPort,
      int camWidth, int camHeight, String directory)
      throws SerialPortException/*, RuntimeException*/ {
        
    this.steps = new LinkedList<SerialStep>();
    this.step = null;
    this.printerPort = new SerialPort(printerPortName);
    if(cameraExists(cameraName)) {
      this.video = new Capture(app, camWidth, camHeight, cameraName);
      if(debug)println("Camera connected.");
    } else {
      this.video = null;
      if(debug)println("Camera not connected.");
    }
    
    this.dir = directory;
    
    // Printer
    printerPort.openPort();
    if(debug)println("Printer connected.");
    
    // Printer helper
    if(type == PrinterType.PRINTRBOT) this.printerHelper = new PrintrBotHelper();
    else if(type == PrinterType.ROSTOCKMAX) this.printerHelper = new RostockMaxHelper();
    
    // ALWAYS initialize the rig
    SerialGCodeStep init = new SerialGCodeStep(this, printerPort,
        printerHelper, printerHelper.initialize());
    steps.add(init);
    
    // Camera
    if(video != null)video.start();
    
    // Lights
    try {
      ino = new Arduino(app, arduinoPort, 57600);
      for(int i = 0; i < 13; i++) {
        ino.pinMode(i, Arduino.OUTPUT);
        ino.digitalWrite(i, Arduino.HIGH);
      }
      if(debug)println("Arduino connected.");
    } catch (Exception e) {
      ino = null; // No lights, I guess.
      //throw new RuntimeException("Arduino not found.");
    } 
  }
  
  public boolean gCodeValid() {
    //Queue<SerialStep> temp = new LinkedList<SerialStep>();
    boolean valid = true;
    
    for(SerialStep s : steps) {
      if(valid) {
        // Only bother checking if we've been valid so far
        if(s instanceof SerialMove) {
          SerialMove move = (SerialMove) s;
          valid = valid && printerHelper.positionValid(move.getX(), move.getY());
        }
      }
    }
    
    return valid;
  }
  
  public void draw() {
    if(video != null) {
      if(video.available()) {
        video.read();
      }
      image(video, 0, 0);
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
  }
  public void addTakePicture() {
    // Only take a picture if there's a camera connected
    if(video != null) {
      picN++;
      steps.add(new SerialPicture(this, video, picN, dir));
    }
  }
  public void addLightSwitch(String id, boolean isOn) {
    // Only add a light switch if the Arduino has been connected
    if(ino!=null)
      steps.add(new SerialLightSwitch(this, ino, Integer.parseInt(id), isOn));
    
    steps.add(new SerialWait(this, printerPort, printerHelper));
  }
  
  /**
   * @param name the name of the camera
   * @return if the given camera is connected
   */
  public boolean cameraExists(String name) {
    String[] cameras = Capture.list();
    for(String camera : cameras) {
      if(camera.equals(name)) return true;
    }
    return false;
  }
  
  public float getPicSizeX() { return RigSys.TEST; }
  public float getPicSizeY() { return RigSys.TEST; }
}
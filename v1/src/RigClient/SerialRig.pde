import processing.video.*;

public class SerialRig implements Rig, StepFinishedListener {
  public static final int WAIT_MILLIS = 2000;
  
  Queue<SerialStep> steps;
  SerialStep step = null;
  
  // Printer
  SerialPort printerPort;
  
  // Camera
  int picN = 0;
  Capture video;
  
  // Lights
  
  // Saving
  String dir;
  
  public static final String OK = "ok";
  
  public SerialRig(PApplet app, String portName, String cameraName, int camWidth, int camHeight, String directory) {
    this.steps = new LinkedList<SerialStep>();
    this.printerPort = new SerialPort(portName);
    this.video = new Capture(app, camWidth, camHeight, cameraName);
    this.dir = directory;
    
    // Printer
    try {
      printerPort.openPort();
      steps.add(new SerialInit(this, printerPort)); // ALWAYS initialize the rig
    } catch (SerialPortException e) {
      e.printStackTrace();
    }
    
    // Camera
    video.start();
  }
  
  public void draw() {
    if(video.available()) {
      video.read();
    }
    image(video, 0, 0);
  }
  
  // Go
  public void go() {
    if(!steps.isEmpty()) {
      step = steps.remove();
      if(debug)announce();
      step.go();
    }
  }
  
  /**
   * Implementation of the StepFinishedListener
   */
  public void stepFinished() {
    if(debug)println("--- FINISHED ---");
    if(!steps.isEmpty()) {
      step = steps.remove();
      if(debug)announce();
      step.go();
    } else 
      if(debug)println("Done!");
  }
  
  public void announce() {
    println("--- NOW EXECUTING: " + step + " ---");
  }
  
  // Step Setup
  public void addMove(float x, float y) {
    steps.add(new SerialMove(this, printerPort, x, y));
  }
  public void addTakePicture() {
    picN++;
    steps.add(new SerialPicture(this, video, picN, dir));
  }
  public void addLightSwitch(String id, boolean isOn) {}
  
  public float getPicSizeX() { return RigSys.SUPEREYES_PIC_SIZE_X; }
  public float getPicSizeY() { return RigSys.SUPEREYES_PIC_SIZE_Y; }
}

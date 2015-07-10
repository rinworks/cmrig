import processing.video.*;

public class SerialRig implements Rig, SerialStepFinishedListener {
  Queue<SerialStep> steps;
  SerialStep step = null;
  
  // Printer
  SerialPort printerPort;
  
  // Camera
  int picN = 0;
  Capture video;
  
  // Lights
  
  public static final String OK = "ok";
  
  public SerialRig(PApplet app, String portName, String cameraName, int camWidth, int camHeight) {
    this.steps = new LinkedList<SerialStep>();
    this.printerPort = new SerialPort(portName);
    this.video = new Capture(app, camWidth, camHeight, cameraName);
    
    // Printer
    try {
      printerPort.openPort();
      steps.add(new SerialInit(this, printerPort));
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
  void go() {
    if(!steps.isEmpty()) {
      step = steps.remove();
      if(debug)announce();
      step.go();
    }
  }
  
  /**
   * Implementation of the SerialStepFinishedListener
   */
  void stepFinished() {
    if(debug)println("--- FINISHED ---");
    if(!steps.isEmpty()) {
      step = steps.remove();
      if(debug)announce();
      step.go();
    } else 
      if(debug)println("Done!");
  }
  
  void announce() {
    println("--- NOW EXECUTING: " + step + " ---");
  }
  
  // Step Setup
  void addMove(float x, float y) {
    steps.add(new SerialMove(this, printerPort, x, y));
  }
  void addTakePicture() {
    picN++;
    steps.add(new SerialPicture(this, picN));
  }
  void addLightSwitch(String id, boolean isOn) {}
  
}

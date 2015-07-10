import jssc.*;

public interface SerialStep {
  void go();
}

public class SerialInit implements SerialStep, SerialPortEventListener {
  SerialStepFinishedListener l;
  SerialPort port;
  
  public static final String INIT_GCODE = "G28 X Y\n";
  
  public SerialInit(SerialStepFinishedListener l, SerialPort port) {
    this.l = l;
    this.port = port; 
  }
  
  public void go() {
    try {
      port.writeString(INIT_GCODE);
      port.addEventListener(this);
      if(debug)println("init event listener added");
      if(debug)print("SENT: " + INIT_GCODE);
    } catch (SerialPortException e) {
      e.printStackTrace();
    }
  }
  
  public void serialEvent(SerialPortEvent event) {
    if(event.isRXCHAR()) {
      try {
        String in = port.readString();
        if(debug)print("RECD: " + in);
        if(in.contains(SerialRig.OK)) {
          port.removeEventListener();
          if(debug)println("init event listener removed");
          if(debug)println("init finished -> listener called");
          l.stepFinished();
        }
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    }
  }
  
  public String toString() {
      return "INIT";
  }
}

public class SerialMove implements SerialStep, SerialPortEventListener {
  SerialStepFinishedListener l;
  SerialPort port;
  float x, y;
  int nOks = 0;
  
  public static final String WAIT_FOR_FINISH = "G4 P0\n";
  public static final String MOVE_CODE = "G0";
  
  public SerialMove(SerialStepFinishedListener l, SerialPort port, float x, float y) {
    this.l = l;
    this.port = port;
    this.x = x;
    this.y = y;
  }
  
  private String getGCode() {
    String xS = String.format("%.2f", x);
    String yS = String.format("%.2f", y);
    return MOVE_CODE + " X" + xS + " Y" + yS + "\n";
  }
  
  public void go() {
    try {
      port.addEventListener(this);
      if(debug)println("move event listener added");
      sendGCode(getGCode());
    } catch (SerialPortException e) {
      e.printStackTrace();
    }
  }
  
  private void sendGCode(String code) throws SerialPortException {
    port.writeString(code);
    if(debug)print("SENT: " + code);
  }
  
  public void serialEvent(SerialPortEvent event) {
    if(event.isRXCHAR()) {
      try {
        String in = port.readString();
        if(debug)print("RECD: " + in);
        if(in.contains(SerialRig.OK)) {
          nOks++;
        }
        println(nOks + " ok's");
        if(nOks == 1) {
          sendGCode(WAIT_FOR_FINISH);
        } else if(nOks == 2) { // 1 for G0 move command received and 1 for G4 wait command finished
          port.removeEventListener();
          if(debug)println("move event listener removed");
          if(debug)println("move finished -> listener called");
          l.stepFinished();
        }
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    }
  }
  
  public String toString() {
      return "MOVE TO X:" + x + ", Y:" + y;
  }
}

public class SerialPicture implements SerialStep  {
  SerialStepFinishedListener l;
  int picN;
 
  public SerialPicture(SerialStepFinishedListener l, int picN) {
    this.l = l;
    this.picN = picN;
  }
  
  public void go() {
    saveFrame("output/picCrop" + picN + ".png");
    l.stepFinished();
  }
  
  public String toString() {
    return "PICTURE";
  }
}

interface SerialStepFinishedListener {
  void stepFinished();
}


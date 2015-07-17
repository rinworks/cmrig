import jssc.*;
import java.util.*;

/**
 * Abstract class that represents a single step in the Rig's set of instructions.
 *
 * @author Sarang Joshi
 */
public abstract class SerialStep {
  protected StepFinishedListener l;
  
  public SerialStep(StepFinishedListener l) {
    this.l = l;
  }
  
  public abstract void go();
}

public class SerialGCodeStep extends SerialStep implements SerialPortEventListener {
  protected SerialPort port;
  protected String[] code;
  protected int lineN;
  
  public SerialGCodeStep(StepFinishedListener l, SerialPort port) {
    this(l, port, "");
  }
  
  public SerialGCodeStep(StepFinishedListener l, SerialPort port, String codeString) {
    super(l);
    this.port = port;
    this.lineN = 0;
    
    setGCode(codeString);
  }
  
  /**
   * Saves the given g codes.
   *
   * @param codeString a string containing g codes separated by \\n line breaks
   */
  public void setGCode(String codeString) {
    this.code = GCodeHelper.parseGCode(codeString, "\n");
  }
  
  private void sendGCode() throws SerialPortException {
    if(debug)println("Line number: " + lineN);
    port.writeString(code[lineN]);
    if(debug)print("SENT: " + code[lineN]);
  }
  
  public void go() {
    if(code.length > 0)
      try {
        port.addEventListener(this);
        if(debug)println("gcode event listener added");
        sendGCode();
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    else
      l.stepFinished();
  }
  
  /**
   * Message received from printer.
   *
   * @param event the serial port event information
   */
  public void serialEvent(SerialPortEvent event) {
    if(event.isRXCHAR()) {
      try {
        String in = port.readString();
        if(debug)print("RECD: " + in);
        if(in.contains(SerialRig.OK)) { // line completed
          lineN++;
          if(lineN >= code.length) { // all the code finished
            port.removeEventListener();
            if(debug)println("g code event listener removed");
            if(debug)println("g code finished -> listener called");
            l.stepFinished();
          } else {
            sendGCode();
          }
        } else {
          // TODO: HANDLE OTHER CASES
          l.stepFinished(); // abort
        }
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    }
  }
  
  public String toString() {
    return Arrays.toString(code);
  }
}

public class SerialInit extends SerialGCodeStep {
  public SerialInit(StepFinishedListener l, SerialPort port) {
    super(l, port, GCodeHelper.GO_TO_HOME); 
  }
  
  public String toString() {
      return "INIT";
  }
}

public class SerialMove extends SerialGCodeStep {
  private float x, y;
  
  public SerialMove(StepFinishedListener l, SerialPort port, float x, float y) {
    super(l, port, "");
    this.x = x;
    this.y = y;
    
    setGCode(GCodeHelper.getMoveGCode(x, y)
      + GCodeHelper.WAIT_FOR_FINISH
      + GCodeHelper.getWaitGCode(SerialRig.WAIT_MILLIS));
  }
    
  public String toString() {
    return "MOVE TO X:" + x + ", Y:" + y;
  }
}


public class SerialPicture extends SerialStep  {
  int picN;
  Capture video;
  String dir;
 
  public SerialPicture(StepFinishedListener l, Capture video, int picN, String directory) {
    super(l);
    this.l = l;
    this.picN = picN;
    this.video = video;
    this.dir = directory;
  }
  
  public void go() {
    //saveFrame("output/picCrop" + String.format("%04d", picN) + ".jpg");
    if(video.available())video.read();
    video.save("output/" + dir + "/" + String.format("%04d", picN) + ".jpg");
    l.stepFinished();
  }
  
  public String toString() {
    return "PICTURE";
  }
}

interface StepFinishedListener {
  void stepFinished();
}



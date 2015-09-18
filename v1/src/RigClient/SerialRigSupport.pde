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
  protected PrinterHelper helper;
  
  public SerialGCodeStep(StepFinishedListener l, SerialPort port, PrinterHelper help) {
    this(l, port, help, "");
  }
  
  public SerialGCodeStep(StepFinishedListener l, SerialPort port, PrinterHelper help,
      String codeString) {
    super(l);
    this.port = port;
    this.helper = help;
    this.lineN = 0;
    
    this.setGCode(codeString);
  }
  
  /**
   * Saves the given g codes.
   *
   * @param codeString a string containing g codes separated by \\n line breaks
   */
  public void setGCode(String codeString) {
    this.code = GCodeHelper.parseGCode(codeString, "\n");
  }
  
  /**
   * Sends the current line of g code, based on {@link lineN}.
   */
  private void sendGCode() throws SerialPortException {
    port.writeString(code[lineN]);
    if(debug)print("SENT: " + code[lineN]);
  }
  
  /**
   * Runs the step.
   */
  public void go() {
    if(code.length > 0)
      try {
        port.addEventListener(this);
        sendGCode();
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    else
      l.stepFinished(true); // empty code?
  }
  
  private String rxString = "";
  
  /**
   * Message received from printer.
   *
   * @param event the serial port event information
   */
  public void serialEvent(SerialPortEvent event) {
    if(event.isRXCHAR()) {
      try {
        String in = port.readString();
        // Appending instead of replacing -- sometimes the printer sends 'o' and 'k' separately for some reason
        rxString += in;
        if(debug)print("RECD: " + in);
        
        // Only handle the response if it's a complete response
        if(rxString.endsWith(GCodeHelper.LINE_BREAK)) {
          // Use the helper to interpret the received string
          SerialResponse resp = helper.handleRx(rxString);
          
          if (resp == SerialResponse.SUCCESS) {
            rxString = ""; // reset received message
            lineN++;
            if(lineN >= code.length) { // all the code finished
              port.removeEventListener();
              l.stepFinished(true);
            } else { // keep sending code
              sendGCode();
            }
          } else if (resp == SerialResponse.WAIT) {
            // do nothing
          } else if (resp == SerialResponse.FAIL) {
            l.stepFinished(false); // abort step
          }
        }
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    }
  }
  
  public String toString() { //<>//
    return Arrays.toString(code);
  }
} //<>//

public class SerialMove extends SerialGCodeStep {
  private float x, y;
  
  public SerialMove(StepFinishedListener l, SerialPort port, PrinterHelper help,
      float x, float y) {
    super(l, port, help);
    this.x = x;
    this.y = y;
    
    setGCode(GCodeHelper.getMoveGCode(x, y)
      + help.waitForFinish());
  }
  
  public float getX() { return x; }
  public float getY() { return y; }
  
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
    this.picN = picN;
    this.video = video;
    this.dir = directory;
  }
  
  public void go() {
    //saveFrame("output/picCrop" + String.format("%04d", picN) + ".jpg");
    //beep.trigger();
    if(video.available())video.read();
    video.save("output/" + dir + "/" + String.format("%04d", picN) + ".jpg");
    l.stepFinished(true);
  }
  
  public String toString() {
    return "PICTURE";
  }
}

public class SerialLightSwitch extends SerialStep {
  Arduino ino;
  int pin;
  boolean isOn;
  
  public SerialLightSwitch(StepFinishedListener l, Arduino ino, int id, boolean isOn) {  
    super(l);
    this.ino = ino;
    this.pin = id;
    this.isOn = isOn;
  }
  
  public void go() {
    // on corresponds to LOW
    ino.digitalWrite(pin, (isOn ? Arduino.LOW : Arduino.HIGH));
    //delay(200);
    l.stepFinished(true);
  }
  
  public String toString() {
    return "LIGHTS O" + (isOn ? "N" : "FF");
  }
}

public class SerialWait extends SerialStep {
  int duration;
  
  public SerialWait(StepFinishedListener l, int duration) {
    super(l);
    this.duration = duration;
  }
  
  public void go() {
    delay(duration); // pauses execution!!
    l.stepFinished(true);
  }
  
  public String toString() {
    return "WAIT FOR " + duration + "ms";
  }
}

interface StepFinishedListener {
  void stepFinished(boolean success);
}
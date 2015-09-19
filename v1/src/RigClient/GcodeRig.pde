import java.util.*;
import java.io.*;
import processing.serial.*;

public class GCodeRig implements Rig {
  String outputName;
  Queue<String> instructions;
  Serial port;
  
  boolean absMove;
  
  public GCodeRig(PApplet app, String outputName) {
    this.outputName = outputName;
    instructions = new LinkedList<String>();
    instructions.add("G28 X Y");
    absMove = true;
    instructions.add("G90");
    
    port = new Serial(app, Serial.list()[0], 9600);
  }
  
  // Default
  public void draw() {
  }
  
  
  // Ticking
  public void go() {
    println("Go!");
    
    // TODO: G code testing
    
    // Serial execution
    while(!instructions.isEmpty()) {
      port.write(instructions.remove() + "\n");
    }
  }
  
  // Steps
  public void addMove(float x, float y) {
    String xS = String.format("%.2f", x);
    String yS = String.format("%.2f", y);
    if(!absMove) {
      absMove = true;
      instructions.add("G90");
    }
    instructions.add("G0 X" + xS + " Y" + yS);
  }
  public void addTakePicture() {
    instructions.add("G4 P2000");
  }
  public String[] lights(){return null;}
  public void addLightSwitch(String id, boolean isOn) {}
  
  public float getPicSizeX() { return RigSys.SUPEREYES_PIC_SIZE_X; }
  public float getPicSizeY() { return RigSys.SUPEREYES_PIC_SIZE_Y; }
}
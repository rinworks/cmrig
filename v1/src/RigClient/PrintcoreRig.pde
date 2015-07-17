import java.util.*;
import java.io.*;

public class PrintcoreRig implements Rig {
  String outputName;
  List<String> instructions;
  
  boolean absMove;
  
  public PrintcoreRig(String outputName) {
    this.outputName = outputName;
    instructions = new ArrayList<String>();
    instructions.add("G28 X Y");
    absMove = true;
    instructions.add("G90");
  }
  
  // Default
  public void draw() {
    tick();
  }
  
  Process p;
  String line;
  BufferedReader br;
  
  // Ticking
  public void go() {
    println("Go!");
    
    // G code file saving
    saveStrings(outputName, instructions.toArray(new String[instructions.size()]));
    if(debug)println("File saved.");
    
    // G code testing
    
    
    // Printcore execution
    try {
      p = new ProcessBuilder("python",
        "-s",
        "C:\\Users\\Sarang\\Documents\\GitHub\\Printrun\\printcore.py",
        "COM3",
        "C:\\Users\\Sarang\\Documents\\GitHub\\rig\\v1\\src\\RigClient\\" + outputName)
        .start();
      if(debug)println("Process started.");
      InputStream is = p.getInputStream();
      InputStreamReader isr = new InputStreamReader(is);
      br = new BufferedReader(isr);
      if(debug)println("Reader init.");
    } catch (Exception e) {
      println("Error!");
    }
  }
  
  public void tick() {
    try {
      if((line = br.readLine()) != null) {
        System.out.println(line);
      }
    } catch (Exception e) {
      if(debug)e.printStackTrace();
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
  public void addLightSwitch(String id, boolean isOn) {}
  
  public float getPicSizeX() { return RigSys.SUPEREYES_PIC_SIZE_X; }
  public float getPicSizeY() { return RigSys.SUPEREYES_PIC_SIZE_Y; }
}

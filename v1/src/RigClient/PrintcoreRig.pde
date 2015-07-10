import java.util.*;
import java.io.*;

class PrintcoreRig implements Rig {
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
  void draw() {
    tick();
  }
  
  Process p;
  String line;
  BufferedReader br;
  
  // Ticking
  void go() {
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
  
  void tick() {
    try {
      if((line = br.readLine()) != null) {
        System.out.println(line);
      }
    } catch (Exception e) {
      if(debug)e.printStackTrace();
    }
  }
  
  // Steps
  void addMove(float x, float y) {
    String xS = String.format("%.2f", x);
    String yS = String.format("%.2f", y);
    if(!absMove) {
      absMove = true;
      instructions.add("G90");
    }
    instructions.add("G0 X" + xS + " Y" + yS);
  }
  
  void addTakePicture() {
    instructions.add("G4 P2000");
  }
  void addLightSwitch(String id, boolean isOn) {}
  
}

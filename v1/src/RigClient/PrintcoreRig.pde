import java.util.*;
import java.io.*;

class PrintcoreRig implements Rig {
  String outputName;
  List<String> instructions;
  
  float zoneWidth, zoneHeight;
  float picSize;
  
  boolean absMove;
  
  public PrintcoreRig(float zoneWidth, float zoneHeight, float picSize, String outputName) {
    this.zoneWidth = zoneWidth;
    this.zoneHeight = zoneHeight;
    this.picSize = picSize;
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
    saveStrings(outputName, instructions.toArray(new String[instructions.size()]));
    if(debug)println("File saved.");
    
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
  
  // Getters
  float getZoneWidth() {return zoneWidth;}
  float getZoneHeight() {return zoneHeight;}
  float getPicSize() {return picSize;}
}

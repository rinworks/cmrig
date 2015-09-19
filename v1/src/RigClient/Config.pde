/**
 * Rudimentary global configuration management
 * @author Joseph Joy
 */
import java.util.*;

class GlobalConfigData {
  String printerPort;
  String arduinoPort;
  int printerBaudRate;
  PrinterType printerType;
  String mainCamera;
  String secondaryCamera;
  String[] lights;

  GlobalConfigData() {
  }
  
  GlobalConfigData(String pPort, String aPort, int pBRate, PrinterType pType, String mainCam, String secCam, String[] lightIds ) {
    printerPort = pPort;
    arduinoPort = aPort;
    printerBaudRate = pBRate;
    printerType = pType;
    mainCamera = mainCam;
    secondaryCamera = secCam;
    lights = lightIds;
  }
  String toString() {
    String ret =  "{pp:" + printerPort + ", ap:" + arduinoPort + ", pbr:" + printerBaudRate;
    ret += "\npt:" + printerType + ", mc:\"" + mainCamera + "\", sc:\"" + secondaryCamera;
    ret += "\nl:" + Arrays.toString(lights) + "\"}";
    return ret;
  }
};

class GlobalConfigManager {
  Dictionary<String, GlobalConfigData> configs; 

  GlobalConfigManager() {
    configs = new Hashtable<String, GlobalConfigData>(); 

    // Add all named configs here...
    //  Config name, printer port, arduino port, printer baud rate, printer type, main camera, secondary camera
    configs.put("PrintrbotMakerFaire", new GlobalConfigData("COM5", "", 250000, PrinterType.PRINTRBOT, "MICROSCOPE", "", null)); // , PrinterType.ROSTOCKMAX
    configs.put("RostockMakerFaire", new GlobalConfigData("COM5", "COM2", 250000, PrinterType.ROSTOCKMAX, "Z Dino-Lite Premier", "CAM2", 
      new String[]{ "3", "4", "5", "6" }));
    configs.put("RostockMakerFaireSJ", new GlobalConfigData("COM5", "COM4", 250000, PrinterType.ROSTOCKMAX, "Dino-Lite Premier", "FULL HD 1080P Webcam",
      new String[]{ "3", "4", "5", "6" }));
  }
  
  String[] list() {
    ArrayList<String> temp = new ArrayList<String>();
    for (Enumeration<String> k = configs.keys(); k.hasMoreElements();) {
       temp.add(k.nextElement());
    }
    return temp.toArray(new String[temp.size()]);
  }

  //
  // Returns named config. Returns null if there is no such config.
  //
  GlobalConfigData getConfig(String configName) {
    return configs.get(configName);
  }
};
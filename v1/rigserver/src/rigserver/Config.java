package rigserver;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import rigserver.SerialRig.PrinterType;

/**
 * Rudimentary global configuration management
 * 
 * @author Joseph Joy
 */
public class Config {

	public static class GlobalConfigData {
		String printerPort;
		String arduinoPort;
		int printerBaudRate;
		PrinterType printerType;
		String mainCamera;
		String secondaryCamera;
		String[] lights;

		public GlobalConfigData() {
		}

		public GlobalConfigData(String pPort, String aPort, int pBRate,
				PrinterType pType, String mainCam, String secCam,
				String[] lightIds) {
			printerPort = pPort;
			arduinoPort = aPort;
			printerBaudRate = pBRate;
			printerType = pType;
			mainCamera = mainCam;
			secondaryCamera = secCam;
			lights = lightIds;
		}

		public String toString() {
			String ret = "{pp:" + printerPort + ", ap:" + arduinoPort
					+ ", pbr:" + printerBaudRate;
			ret += "\npt:" + printerType + ", mc:\"" + mainCamera + "\", sc:\""
					+ secondaryCamera + "\"";
			ret += "\nl:" + Arrays.toString(lights) + "\"}";
			return ret;
		}
	}

	public static class GlobalConfigManager {
		Map<String, GlobalConfigData> configs;

		public GlobalConfigManager() {
			configs = new HashMap<String, GlobalConfigData>();

			// Add all named configs here...
			// Config name, printer port, arduino port, printer baud rate,
			// printer type, main camera, secondary camera
			configs.put("PrintrbotMakerFaire", new GlobalConfigData("COM5", "",
					250000, PrinterType.PRINTRBOT, "MICROSCOPE", "", null));
			configs.put("RostockMakerFaire", new GlobalConfigData("COM5",
					"COM2", 250000, PrinterType.ROSTOCKMAX,
					"Z Dino-Lite Premier", "CAM2", new String[] { "3", "4",
							"5", "6" }));
			configs.put("RostockMakerFaireSJ", new GlobalConfigData("COM5",
					"COM4", 250000, PrinterType.ROSTOCKMAX,
					"Dino-Lite Premier", "FULL HD 1080P Webcam", new String[] {
							"3", "4", "5", "6" }));
		}

		public String[] list() {
			List<String> temp = new ArrayList<String>();
			for (String k : configs.keySet()) {
				temp.add(configs.get(k).toString());
			}
			return temp.toArray(new String[temp.size()]);
		}

		/**
		 * Returns named config. Returns null if there is no such config.
		 */
		public GlobalConfigData getConfig(String configName) {
			return configs.get(configName);
		}
	};
}

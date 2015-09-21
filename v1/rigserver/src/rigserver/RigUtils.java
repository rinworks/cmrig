package rigserver;

import rigserver.Config.GlobalConfigManager;

// TODO: Make static

/**
 * A utilities class in support of the {@link RigSys} object, providing
 * functionality to setup a rig.
 *
 * @author Sarang Joshi
 */
public class RigUtils {
	/**
	 * Sets up a matrix pattern to fully capture the given image.
	 *
	 * @param r
	 *            the Rig to operate on
	 * @param x
	 *            start value of x
	 * @param y
	 *            start value of y
	 * @param width
	 *            width of the matrix
	 * @param height
	 *            height of the matrix
	 * @return the number of pictures taken
	 */
	public static String setupMatrix(Rig r, float x, float y, float width,
			float height) {
		if (r != null) {
			int nX = (int) Math.ceil(width / r.getPicSizeX()) + 1; // # of
																	// pictures
																	// in the
			// x
			int nY = (int) Math.ceil(height / r.getPicSizeY()) + 1; // # of
																	// pictures
																	// in the
			// y
			for (int j = 0; j < nY; j++) { // row-major
				float picY = y
						+ r.getPicSizeY()
						/ 2f
						+ j
						* (r.getPicSizeY() - ((r.getPicSizeY() * nY - height) / (nY - 1)));
				for (int i = 0; i < nX; i++) {
					float picX = x
							+ r.getPicSizeX()
							/ 2f
							+ i
							* (r.getPicSizeX() - ((r.getPicSizeX() * nX - width) / (nX - 1)));
					r.addMove(picX, picY);
					r.addTakePicture(String.format("%02d", 1 + j) + "-"
							+ String.format("%03d", 1 + i));
				}
			}
			return nX + " pictures per row, " + nY + " rows";
		}
		return "";
	}

	public static void setupGlobalConfiguration(String configName) {
		GlobalConfigManager gcm = new GlobalConfigManager();
		// String[] configNames = gcm.list();
		// println(configNames);
		RigSys.GLOBAL_CONFIG = gcm.getConfig(configName);
		if (RigSys.GLOBAL_CONFIG == null) {
			throw new RuntimeException("Configuration not found: " + configName);
		}
		System.out.println("Config \"" + RigSys.GLOBAL_CONFIG + "\":\n" + configName);
		// String[] cameras = Capture.list();
		// println(cameras);
	}

	public static void allLights(Rig r, boolean on) {
		if (r != null && r.lights() != null) {
			for (String id : r.lights()) {
				r.addLightSwitch(id, on);
			}
		}
	}
}
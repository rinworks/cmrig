package rigserver;

import java.util.Random;

import rigserver.Config.GlobalConfigManager;

// TODO: Static or not??
/**
 * A utilities class in support of the {@link RigSys} object, providing
 * functionality to setup a rig.
 *
 * @author Sarang Joshi
 */
public class RigUtils {
	public static Random rand = new Random();

	/**
	 * Sets up a matrix pattern to fully capture the given image.
	 *
	 * @param r
	 *            the {@link Rig} to operate on
	 * @param x
	 *            start value of x
	 * @param y
	 *            start value of y
	 * @param width
	 *            width of the matrix
	 * @param height
	 *            height of the matrix
	 * @param prefix
	 *            prefix for all the pictures taken
	 * @return the number of pictures taken
	 */
	public String setupMatrix(Rig r, float x, float y, float width,
			float height, String prefix) {
		if (r != null) {
			// # of pictures
			int cols = (int) Math.ceil(width / r.getPicSizeX()) + 1;
			int rows = (int) Math.ceil(height / r.getPicSizeY()) + 1;

			// Offsets for each picture
			float xOffset = (r.getPicSizeX() - ((r.getPicSizeX() * cols - width) / (cols - 1)));
			float yOffset = (r.getPicSizeY() - ((r.getPicSizeY() * rows - height) / (rows - 1)));

			for (int j = 0; j < rows; j++) { // row-major
				float picY = y + r.getPicSizeY() / 2f + j * yOffset;
				for (int i = 0; i < cols; i++) {
					float picX = x + r.getPicSizeX() / 2f + i * xOffset;
					r.addMove(picX, picY);
					r.addTakePicture(prefix
							+ String.format("%02d", 1 + j) + "-"
							+ String.format("%03d", 1 + i));

					int light = rand.nextInt(4) + 3;
					boolean on = rand.nextBoolean();
					r.addLightSwitch(light + "", on);
				}
			}
			return cols + " columns, " + rows + " rows";
		}
		return "";
	}

	/**
	 * Sets up a 3D cubical matrix. Takes pictures z-layer by z-layer.
	 * 
	 * @param r
	 * @param x
	 *            start x
	 * @param y
	 *            start y
	 * @param width
	 *            width of matrix
	 * @param height
	 *            height of matrix
	 * @param z
	 *            start z
	 * @param layers
	 *            number of z layers
	 * @param dZ
	 *            change in z between two layers
	 * @return
	 */
	public String setupCube(Rig r, float x, float y, float width, float height,
			float z, float layers, float dZ) {
		if (r != null) {
			for (int i = 0; i < layers; i++) {
				r.addMove(x, y, z + i * dZ);
				setupMatrix(r, x, y, width, height, i + "-");
			}
		}
		return "";
	}

	/**
	 * Sets up the global configuration.
	 * 
	 * @param configName
	 *            the configuration to set up
	 * @throws RuntimeException
	 *             if the configuration isn't defined
	 */
	public void setupGlobalConfiguration(String configName) {
		GlobalConfigManager gcm = new GlobalConfigManager();

		RigSys.GLOBAL_CONFIG = gcm.getConfig(configName);
		if (RigSys.GLOBAL_CONFIG == null) {
			throw new RuntimeException("Configuration not found: " + configName);
		}
		Logger.logln("Config \"" + RigSys.GLOBAL_CONFIG + "\":\n"
				+ configName);
	}

	/**
	 * Sets all the lights on or off.
	 * 
	 * @param r
	 *            the {@link Rig} to operate on
	 * @param on
	 *            true for on, false for off
	 */
	public void allLights(Rig r, boolean on) {
		if (r != null && r.lights() != null) {
			for (String id : r.lights()) {
				r.addLightSwitch(id, on);
			}
		}
	}

	public void setupMatrix(Rig rig, int i, int wid, int hei, int l) {
		setupMatrix(rig, i, wid, hei, l, "");
	}
}
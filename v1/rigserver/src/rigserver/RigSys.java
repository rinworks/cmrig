package rigserver;

import jssc.SerialPortException;
import processing.core.PApplet;
import rigserver.Config.GlobalConfigData;

/**
 * Class that handles the overall rig system.
 *
 * @author Sarang Joshi
 */
public class RigSys {
	public static final int L1SIM = 0;
	public static final int SERIAL = 3;

	// TODO: FIX. TERRIBLY INACCURATE, CHANGES FOR EACH PICTURE AND Z-VALUE
	public static final float SUPEREYES_PIC_SIZE_X = 12.5f;
	public static final float SUPEREYES_PIC_SIZE_Y = 9f;

	public static final float DINO = 2.3f;
	public static final float LOL = 10f;

	public static final boolean DEBUG = true;
	public static final boolean DEEP_DEBUG = false;

	public static GlobalConfigData GLOBAL_CONFIG;
	
	private PApplet app;

	/**
	 * Creates a new Rig system.
	 */
	public RigSys(PApplet app) {
		this.app = app;

		// Logging
		// Logger.setup(Logger.CONSOLE);
	}

	/**
	 * Opens a new simulated rig.
	 *
	 * @returns null if the type is not that of a sim rig
	 */
	public Rig openSimRig(int type, float boundsX, float boundsY, float initX,
			float initY, float picSizeX, float picSizeY, String in, String out) {
		switch (type) {
		case L1SIM:
			return new L1SimRig(app, boundsX, boundsY, initX, initY, picSizeX,
					picSizeY, in, out);
		default:
			return null;
		}
	}

	/**
	 * Opens a new real rig.
	 *
	 * @param directory
	 *            the directory to save images under
	 */
	public Rig openRealRig(int wid, int hei, String directory) {
		try {
			return new SerialRig(app, wid, hei, directory);
		} catch (SerialPortException e) {
			System.err.println("Printer not connected.");
		}
		return null;
	}

	/**
	 * Opens a new rig, given the parent applet, the type of rig, with
	 * <b><i>default</i></b> configuration details from the global
	 * configuration.
	 * 
	 * @param type
	 * @return
	 */
	public Rig openDefaultRig(int type, int wid, int hei, String dir) {
		switch (type) {
		case SERIAL:
			return openRealRig(wid, hei, dir);
		case L1SIM:
		default:
			return openSimRig(type, wid, hei, 110f, 110f, 200f, 200f,
					"fossil.jpg", dir);
		}
	}

	public interface StepFinishedListener {
		void stepFinished(boolean success);
	}
}
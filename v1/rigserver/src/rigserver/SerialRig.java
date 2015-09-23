package rigserver;

import java.util.*;

import jssc.*;
import processing.core.PApplet;
import processing.video.Capture;
import rigserver.RigSys.StepFinishedListener;
import cc.arduino.Arduino;

public class SerialRig implements Rig, StepFinishedListener {
	PApplet app;

	public static final int PIC_MILLIS = 2500;
	public static final int LIGHT_MILLIS = 450;
	public static final int MOVE_MILLIS = 250;
	public static final int FEED_RATE = 3000;

	private Queue<Step> steps;
	private Step step;

	// Printer
	private SerialPort printerPort;

	// Camera
	private Capture cam1;

	// Lights
	private String[] lightIds;
	private Arduino ino;

	// Saving
	private String dir;

	private PrinterHelper printerHelper;

	public static final String OK = "ok";
	public static final String WAIT = "wait";
	public static final String ERROR = "error";

	public enum PrinterType {
		PRINTRBOT, ROSTOCKMAX
	}

	public enum SerialResponse {
		SUCCESS, WAIT, FAIL
	}

	public SerialRig(PApplet app, int camWidth, int camHeight, String directory)
			throws SerialPortException/* , RuntimeException */{
		this.app = app;
		if (RigSys.DEBUG)
			Logger.logln();

		this.steps = new LinkedList<Step>();
		this.step = null;
		this.dir = directory;

		// Printer
		if (RigSys.GLOBAL_CONFIG.printerType == PrinterType.PRINTRBOT)
			this.printerHelper = new PrintrBotHelper();
		else if (RigSys.GLOBAL_CONFIG.printerType == PrinterType.ROSTOCKMAX)
			this.printerHelper = new RostockMaxHelper();

		this.printerPort = new SerialPort(RigSys.GLOBAL_CONFIG.printerPort);
		printerPort.openPort();
		printerPort.setParams(RigSys.GLOBAL_CONFIG.printerBaudRate, 8, 1, 0);
		if (RigSys.DEBUG)
			Logger.logln("Printer connected.");

		// Always initialize
		steps.add(GCodeStep.init(this, printerPort, printerHelper));

		// Camera
		if (cameraExists(RigSys.GLOBAL_CONFIG.mainCamera)) {
			this.cam1 = new Capture(app, camWidth, camHeight,
					RigSys.GLOBAL_CONFIG.mainCamera);
			if (RigSys.DEBUG)
				Logger.logln("Camera connected.");
			cam1.start();
		} else {
			this.cam1 = null;
			if (RigSys.DEBUG)
				Logger.logln("Camera not connected.");
		}

		// Lights
		try {
			ino = new Arduino(app, RigSys.GLOBAL_CONFIG.arduinoPort, 57600);
			for (int i = 0; i < 13; i++) {
				ino.pinMode(i, Arduino.OUTPUT);
				ino.digitalWrite(i, Arduino.HIGH);
			}
			if (RigSys.DEBUG)
				Logger.logln("Arduino connected.");
			lightIds = RigSys.GLOBAL_CONFIG.lights;
		} catch (Exception e) {
			ino = null;
			if (RigSys.DEBUG)
				Logger.logln("Arduino not connected.");
		}

		if (RigSys.DEBUG)
			Logger.logln();
	}

	/**
	 * Checks if the current sequence of moves is valid, i.e. within the
	 * printer's safe bounds.
	 * 
	 * @return validity
	 */
	public boolean movesValid() {
		// Queue<SerialStep> temp = new LinkedList<SerialStep>();
		for (Step s : steps) {
			if (s instanceof Move) {
				Move move = (Move) s;
				if (!printerHelper.positionValid(move.getX(), move.getY()))
					return false;
			} else if (s instanceof Move3D) {
				Move3D move = (Move3D) s;
				if (!printerHelper.positionValid(move.getX(), move.getY(), move.getZ()))
					return false;
			}
		}
		return true;
	}

	@Override
	public void draw() {
		if (cam1 != null) {
			if (cam1.available()) {
				cam1.read();
			}
			app.image(cam1, 0, 0);
		} else {
			app.text("No camera connected.", 0, 0);
		}
	}

	/**
	 * Must be called to start the rig execution.
	 */
	@Override
	public void go() {
		if (movesValid()) {
			if (!steps.isEmpty()) {
				step = steps.remove();
				if (RigSys.DEBUG)
					announce();
				step.go();
			}
		}
	}

	/**
	 * Implementation of the StepFinishedListener
	 */
	@Override
	public void stepFinished(boolean success) {
		if (success) {
			if (RigSys.DEBUG)
				Logger.logln(" finished! ---");
			if (!steps.isEmpty()) {
				step = steps.remove();
				if (RigSys.DEBUG)
					announce();
				step.go();
			} else {
				finish(true);
			}
		} else {
			finish(false);
		}
	}

	/**
	 * Finishes the execution.
	 */
	public void finish(boolean success) {
		if (RigSys.DEBUG)
			Logger.logln(success ? "Done!" : "Aborted.");
		try {
			if (printerPort.isOpened())
				printerPort.closePort();
			if (RigSys.DEBUG)
				Logger.logln("Printer port closed.");
		} catch (SerialPortException e) {
		}
	}

	public void announce() {
		Logger.log("--- " + step.toString() + " ...");
	}

	// Step Setup
	@Override
	public void addMove(float x, float y) {
		steps.add(new Move(this, printerPort, printerHelper, x, y));
		steps.add(new Wait(this, SerialRig.MOVE_MILLIS));
	}

	public void addMove(float x, float y, float z) {
		steps.add(new Move3D(this, printerPort, printerHelper, x, y, z));
		steps.add(new Wait(this, SerialRig.MOVE_MILLIS));
	}

	@Override
	public void addTakePicture(String name) {
		// Only take a picture if there's a camera connected
		if (cam1 != null) {
			steps.add(new Wait(this, SerialRig.PIC_MILLIS));
			steps.add(new Picture(this, cam1, name, dir));
		}
	}

	@Override
	public void addLightSwitch(String id, boolean isOn) {
		// Only add a light switch if the Arduino has been connected
		if (ino != null) {
			steps.add(new LightSwitch(this, ino, Integer.parseInt(id), isOn));
			steps.add(new Wait(this, LIGHT_MILLIS));
		}
	}

	@Override
	public String[] lights() {
		return lightIds;
	}

	/**
	 * @param name
	 *            the name of the camera
	 * @return if the given camera is connected
	 */
	public boolean cameraExists(String name) {
		String[] cameras = Capture.list();
		for (String camera : cameras) {
			if (camera.contains(name))
				return true;
		}
		return false;
	}

	public float getPicSizeX() {
		return RigSys.DINO;
	}

	public float getPicSizeY() {
		return RigSys.DINO;
	}

	public interface PrinterHelper {
		public String initialize();

		public boolean positionValid(float x, float y, float z);

		public String waitForFinish();

		public boolean positionValid(float x, float y);

		public SerialResponse handleRx(String rxString);
	}

	public static class PrintrBotHelper implements PrinterHelper {
		public static final float X_BOUND = 152.4f;
		public static final float Y_BOUND = 152.4f;

		public static final float Z_LOW = 50f;
		public static final float Z_HIGH = 70f;
		
		@Override
		public String initialize() {
			return "G28 X Y\nG0 F" + SerialRig.FEED_RATE + "\n";
		}

		// TODO: Is this really necessary?
		@Override
		public String waitForFinish() {
			return "G4 P0\n";
		}

		@Override
		public boolean positionValid(float x, float y) {
			boolean xOkay = x >= 0 && x <= X_BOUND;
			boolean yOkay = y >= 0 && y <= Y_BOUND;
			return xOkay && yOkay;
		}

		@Override
		public SerialResponse handleRx(String rxString) {
			if (rxString.contains(SerialRig.OK)) { // line completed
				return SerialResponse.SUCCESS;
			} else {
				return SerialResponse.FAIL;
			}
		}

		/**
		 * Not too precise because of PrintrBot's unfortunate lack of Z calibration.
		 * TODO: fix?
		 */
		@Override
		public boolean positionValid(float x, float y, float z) {
			return positionValid(x, y) && (z >= Z_LOW && z <= Z_HIGH);
		}
	}

	public static class RostockMaxHelper implements PrinterHelper {
		public static final float Z_FERN = 171.61f;
		public static final float Z_FOSSIL = 290f;
		public static final float Z_SAFE = 344.61f; // 50 off from home
		public static final float Z_FLOWER = 202.61f;

		public static final float Z_HOME = 394.61f;
		public static final float Z_LOW = 180f;
		public static final float Z_INIT = Z_SAFE;
		
		public static final float Z_DIFF = 2f;

		public static final float BED_RADIUS = 120f;
		public static final float BUFFER = 10f;

		public String initialize() {
			String home = "G28 X0 Y0 Z0\n";
			//String setFeedRate = "G0 F" + SerialRig.FEED_RATE + "\n";
			String setZ = GCodeHelper.ABS_MOVEMENT + GCodeHelper.MOVE_PREFIX
					+ " Z" + Z_INIT;
			return home + /*setFeedRate +*/ setZ;
		}

		public String waitForFinish() {
			return "M400\n";
		}

		public boolean positionValid(float x, float y) {
			return (x * x + y * y) <= Math.pow(BED_RADIUS - BUFFER, 2);
		}

		// TODO: buff this up
		public SerialResponse handleRx(String rxString) {
			if (rxString.contains(SerialRig.OK)) {
				return SerialResponse.SUCCESS;
			} else if (rxString.contains(SerialRig.ERROR)) {
				return SerialResponse.FAIL;
			} else {
				return SerialResponse.WAIT;
			}
		}

		@Override
		public boolean positionValid(float x, float y, float z) {
			return positionValid(x, y) && (z >= Z_LOW && z <= Z_HOME);
		}
	}

	/**
	 * Abstract class that represents a single step in the Rig's set of
	 * instructions.
	 *
	 * @author Sarang Joshi
	 */
	static abstract class Step {
		protected StepFinishedListener l;

		public Step(StepFinishedListener l) {
			this.l = l;
		}

		public abstract void go();
	}

	static class GCodeStep extends Step implements SerialPortEventListener {
		protected SerialPort port;
		protected String[] code;
		protected int lineN;
		protected PrinterHelper helper;
		private String rxString;

		public GCodeStep(StepFinishedListener l, SerialPort port,
				PrinterHelper help) {
			this(l, port, help, "");
		}

		public GCodeStep(StepFinishedListener l, SerialPort port,
				PrinterHelper help, String codeString) {
			super(l);
			this.port = port;
			this.helper = help;
			this.lineN = 0;
			this.rxString = "";

			if (!codeString.isEmpty())
				setGCode(codeString);
		}

		/**
		 * Saves the given g codes.
		 *
		 * @param codeString
		 *            a string containing g codes separated by \\n line breaks
		 */
		public void setGCode(String codeString) {
			this.code = GCodeHelper.parseGCode(codeString, "\n");
		}

		private void sendGCode() throws SerialPortException {
			port.writeString(code[lineN]);
			if (RigSys.DEEP_DEBUG)
				Logger.log("SENT: " + code[lineN]);
		}

		public void go() {
			if (code.length > 0)
				try {
					port.addEventListener(this);
					sendGCode();
				} catch (SerialPortException e) {
					e.printStackTrace();
				}
			else
				l.stepFinished(true); // empty code?
		}

		/**
		 * Message received from printer.
		 *
		 * @param event
		 *            the serial port event information
		 */
		public void serialEvent(SerialPortEvent event) {
			if (event.isRXCHAR()) {
				try {
					String in = port.readString();
					// Appending instead of replacing -- sometimes the printer
					// sends 'o' and 'k' separately for some reason
					rxString += in;
					if (RigSys.DEEP_DEBUG)
						Logger.log("RECD: " + in);

					// Only handle the response if it's a complete response
					if (rxString.endsWith(GCodeHelper.LINE_BREAK)) {
						// Use the helper to interpret the received string
						SerialResponse resp = helper.handleRx(rxString);

						if (resp == SerialResponse.SUCCESS) {
							rxString = ""; // reset received message
							lineN++;
							if (lineN >= code.length) { // all the code finished
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

		/**
		 * Returns a string representation of this g code step.
		 */
		public String toString() {
			String[] clean = new String[code.length];
			for (int i = 0; i < code.length; i++) {
				if (code[i].endsWith(GCodeHelper.LINE_BREAK))
					clean[i] = code[i].substring(0, code[i].length() - 1);
				else
					clean[i] = code[i];
			}
			return Arrays.toString(clean);
		}

		/**
		 * INIT
		 */
		public static GCodeStep init(StepFinishedListener l, SerialPort port,
				PrinterHelper help) {
			return new GCodeStep(l, port, help, help.initialize()) {
				@Override
				public String toString() {
					return "Initialize";
				}
			};
		}

	}

	static class Move extends GCodeStep {
		private float x, y;

		public Move(StepFinishedListener l, SerialPort port,
				PrinterHelper help, float x, float y) {
			super(l, port, help);
			this.x = x;
			this.y = y;

			this.setGCode(GCodeHelper.getMoveGCode(x, y) + help.waitForFinish());
		}

		public float getX() {
			return x;
		}

		public float getY() {
			return y;
		}

		public String toString() {
			return "Move to X:" + x + ", Y:" + y;
		}
	}

	static class Move3D extends GCodeStep {
		private float x, y, z;

		public Move3D(StepFinishedListener l, SerialPort port,
				PrinterHelper help, float x, float y, float z) {
			super(l, port, help);
			this.x = x;
			this.y = y;
			this.z = z;

			this.setGCode(GCodeHelper.getMove3DGCode(x, y, z)
					+ help.waitForFinish());
		}

		public float getX() {
			return x;
		}

		public float getY() {
			return y;
		}

		public float getZ() {
			return z;
		}

		public String toString() {
			return "Move to X:" + x + ", Y:" + y + ", Z:" + z;
		}
	}

	static class Picture extends Step {
		String picN;
		Capture video;
		String dir;

		public Picture(StepFinishedListener l, Capture video, String picN,
				String directory) {
			super(l);
			this.picN = picN;
			this.video = video;
			this.dir = directory;
		}

		public void go() {
			if (video.available())
				video.read();
			video.save("output/" + dir + "/" + picN + ".jpg");
			if (RigSys.DEEP_DEBUG)
				Logger.logln("Picture " + picN + " saved.");
			l.stepFinished(true);
		}

		public String toString() {
			return "Taking picture " + picN;
		}
	}

	static class LightSwitch extends Step {
		Arduino ino;
		int pin;
		boolean isOn;

		public LightSwitch(StepFinishedListener l, Arduino ino, int id,
				boolean isOn) {
			super(l);
			this.ino = ino;
			this.pin = id;
			this.isOn = isOn;
		}

		public void go() {
			// On corresponds to LOW
			ino.digitalWrite(pin, (isOn ? Arduino.LOW : Arduino.HIGH));
			if (RigSys.DEEP_DEBUG)
				Logger.logln("Light " + pin + " turned o"
						+ (isOn ? "n." : "ff."));
			l.stepFinished(true);
		}

		public String toString() {
			return "Light " + pin + " o" + (isOn ? "n" : "ff");
		}
	}

	public class Wait extends Step {
		int duration;

		public Wait(StepFinishedListener l, int duration) {
			super(l);
			this.duration = duration;
		}

		public void go() {
			try {
				Thread.sleep(duration); // pauses execution!!
			} catch (InterruptedException ignored) {
			}
			l.stepFinished(true);
		}

		public String toString() {
			return "Wait for " + duration + "ms";
		}
	}

}
package rigserver;

import java.util.*;
import processing.core.*;

/**
 * A level-1 simulator of the rig system.
 *
 * @author Sarang Joshi
 */
public class L1SimRig implements Rig {
	static final int DEFAULT_CAM_SIZE = 20;
	static final int MARGIN = 10;
	static final int FPS = 60;
	static final int DEFAULT_TICKS = 30;

	PApplet app;

	// The zone in which the Rig can operate
	float zoneX, zoneY, zoneWidth, zoneHeight;

	// Rig state
	float x, y;
	int size;
	float picSizeX, picSizeY;
	float imgScaleX, imgScaleY;

	// Steps
	Queue<Step> steps;
	List<Step> pastSteps;
	Step curr = null;
	boolean paused = true;
	int picN = 0;

	PImage img;
	Light[] lights;

	String outputName;

	public L1SimRig(PApplet app, float boundsX, float boundsY, float x,
			float y, float picSizeX, float picSizeY, String inputName,
			String outputName) {
		this.app = app;

		this.zoneX = MARGIN;
		this.zoneY = MARGIN;
		this.zoneWidth = boundsX - 2 * MARGIN;
		this.zoneHeight = boundsY - 2 * MARGIN;
		this.x = x;
		this.y = y;
		this.size = DEFAULT_CAM_SIZE;
		this.picSizeX = picSizeX;
		this.picSizeY = picSizeY;

		this.img = app.loadImage("input/" + inputName);
		this.outputName = outputName;

		// how much the real image is scaled down by
		this.imgScaleX = (float) zoneWidth / (float) img.width;
		this.imgScaleY = (float) zoneHeight / (float) img.height;

		this.steps = new LinkedList<Step>();
		this.pastSteps = new ArrayList<Step>();

		this.setupLights();
	}

	// // DRAWING, OUTPUT ////
	public void draw() {
		drawImage();
		drawZone();
		drawPaths();
		drawCam();
		drawLights();

		// non-drawing
		tick();
	}

	public void drawImage() {
		app.image(img, MARGIN, MARGIN, zoneWidth, zoneHeight);
	}

	public void drawZone() {
		app.noFill();
		app.rectMode(PApplet.CORNER);
		app.stroke(0);
		app.rect(zoneX, zoneY, zoneWidth, zoneHeight);
	}

	// Draws actual rig camera
	public void drawCam() {
		app.stroke(0);
		app.fill(0x000000);
		app.rectMode(PConstants.CENTER);
		app.rect(x, y, size, size);

		// if(RigSys.DEBUG){fill(255);text(round(x)+", "+round(y),x,y);}
	}

	public void drawPaths() {
		for (Step s : pastSteps) {
			s.draw();
		}
	}

	public void drawLights() {
		for (Light l : lights) {
			l.draw();
		}
	}

	// // TICK-BASED OPERATIONS ////
	// Goes through the compiled moves sequentially
	public void go() {
		if (!steps.isEmpty()) {
			curr = steps.remove();
			pastSteps.add(curr);
			curr.init();
			paused = false;
			if (RigSys.DEBUG)
				System.out.println("Go!");
		}
	}

	// One tick
	public void tick() {
		if (!paused) {
			try {
				if (curr.isFinished()) {
					curr.finish();
					if (RigSys.DEBUG)
						System.out.println(curr.finishMessage());
					curr = steps.remove();
					pastSteps.add(curr);
					curr.init();
				} else {
					curr.tick();
				}
			} catch (NoSuchElementException e) {
				if (RigSys.DEBUG)
					System.out.println("Done.");
				paused = true;
			}
		}
	}

	// // SETUP ////
	/**
	 * Offset by MARGIN
	 */
	public void addMove(float x, float y) {
		steps.add(new Move(x + MARGIN, y + MARGIN, this));
	}

	/**
	 * There is no "z", so this just calls the {@link addMove} method with only
	 * x and y parameters.
	 */
	public void addMove(float x, float y, float z) {
		this.addMove(x, y);
	}
	
	public void addTakePicture(String name) {
		steps.add(new Picture(FPS, name, this));
		picN++;
	}

	public void addLightSwitch(String id, boolean isOn) {
		steps.add(new LightSwitch(id, isOn, FPS, this));
	}

	// // LIGHTS ////
	public void setupLights() {
		lights = new Light[4];
		lights[0] = new Light(Light.SIZE / 2, Light.SIZE / 2, "NW");
		lights[1] = new Light(zoneWidth + MARGIN + Light.SIZE / 2,
				Light.SIZE / 2, "NE");
		lights[2] = new Light(zoneWidth + MARGIN + Light.SIZE / 2, zoneHeight
				+ MARGIN + Light.SIZE / 2, "SE");
		lights[3] = new Light(Light.SIZE / 2, zoneHeight + MARGIN + Light.SIZE
				/ 2, "SW");
	}

	public void on(String id) {
		for (Light l : lights)
			if (l.id.equals(id))
				l.on();
	}

	public void off(String id) {
		for (Light l : lights)
			if (l.id.equals(id))
				l.off();
	}

	public String[] lights() {
		String[] l = new String[lights.length];
		for (int i = 0; i < lights.length; i++) {
			l[i] = lights[i].id;
		}
		return l;
	}

	// // OPERATIONS ////
	// Coarse movement
	public void change(float dX, float dY) {
		x += dX;
		y += dY;
	}

	public boolean isInZone() {
		return !(x < zoneX || y < zoneY || x + size > zoneX + zoneWidth || y
				+ size > zoneY + zoneHeight);
	}

	// Picture-taking
	public PImage takePicture() {
		int cropW = Math.round(picSizeX / imgScaleX);
		int cropH = Math.round(picSizeY / imgScaleY);
		int cropX = Math.round((x - MARGIN - picSizeX / 2) / imgScaleX);
		int cropY = Math.round((y - MARGIN - picSizeY / 2) / imgScaleY);

		return img.get(cropX, cropY, cropW, cropH);
	}

	public float getPicSizeX() {
		return picSizeX;
	}

	public float getPicSizeY() {
		return picSizeY;
	}

	class MovePath {
		List<PVector> points;

		public MovePath(float sx, float sy) {
			points = new ArrayList<PVector>();
			addPoint(sx, sy);
		}

		public void addPoint(float x, float y) {
			points.add(new PVector(x, y));
		}

		public void draw() {
			app.stroke(255);
			for (int i = 0; i < points.size() - 1; i++) {
				app.line(points.get(i).x, points.get(i).y, points.get(i + 1).x,
						points.get(i + 1).y);
			}
		}
	}

	class PicturePath {
		float x, y;

		public PicturePath(float x, float y) {
			this.x = x;
			this.y = y;
		}

		public void draw() {
			app.stroke(255, 0, 0);
			app.fill(255, 0, 0);
			app.ellipse(x, y, 16, 16);
		}
	}

	interface Step {
		void init();

		void tick();

		boolean isFinished();

		void finish();

		String finishMessage();

		void draw();
	}

	class Move implements Step {
		float endX, endY;
		float tickX, tickY;
		int nOfTicks;
		float buffer;
		MovePath path;
		L1SimRig rig;

		public Move(float x, float y, L1SimRig r) {
			endX = x;
			endY = y;
			rig = r;
		}

		public void init() {
			float dX = endX - rig.x;
			float dY = endY - rig.y;
			float d = (float) Math.sqrt(dX * dX + dY * dY);
			if (Math.round(d) != 0) {
				nOfTicks = (int) (d / 0.8);
			} else {
				nOfTicks = L1SimRig.DEFAULT_TICKS;
			}
			tickX = dX / nOfTicks;
			tickY = dY / nOfTicks;
			buffer = (float) (Math.sqrt(tickX * tickX + tickY * tickY) / 2.0f)
					+ PApplet.EPSILON;
			path = new MovePath(rig.x, rig.y);
		}

		public void tick() {
			rig.change(tickX, tickY);
			path.addPoint(rig.x, rig.y);
		}

		public void finish() {
		}

		public boolean isFinished() {
			return PApplet.dist(rig.x, rig.y, endX, endY) <= buffer;
		}

		public String finishMessage() {
			return "Moved to " + (endX) + ", " + (endY) + ".";
		}

		public void draw() {
			if (path != null)
				path.draw();
		}
	}

	class Picture implements Step {
		int nOfTicks;
		int tick;
		String name;
		PicturePath path;
		L1SimRig rig;

		public Picture(int nOfTicks, String n, L1SimRig r) {
			this.nOfTicks = nOfTicks;
			this.name = n;
			this.rig = r;
		}

		public void init() {
			tick = 0;
			path = new PicturePath(rig.x, rig.y);

			PImage cropImage = rig.takePicture();
			cropImage.save("output/picCrop" + picN + ".jpg");
		}

		public void tick() {
			tick++;
		}

		public void finish() {
		}

		public boolean isFinished() {
			return tick == nOfTicks;
		}

		public String finishMessage() {
			return "Picture taken.";
		}

		public void draw() {
			if (path != null)
				path.draw();
		}
	}

	class LightSwitch implements Step {
		String id;
		int nOfTicks;
		boolean isOn;
		int tick;
		L1SimRig rig;

		public LightSwitch(String id, boolean isOn, int nOfTicks, L1SimRig r) {
			this.id = id;
			this.nOfTicks = nOfTicks;
			this.isOn = isOn;
			this.rig = r;
		}

		public void init() {
			tick = 0;
		}

		public void tick() {
			tick++;
		}

		public void finish() {
			if (isOn)
				rig.on(id);
			else
				rig.off(id);
		}

		public boolean isFinished() {
			return nOfTicks == tick;
		}

		public void draw() {
		}

		public String finishMessage() {
			return "Light id " + id + " switched o" + (isOn ? "n." : "ff.");
		}
	}

	class Light {
		public static final int SIZE = 10;

		boolean isOn;
		float x, y;
		String id;

		public Light(float x, float y, String id) {
			this.x = x;
			this.y = y;
			this.isOn = true;
			this.id = id;
		}

		void toggle() {
			isOn = !isOn;
		}

		void on() {
			isOn = true;
		}

		void off() {
			isOn = false;
		}

		void draw() {
			if (isOn) {
				app.stroke(255);
				app.fill(255);
			} else {
				app.stroke(0);
				app.fill(0);
			}
			app.ellipse(x, y, SIZE, SIZE);
		}
	}
}

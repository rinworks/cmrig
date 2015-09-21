import processing.core.PApplet;
import rigserver.*;
import rigserver.SerialRig.*;

public class RigClient extends PApplet {
	/**
	 * ??!!
	 */
	private static final long serialVersionUID = 1L;

	RigSys sys;
	Rig rig;

	public void setup() {
		size(640, 480);

		sys = new RigSys(this);
		RigUtils.setupGlobalConfiguration("RostockMakerFaireSJ");
		
		rig = sys.openDefaultRig(RigSys.SERIAL, width, height,
				"makerfaire-demo");
		float val = (float) ((RostockMaxHelper.BED_RADIUS) / Math.sqrt(2.0));
		float startX = -20f, startY = -20f, wid = 40f, hei = 40f;
		RigUtils.allLights(rig, false);

		rig.addMove(20, 20);
		rig.addMove(25, 25);
		rig.addTakePicture("superdistinctivenamelol");

		if (rig != null)
			rig.go();
	}

	public void draw() {
		background(127.0f);
		if (rig != null)
			rig.draw();
	}
}
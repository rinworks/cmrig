import processing.core.PApplet;
import rigserver.*;
import rigserver.SerialRig.*;

@SuppressWarnings("serial")
public class RigClient extends PApplet {
	RigSys sys;
	Rig rig;

	public void setup() {
		size(1280, 960);

		sys = new RigSys(this);
		sys.utils().setupGlobalConfiguration("RostockMakerFaireSJ");

		rig = sys.openDefaultRig(RigSys.SERIAL, width, height,
				"micromakerfaire");
		
		//sys.utils().allLights(rig, true);
		sys.utils().setupMatrix(rig, -30, -30, 60, 60);
		
		rig.addMove(20, 20);
		
		//sys.utils().setupCube(rig, -30, -25, 10, 10, RostockMaxHelper.Z_INIT, 10, RostockMaxHelper.Z_DIFF);
		// rig.addMove(20, 20, RostockMaxHelper.Z_INIT - 10);

		if (rig != null)
			rig.go();
	}

	public void draw() {
		background(127.0f);
		if (rig != null)
			rig.draw();
	}
}
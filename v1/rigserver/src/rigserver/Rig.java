package rigserver;

public interface Rig {
	public void draw();

	public void go();

	public void addMove(float x, float y);
	
	public void addMove(float x, float y, float z);

	/**
	 * @param name name of the picture without extension
	 */
	public void addTakePicture(String name);

	public void addLightSwitch(String id, boolean isOn);

	public String[] lights();
	
	public float getPicSizeX();

	public float getPicSizeY();
}

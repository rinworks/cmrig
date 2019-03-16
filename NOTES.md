# CMRig: Design and Implementation Notes


## 2019 March 16: JMJ - Design decisions for 2019

_Options_
- Full 6 degrees of motion vs reduced
- Abandon the delta-printer approach for other approaches or keep the delta printer
- Size of object being photographed
- Does object have to move or can it be stationary
- Lighting based on individual hand-positioned lights or a fabric of led lights

_Decisions_
- Keep delta-printer. We have a working system that moves in x-y-z with decent precision and stability. Let's use that to the max
  before exploring other options.
- Motion/orientation:
	- Focus on looking downwards first - x-y-z and direction of
	  camera is downwards. This is what we have currently. It can be used to
	  explore stitching and more importantly, can be used for 3D. So it'll keep us
	  busy for a long time.
	- Next add a mirror to direct view horizontally. This mirror should (initially) be manually rotated above a horizontal
	  axis, allowing the camera view to be tilted on a vertical plane (upwards/downwards).
	- Also build a computerized rotating turntable. The object can optionally be positioned on this turntable so we get
	  another degree of rotation. The combination of this plus the manual mirror will allow an enormous range of image
	  capture possibilities. This turntable will sit to the side of the delta rig, intruding into it slightly. The object
	  will be photographed from the side with a little tilting of views possible via the mirror.
- Size of object: whatever comfortably fits in the printer base for the downwards view. For sideways view without turntable,
  it can be anything that is brought close to the printer - or the printer brought close to the object. For the turntable,
  roughly a foot across (see turntable design below).
- Object moving or not: does not move unless the turntable is used. When turntable is being used, it can be rotated very slowly
  to minimize g-forces.
- Lighting:
	- Addressing heat generation: a KEY aspect of lighting is that it is only turned on for brief intervals.
	This is to reduce heat produced by lights and
	allow maximum intensity lighting (which in turn enables greatest depth-of-field and lowest noise). Ideally the lights
	are on only for the duration of the actual exposure. Initially we have to do some tests to see how long it takes for
	the lights we have to achieve constant illumination - this can be done using a high speed camera capturing the moment
	the light is turned on.
	- Addressing stray light on background and onto the optics. This must be minimized. For now, this is addressed by
	manually-positioned lights (see below).
	- Initial plan is to simply use the LED 'spot' lights with differs attached. They will be placed as close to
	the object as permissible, with diffusers as large as possible to simulate soft-box lighting. The lighting setup
	will be global for the object - positions and use of gels etc are all done manually - note should be made to help
	with reproducabiltiy. If possible, the positions and orientations of the lights should be something that can be
	manually read off - but initially just photographs of the setup from various directions should suffice - we want to get
	going as soon as possible. Also, we can add baffles to mitigate stray light (if stray-light issues arise). 
	- Lighting does not move. So without a turntable, light stays stationary with respect to object. With turntable,
	the angle of lighting w.r.t object will change as the object rotates. This effect will be mitigated (if that is an issue)
	by reducing the use of directional lighting and emulating uniform ambient lighting. However, the initial plan is 
	to simply position lights in a way that eyeballing test images generated produced pleasing results.
	- Postponed until much later: using LED panels or movable light sources. While these promise much more flexible and
	repeatable lighting conditions, the reality is that they will take a lot of time to get right. In the case of
	individually-addressable LED panels, one issue is controlling the direction of light and issues with stray light.
- 

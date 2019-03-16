## CMRig TODO List
1. [BIG] Get the TOUPCAM L3C MOS camera under full programmatic control. This is going to take a while - we should wrap the supplied
   C++ SDK to a Python library. 
1. [BIG] Write a Python library to control the CMRig. Use learnings from the Java CMRig code.
1. [HUGE] Design and implement large-scale, long running image acquisition and storage support.
   It should be possible to pause and resume acquisition, and to go back and fill holes (assuming the physical setup exists).
   Should work across both capture and acquisition devices power cycles. (x,y,z) and camera orientation and camera parameters
   like focal length should be included in metadata.
1. [BIG] Start large scale acquisition - a 3D grid, including various z-levels.
1. [HUGE] Write programmatic image stitching pipeline that picks optimal z-level image as part of the pipeline. Focus stacking
   is not a priority. The priority is to generate visually compelling high resolution stitched images of mostly flat objects.
1. [BIG] Build out the Periscope <https://github.com/rinworks/periscope> and build the software that allows exploring
   3D viewing.

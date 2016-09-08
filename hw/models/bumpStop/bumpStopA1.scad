//
// Project: CMRig - BumpStop part A - this attaches to the affector platform adaptor
// History: Y16M09D08 JMJ  Started 1st version
//

// Parameters
magnetDia=19.1; // actual magnet dia
magnetHeight=4.8; // actual magnet height
magnetDiaSpace=0.5; // wiggle room for magnet
magnetHeightContraction=0.5; // make the depth slight less than magnet.

hCone = magnetHeight-magnetHeightContraction; // Height of cone
hMagnet = magnetHeight-magnetHeightContraction; // Height of magnet well
holeInnerDia = magnetDia+magnetDiaSpace; // narrow part of cone
holeOuterDia = holeInnerDia+2*hCone; // wider part of cone - 45 degree cone.
wallThickness=2; // also base thickness.
outerDia = holeOuterDia+max(2,wallThickness); // of magnet recepticle
switchDia = 7.9; // Hole to place switch.
// Note: pushbutton switch is located midway between holes.
switchFootprintDia = 9.9; // Diameter of pushbutton flange

holeDistanceGap = max(switchFootprintDia+2, 15); // Make sure there is enough distance to place the switch!
holeDistance = outerDia+holeDistanceGap; // distance between the 2 holes for magnets


baseLengthExtra = 10; // How much extra length to base
baseLength = 2*outerDia + holeDistanceGap + baseLengthExtra; // (printed along x)
baseWidth = outerDia; //(along y)
baseDepth = wallThickness; // (along z)


union() {
    x1 = outerDia/2; // x position of center of first magnet recepticle
    x2 = x1 + holeDistance; // x position for 2nd center...
    switchX = (x1+x2)/2; //midway between the two
    
    // Base    
    base(baseLength, baseWidth, switchDia, switchX);
    
    // The two magnet receptacles...
    translate([x1, baseWidth/2, baseDepth])
        magnetReceptacle(holeInnerDia, holeOuterDia, outerDia, hMagnet, hCone, $fn=60);    
    translate([x2, baseWidth/2, baseDepth])
        magnetReceptacle(holeInnerDia, holeOuterDia, outerDia, hMagnet, hCone, $fn=60);
}

// The base
//   switchDia: dia of switch hole
//   switchX: x position of center of switch hole
//  Note: the end closer to x=0 is a semi-circle
module base(baseLength, baseWidth, switchDia, switchX) {
    union() {
        translate([baseWidth/2, baseWidth/2, 0]) 
            cylinder(h=baseDepth, d=baseWidth);
        difference() {
            translate([baseWidth/2, 0, 0])
                cube([baseLength-baseWidth/2, baseWidth, baseDepth]);
            translate([switchX, baseWidth/2, -1])
                cylinder(h=baseLength+2, d=switchDia, $fn=60);
        }
    }
}

// A single magnet Recptacle
// It is centered on the origin
// Overall depth (along z) is (hMagnet+hCone)
module magnetReceptacle(holeInnerDia, holeOuterDia, outerDia, hMagnet, hCone) {
    difference() {
        cylinder(h=hMagnet+hCone, d=outerDia);
        union() {
            translate([0,0,-1])
                cylinder(h=hMagnet+2, d=holeInnerDia);
            translate([0,0, hMagnet])
                cylinder(h=hCone*1.01, d1=holeInnerDia, d2=holeOuterDia);
        }
    }
}

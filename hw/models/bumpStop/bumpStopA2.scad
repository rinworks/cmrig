//
// Project: CMRig - BumpStop part A - this attaches to the affector platform adaptor
// History: Y16M09D08 JMJ  Started 1st version
//          Y16M09D08 JMJ  Made cones shallower and other mods
//
// TODO:
//  - Reduce magnetHeightContraction to 0 - so magnet is level.
//  - Reduce cone hight to 1mm - this will also reduce width.
//  - Hardcode inter-(magnet)-hole distance - so it matches part B.
//  - Merge part A and B into one - just save STL files separately.
//      (this is because they are too closely related).
//  - Fix issue with the central stump hitting receptacle walls on
//    movement - requires the hole distance to be wider

// Parameters
magnetDia=19.1; // actual magnet dia
magnetHeight=4.8; // actual magnet height
magnetDiaSpace=1.0; // wiggle room for magnet
magnetHeightContraction=0.25; // make the depth slight less than magnet.
coneHeightFrac = 1/tan(20); // 20 degrees.

hCone = 2; // Height of cone
hMagnet = magnetHeight-magnetHeightContraction; // Height of magnet well
holeInnerDia = magnetDia+magnetDiaSpace; // narrow part of cone
holeOuterDia = holeInnerDia+2*hCone*coneHeightFrac; // wider part of cone - 45 degree cone.
wallThickness=2; // also base thickness.
outerDia = holeOuterDia+max(2,wallThickness); // of magnet recepticle
switchDia = 7.9; // Hole to place switch.
switchExtraSpace = 0.2;
switchHoleDia = switchDia+switchExtraSpace;
// Note: pushbutton switch is located midway between holes.
switchFootprintDia = 9.9; // Diameter of pushbutton flange

holeDistanceGap = max(switchFootprintDia+2, 15); // Make sure there is enough distance to place the switch!
holeDistance = outerDia+holeDistanceGap; // distance between the 2 holes for magnets


baseLengthExtra = 10; // How much extra length to base
baseLength = 2*outerDia + holeDistanceGap + baseLengthExtra; // (printed along x)
baseWidth = outerDia*0.75; //(along y)
baseDepth = wallThickness; // (along z)


union() {
    x1 = outerDia/2; // x position of center of first magnet recepticle
    x2 = x1 + holeDistance; // x position for 2nd center...
    switchX = (x1+x2)/2; //midway between the two
    
    // Base    
    base(baseLength, baseWidth, outerDia, holeDistance, switchHoleDia, switchX);
    
    // The two magnet receptacles...
    translate([x1, 0, baseDepth])
        magnetReceptacle(holeInnerDia, holeOuterDia, outerDia, hMagnet, hCone, $fn=60);    
    translate([x2, 0, baseDepth])
        magnetReceptacle(holeInnerDia, holeOuterDia, outerDia, hMagnet, hCone, $fn=60);
}

// The base
//   switchDia: dia of switch hole
//   switchX: x position of center of switch hole
//  Note: the end closer to x=0 is a semi-circle.
//  Note: we also punch switch-hole-sized holes at the base of the 
// recepticles.
module base(baseLength, baseWidth, outerDia, holeDistance, switchDia, switchX) {
    x1 = outerDia/2;
    x2 = x1 + holeDistance;
    difference() {
        union() {
            translate([x1, 0, 0]) 
                cylinder(h=baseDepth, d=outerDia);
            translate([x2, 0, 0]) 
                cylinder(h=baseDepth, d=outerDia);
            translate([x1, -baseWidth/2, 0])
                cube([baseLength-outerDia/2, baseWidth, baseDepth]);
        }
        union() {
                translate([x1, 0, -1])
                    cylinder(h=baseLength+2, d=switchDia, $fn=60);
                translate([x2, 0, -1])
                    cylinder(h=baseLength+2, d=switchDia, $fn=60);
                translate([switchX, 0, -1])
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

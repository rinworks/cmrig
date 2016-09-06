//washer(15, 25, 5);
//pipeSegment(id1=15, id2=20, od1=20, od2=25, h=10);
//radialCylinders(cd=25, pd=3, h=5, angles=[0, 45,90, 180]);
baseThickness=3;
wallThickness=baseThickness; // Thickness of vertical structures.
boltsCircleDia=50;
boltsDia=3;
boltsFlangeDia=10;
boltBigFlangeDia= boltsFlangeDia+2*wallThickness; // to accomodate for cylinder
centralHoleBase=30;
baseOuterDia=boltsCircleDia+boltsDia;
baseExtensionRadius = 79; // From center (it's 29mm from bolt hole center.)
baseExtensionNarrowWidth = 10;
baseExtensionWideWidth = 15;



punchThickness = baseThickness+2; // We extend punch solids by 1 in each direction
difference() {
    union() {
        washer(centralHoleBase, baseOuterDia, baseThickness);
        radialCylinders(cd=boltsCircleDia, pd=boltsFlangeDia, h=baseThickness, angles=[120,240], $fn=60);
        radialCylinders(cd=boltsCircleDia, pd=boltBigFlangeDia, h=baseThickness, angles=[0], $fn=60);
        translate([0,-baseExtensionNarrowWidth/2, 0])
            cube([baseExtensionRadius, baseExtensionNarrowWidth, baseThickness]);
        translate([baseExtensionRadius,-baseExtensionWideWidth/2, 0])
            cube([wallThickness, baseExtensionWideWidth, baseThickness]);
    }
    union() {
    translate([0,0,-1])
        cylinder(d=centralHoleBase, h=punchThickness);
    radialCylinders(cd=boltsCircleDia, pd=boltsDia, h=punchThickness, angles=[0, 120,240], zo=-1, $fn=60);
    }
}



// A washer with base on x-y plane and axis == z-axis
module washer(id, od, h) {
    difference() {
        cylinder(h, d=od, $fn=60);
        translate([0,0,-h*0.05])
            cylinder(h*1.1, d=id, $fn=60);
    }
}

// Creates a segment of a pipe. The center of the segment is the z-axis.
// The base of the segment is the x-y plane. The base inner/outer dia are
// id1/id2 and the top inner/outer dia are id2/od2. The height of the
// segment is h.
module pipeSegment(id1, od1, id2, od2, h) {
    difference() {
        cylinder(h, d1=od1, d2=od2, $fn=60);
        translate([0,0,-h*0.05])
            cylinder(h*1.1, d1=id1, d2=id2, $fn=60);
    }
}

// Creates a union of several cylinders along a circle with diameter cd.
// One application: subtract these from a circular gasket.
// The cylinders have diameter pd and height h. The circle is on the x-y
// plane and it's center the origin. The *base* of the punches is paralel
// to the x-y plane, with z=zo. The cylinders are positioned at the
// specified vector of angles.
module radialCylinders(cd, pd, h, angles, zo) {
    //cylinder(d=pd, h);
    translate([0,0, 0]) {
        for(a = angles) {
            rotate(a)
                translate([cd/2, 0, zo])
                    cylinder(d=pd, h);
        }
    }
}


//washer(15, 25, 5);
//pipeSegment(id1=15, id2=20, od1=20, od2=25, h=10);
//radialCylinders(cd=25, pd=3, h=5, angles=[0, 45,90, 180]);
baseThickness=3;
wallThickness=baseThickness; // Thickness of vertical structures.
boltsCircleDia=50;
boltsDia=3.5;
boltsFlangeDia=18; // This should be wide enough for the cylinder - we make all 3 this wide.
//boltBigFlangeDia= boltsFlangeDia; // [Not needed] to accomodate for cylinder
centralHoleBase=32; // This also happens to match the "bigDia" of the dynolite.
baseOuterDia=boltsCircleDia+boltsDia;
baseExtensionRadius = 54 ; // From center (it's 29mm from bolt hole center.)
baseExtensionNarrowWidth = 10;
baseExtensionWideWidth = 15;

// The microscope support...
msRingBigDia=32;
msRingSmallDia=29.6;
msRingHeight=10;
msRingOffsetFromBase=30; // Vertical distance from x-y plane (*bottom* of base).
msBarWidth=15;
msBarThickness=8 ;
msBarHeight=45+msRingOffsetFromBase+msRingHeight;
msVentHoleDia=20;

// The external support
extSupportCylHeight = 15;
extSupportHeight = 20;

punchThickness = baseThickness+2; // We extend punch solids by 1 in each direction
msBase();
msSuperstructure();

module msBase() {
    difference() {
        union() {
            washer(centralHoleBase, baseOuterDia, baseThickness);
            radialCylinders(cd=boltsCircleDia, pd=boltsFlangeDia, h=baseThickness, angles=[0,120,240], $fn=60);
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
}

module msSuperstructure() {
   
    msOd = msRingBigDia+2*wallThickness;
    extOd = boltsFlangeDia;
    extId = extOd-2*wallThickness;
    extSupportStartRadius = boltsCircleDia/2 + extOd/2;
    union() {
        
        // Ring support (with horizontal vent holes punched in it)
        difference() {
            pipeSegment(id1=msRingBigDia, id2=msRingSmallDia, od1=msOd, od2=msOd, h=msRingOffsetFromBase);
            translate([0, 0, msRingOffsetFromBase/2])
                radialHorizontalCylinders(cd=boltsCircleDia, pd=msVentHoleDia, h=15, angles=[60,-60], $fn=60);
        }
        
        // Ring
        translate([0,0, msRingOffsetFromBase])
            pipeSegment(id1=msRingSmallDia, id2=msRingBigDia, od1=msOd, od2=msOd, h=msRingHeight);
        
        // Vertical Bar
        difference() { 
            translate([-msRingBigDia/2-msBarThickness/2, -msBarWidth/2, 0])
                cube([msBarThickness, msBarWidth, msBarHeight]);
            translate([0,0,-1]) cylinder(d=msRingBigDia, h=msBarHeight+2, $fn=60);
        }
        
        // Cylinder around bolt to give strength to ext support
        translate([boltsCircleDia/2, 0, 0])
            pipeSegment(id1=extId, id2=extId, od1=extOd, od2=extOd, h=extSupportCylHeight);
        
        // The ext support
        translate([baseExtensionRadius,-baseExtensionWideWidth/2, 0])
                    cube([wallThickness, baseExtensionWideWidth, extSupportHeight]);
        
        // Brace from cylinder to ext support
        translate([extSupportStartRadius, 0, 0])
            slopingWall(extSupportCylHeight, extSupportHeight, baseExtensionRadius-extSupportStartRadius, wallThickness);
    }
}


/*





rotate([-90,0,0]) {
difference() {
    cube([tBarWidth, tBarLength, 3*pt+pt]);
    union() {
    translate([tBarWidth/2,-pt/2, bigDia/2+2*pt+pt])
      rotate([-90,0,0])
        cylinder(h=tBarLength+pt, r=bigDia/2, $fn=60);
    }
}
*/

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


module trapPrism(tb1, tb2, th, h) {
    paths= [[0,1,2,3]]; // MUST be vector of vectors
    dx = (tb1-tb2)/2;
    linear_extrude(height=h)
        polygon(points=[[0,0], [tb1, 0], [dx+tb2,th], [dx,th]], paths=paths);
}

// A wall with varying height - starting with h1 at the origin
// and going to h2 at [width, 0, 0]. The wall thickness is "thickness", and
// the wall is centered on the x-axis (y-dimensions is +/- thickness/2) 
module slopingWall(h1, h2, width, thickness) {
    paths= [[0,1,2,3]]; // MUST be vector of vectors
    //dx = (tb1-tb2)/2;
    rotate([90, 0, 0]) {
        linear_extrude(height=thickness)
            polygon(points=[[0,0], [width, 0], [width, h2], [0, h1]], paths=paths);
    }
}


// Like radial cylinders, but the cylinders themselves are radial
module radialHorizontalCylinders(cd, pd, h, angles, zo) {
    //cylinder(d=pd, h);
    translate([0,0, 0]) {
        for(a = angles) {
            rotate(a)
                translate([cd/2, 0, zo])
                    rotate([0,-90,0])
                        cylinder(d=pd, h);
        }
    }
}

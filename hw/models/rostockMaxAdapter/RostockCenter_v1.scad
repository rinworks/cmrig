

// A washer with base on x-y plane and axis == z-axis
module washer(id, od, h) {
}

// Creates several cylinders along a circle with diameter cd.
// One application: subtract these from a circular gasket.
// The cylinders have diameter pd and height h. The circle is on the x-y
// plane and it's center the origin. The *base* of the punches is on 
// the x-y plane. The cylinders are positioned at the specified vector
// of angles.
module radialCylinders(cd, pd, h, angles) {
}

// Creates a segment of a pipe. The center of the segment is the z-axis.
// The base of the segment is the x-y plane. The base inner/outer dia are
// id1/id2 and the top inner/outer dia are id2/od2. The height of the
// segment is h.
module pipeSegment(id1, od1, id2, od2, h) {
}
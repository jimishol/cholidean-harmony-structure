module dodecahedron(scale) {
    // regular dodecahedron (centered at origin, edge length 1)

    // coordinates of the "cube"
    c = (1 + sqrt(5)) / 4 *scale;  // phi / 2
    // coordinates of the "rectangular cuboid"
    r1 = 0;
    r2 = (3 + sqrt(5)) / 4 *scale;  // (phi + 1) / 2
    r3 = 1 / 2 * scale;

    polyhedron(
        // vertices
        [
            [ r1,  r2,  r3],  //  0: front top
            [ r1,  r2, -r3],  //  1: front bottom
            [ r1, -r2,  r3],  //  2: rear top
            [ r1, -r2, -r3],  //  3: rear bottom
            [ r3,  r1,  r2],  //  4: top right
            [ r3,  r1, -r2],  //  5: bottom right
            [-r3,  r1,  r2],  //  6: top left
            [-r3,  r1, -r2],  //  7: bottom left
            [  c,   c,   c],  //  8: top front right
            [  c,   c,  -c],  //  9: bottom front right
            [  c,  -c,   c],  // 10: top rear right
            [  c,  -c,  -c],  // 11: bottom rear right
            [ -c,   c,   c],  // 12: top front left
            [ -c,   c,  -c],  // 13: bottom front left
            [ -c,  -c,   c],  // 14: top rear left
            [ -c,  -c,  -c],  // 15: bottom rear left
            [ r2,  r3,  r1],  // 16: right front
            [ r2, -r3,  r1],  // 17: right rear
            [-r2,  r3,  r1],  // 18: left front
            [-r2, -r3,  r1],  // 19: left rear
        ],
        // faces
        [
            [ 0,  1,  9, 16,  8],  // front right
            [ 0,  8,  4,  6, 12],  // top front
            [ 0, 12, 18, 13,  1],  // front left
            [ 1, 13,  7,  5,  9],  // bottom front
            [ 2,  3, 15, 19, 14],  // rear left
            [ 2, 10, 17, 11,  3],  // rear right
            [ 2, 14,  6,  4, 10],  // top rear
            [ 3, 11,  5,  7, 15],  // bottom rear
            [ 4,  8, 16, 17, 10],  // right top
            [ 5, 11, 17, 16,  9],  // right bottom
            [ 6, 14, 19, 18, 12],  // left top
            [ 7, 13, 18, 19, 15],  // left bottom
        ]
    );
}

module beveledHole(p1, p2, r, bevel = 0.02, fn) {
    hull() {
        translate(p1) sphere(r = r + bevel, $fn = fn);
        translate(p2) sphere(r = r + bevel, $fn = fn);
    }
}

//helper in order
function prevNote(name) = CoF[(note_index(name) + 11) % 12];

module joint(name, size = joint_size, tube_r = tube_radius) {
    idx    = note_index(name);
    center = SoFourths(idx);
    hole_r = tube_r * 0.78;// hull by default creates larger holes. Reducing hole_radius forces hole more close to edge.

    // Edge directions
    p_out = SoFourths((idx + 4) % 12);
    p_in  = SoFourths((idx - 4 + 12) % 12);
    scale_tube_hole = 1.15; //Else perfect fit seems odd
    
    translate(center) dodecahedron(size); // 👈 Place it here
            // Subtracted solid
/*	This block create holes for passing through edge and curves. If holes are prefered uncomment the block and comment the previous action.	    
    difference() {
        translate(center) dodecahedron(size); // 👈 Place it here
        beveledHole(center, p_out, hole_r, 0.05, edge_res);
        beveledHole(p_in, center,  hole_r, 0.05, tube_res);
        curveTube(prevNote(name), tube_radius * scale_tube_hole, tube_steps/12);
        curveTube(name, tube_radius * scale_tube_hole, tube_steps/12);
    }
*/
}

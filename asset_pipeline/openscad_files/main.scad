// main.scad
include <prims.scad>;
// at the very top, allow -D exportNote="" (all) or e.g. -D exportNote="A"
exportNote = "";
// Helper: only emit i if exportNote is empty or matches
function keep(i) = (exportNote == "" || exportNote == i);
// ───────────────────────────────────────────────────────────────────
// 1) CONFIGURATION
// ───────────────────────────────────────────────────────────────────
notes_origin = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B"];
step         = 6*PI/12;     // = PI/2
//Radius of the whole torus
torusRadius  = 7;
//Half the width of the whole torus. Position span from -value to +value
torusWidth   = 3;
//tube_res is the $fn. Greater values create cylinder tube
tube_res     = 12;     
//edge_res is the $fn. Greater values create cylinders
edge_res     = 12;
surf_fn      = 12;    //$fn to union cyliders not boxes
//Percentage of the surface, along the curve, to be cut equally
surf_trim_h  = 0.18;  
//Percentage of the surface, perpendicular to the curve, to be cut equally
surf_trim_v  = 0.45;
//radius of the note joint
joint_size   = 0.375;
//radius of edge tube
edge_size    = 0.24;
//thickness of scale surfaces
surf_size    = 0.12;  
label_size   = 0.6;
//radius of curved tube
tube_radius  = 0.3;
//tube_steps needs at least 12 to close circle of Fourths forming a "Penrose" square. More than 10 per station creates clear curvature. Better value multiple of 12. tube_steps × surf_sambles  < 4000 else goes beyond openscad's limits.
tube_steps   = 120; 
//Sambles per step. (By 1 a rail is constructed, not surface)
surf_sambles     = 32;
//There are two vertical edges, an outer and an inner. It is more convenient to place the tonic (DesireNote) of major scales or relative major scales at upper end of the outer vertical edge.
DesiredNote = "C";

show_labels = false; // toggle via ‑D or edit
show_curve = true; // toggle via ‑D or edit
show_edges = true; // toggle via ‑D or edit
show_joints = true; // toggle via ‑D or edit
show_surfaces = true; // toggle via ‑D or edit

// ───────────────────────────────────────────────────────────────────
// 2) CORE FUNCTIONS & HELPERS
// ───────────────────────────────────────────────────────────────────

function origin_note_index(note) =
    [ for (i = [0 : 11]) if (notes_origin[i] == note) i ][0];
        
// note_index relevant to CoF (Circle of Fourths)
function note_index(note) =
    [ for (i = [0 : 11]) if (CoF[i] == note) i ][0];
notes = [ for (i = [0:11]) notes_origin[(i + 8 + origin_note_index(DesiredNote)) % 12] ];
CoF = [ for (i=[0:11]) notes[(i * 5) % 12] ];

function SoFourths(u) = let(
    t = u * step,
    R = torusRadius, w = torusWidth,
    a = t * 180/PI,
    b = t/3 * 180/PI
)
[
    sin(a)*(R + cos(b+360) + w*cos(b-180)),
    cos(a)*(R + cos(b+360) + w*cos(b-180)),
    sin(b+360) + w*sin(b-180)
];

module curveTube(name, rad = tube_radius, steps = tube_steps / 12) {
    idx = note_index(name); // index in CoF

    for (j = [0 : steps - 1]) {
        du1 = j / steps;
        du2 = (j + 1) / steps;
        u1 = idx + du1;
        u2 = idx + du2;
        p1 = SoFourths(u1);
        p2 = SoFourths(u2);

        hull() {
            translate(p1) sphere(r = rad, $fn = tube_res);
            translate(p2) sphere(r = rad, $fn = tube_res);
        }
    }
}

module link_by_name(name, l_size, fn) {
    idx = note_index(name);
    p1 = SoFourths(idx);
    p2 = SoFourths((idx + 4) % 12);
    
    hull() {
        translate(p1) sphere(r = l_size, $fn = fn);
        translate(p2) sphere(r = l_size, $fn = fn);
    }
}

// module link(p1, p2, l_size, fn) needed for trimmingg of surfaces
module link(p1, p2, l_size, fn) {
    hull() {
        translate(p1) sphere(r = l_size, $fn = fn);
        translate(p2) sphere(r = l_size, $fn = fn);
    }
}

module ribbonSurface(name, trim_h, trim_v) {
    StartP1   = (note_index(name) +11) % 12; // Start of evolving P1P2
    StartP2   = (note_index(name) +7) % 12;  // End of evolving P1P2
    loop_start = (tube_steps / 12 * surf_sambles) * trim_h /2;
    loop_end  = (tube_steps / 12 * surf_sambles) * (1 -trim_h / 2);
    union() {
        for (s = [loop_start : loop_end]) {
            du = s / (tube_steps / 12 * surf_sambles);
            p1 = SoFourths(StartP1 + du);
            p2 = SoFourths(StartP2 + du);
            Vector1 = p1 + trim_v / 2 * (p2 -p1);
            Vector2 = p1 + (1 - trim_v / 2) * (p2 -p1);
            // each tiny link becomes one “slice” of your ribbon
            link(Vector1, Vector2, surf_size, surf_fn);
        }
    }
}
// ────────────────────────────────────────────────────────────────
// 3) RENDER
// ────────────────────────────────────────────────────────────────

    if (show_curve) {
    color([0.05, 0.75, 0.90], 0.25)
    for (i = CoF)//(i = ["Eb"]) for specific label. (i = CoF) for all
        if (keep(i))
        curveTube(i);  
    }

    if (show_labels) {
    for (i = CoF) {  //(i = ["Eb"]) for specific label. (i = CoF) for all
        pos = SoFourths(note_index(i));
        translate(pos + [joint_size * 3, joint_size * 3, joint_size * 3])
        linear_extrude(height = label_size/2, $fn=24)
            text(
                i,
                size   = label_size,
                font   = "Liberation Sans",  // Add this if it helps
                halign = "center",
                valign = "center"
            );
        }
    }
    
    if (show_edges) {
        // Render directed edges from notes[i] -> notes[(i+8)%12]
        for (i = CoF) {//(i = ["Eb"]) for specific edge. (i = CoF) for all
        color([0.05, 0.55, 0.70], 0.20)
        if (keep(i))
        link_by_name(i, edge_size, edge_res);
        }
    }

 if (show_joints) {
    for (i = CoF)  // or (i = CoF)
        if (keep(i))
        joint(i);
}


 if (show_surfaces) {
    for (i = CoF) //(i = ["Eb"]) for specific surface. (i = CoF) for all
        color([0.80, 0.90, 0.90], 0.12)
        if (keep(i))
        ribbonSurface(i, surf_trim_h, surf_trim_v);
}

//==================Configure Previewer===============================

$vpr = [62.7, 0, 96.4];
$vpt = [-1.13, -0.727, -0.103];
$vpf = 22.5;
$vpd = 66.96;

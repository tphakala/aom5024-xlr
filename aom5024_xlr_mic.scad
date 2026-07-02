// =============================================================================
//  AOM-5024 CAPSULE HOUSING FOR NEUTRIK NC3MXX
// =============================================================================
//  A one-piece, 3D-printable pencil-microphone body that:
//
//    - holds an electret capsule (designed around the PUI Audio
//      AOM-5024L-HD-R) in a snap-fit pocket at the front, and
//    - screws its rear end into a real Neutrik NC3MXX male XLR connector,
//      using the shell's own internal thread (where the stock cable
//      bushing/boot normally screws in - requires the newer NC3MXX revision
//      that has this thread machined inside the shell).
//
//  The connector's metal shell, pin insert and latch are used as-is; this
//  part only replaces the cable bushing/boot, extending forward to carry the
//  capsule.
//
//  ASSEMBLY
//    1. Feed the mic wires in through the rear opening and out the front.
//    2. Solder the wires to the capsule's rear pads.
//    3. Push the capsule in from the REAR, forward through the bore. Its
//       leading edge cams the four snap fingers outward as it passes; at the
//       front of the pocket the fingers spring back in behind its rear edge
//       and hold it captive. Optional: a dab of hot glue for a permanent bond.
//    4. Screw the housing's rear thread into the connector shell. The wing
//       ring reaches deeper than the thread and pushes the connector's pin
//       insert forward into its seat as the housing tightens.
//
//  ADAPTING TO YOUR CAPSULE
//    Set capsule_od and capsule_h under [Capsule] below - the pocket bore,
//    pocket depth, and snap-finger positions all derive from those two
//    numbers. Print "fit_test_snap" (just the front tip, minutes of print
//    time) to confirm the fit before printing a full housing.
//
//  FIT TESTS - PRINT THESE FIRST
//    The connector-thread and wing-ring dimensions were estimated from a
//    third-party reference mesh, NOT from a Neutrik spec sheet - verify them
//    against your own connector before committing to a full print:
//      fit_test_conn_thread - rear thread + wing ring stub
//      fit_test_snap        - front tip only: pocket + snap fingers
//
//  EXPORT
//    openscad -o stl/housing.stl              -D 'part="housing"'              aom5024_xlr_mic.scad
//    openscad -o stl/fit_test_conn_thread.stl -D 'part="fit_test_conn_thread"' aom5024_xlr_mic.scad
//    openscad -o stl/fit_test_snap.stl        -D 'part="fit_test_snap"'        aom5024_xlr_mic.scad
//
//  PRINTING
//    Orientation: front (capsule) end DOWN on the bed, wing ring up. The tip
//    chamfer is shaped to be self-supporting in this orientation and the
//    snap-finger slots print without support at any angle.
//    Material: PETG / ABS / ASA (thread, wing-ring and snap-finger
//    durability). 0.16-0.20mm layers, 4 perimeters, 40-60% infill.
// =============================================================================


/* [Part] */
// Part to render/export
part = "housing"; // [housing, fit_test_conn_thread, fit_test_snap]


/* [Capsule] */
// Capsule body diameter. Measure YOUR capsule with calipers - the AOM-5024L-HD-R datasheet says 9.7mm, but an actual unit measured 9.8mm
capsule_od = 9.8;
// Capsule body height, front face to rear face (pocket depth derives from this)
capsule_h = 5.0;
// Extra pocket radius PER SIDE over capsule_od - a snug slip fit. The pocket is one consistent bore, open straight to the front face
capsule_radial_clear = 0.05;
// Extra pocket depth behind the capsule's nominal seat - tolerance for capsule height variation and solder blobs on the rear pads
capsule_depth_clear = 0.2;

// NOTE on the pocket design: a single consistent bore diameter is used for
// the entire pocket, opening straight out at the front face. Do not be
// tempted to add a narrower "aperture" in front of a wider pocket - if the
// opening is smaller than the pocket behind it, the capsule has room to
// rattle, tilt, and sink too deep in the gap. The snap fingers provide the
// positive depth stop; the bore is just a straight, snug sleeve.


/* [Front tip] */
// Axial run of the 45-degree outer chamfer at the front tip (radial rise is equal)
tip_chamfer_len = 1.0;
// Fillet radius rounding the chamfer's corners
tip_fillet_r = 0.3;


/* [Snap-fit fingers] */
// Number of cantilever fingers behind the capsule pocket
finger_count = 4;
// Angular gap between adjacent fingers (degrees)
finger_gap_deg = 16;
// Total cantilever length, nub end to anchor end. Longer = more flexible = easier snap-in
finger_len = 4.0;
// Radial thickness of each finger
finger_wall = 1.0;
// Length at the rear of finger_len left un-relieved, fusing the fingers solidly into the housing wall
finger_anchor_len = 1.0;
// Axial length of the inward nub bump at each finger's free end
nub_len = 1.2;
// Total diametral reduction below capsule_od at the nubs - how far the fingers must flex as the capsule passes. Lower if the capsule won't snap past; raise if it sits loose
nub_overlap = 0.6;
// Radial air gap outside each finger so it can flex outward without binding
flex_clear = 0.4;


/* [Connector thread - Neutrik NC3MXX] */
// These are ESTIMATES mined from a third-party reference mesh, not a Neutrik
// spec sheet. They have survived test prints against one real NC3MXX shell,
// but print fit_test_conn_thread and check against YOURS first. If the thread
// binds, shave conn_thread_major_d down ~0.1-0.2mm at a time (there is no
// clearance parameter: the mating female half is real hardware, not printed).

// Thread lead per turn
conn_thread_pitch = 1.0;
// Crest (outer) diameter of the male thread
conn_thread_major_d = 16.95;
// Root diameter of the male thread
conn_thread_minor_d = 15.72;
// Male tooth angular span, degrees. Beefy/printable - the real thread is finer, but we only need to grip the connector's flanks
conn_thread_tooth_ang = 100;
// Engagement length (~5 turns at 1.0 pitch)
conn_thread_len = 5.3;


/* [Wing ring] */
// A solid ring behind the thread that reaches deeper into the shell than the
// thread does, pushing the connector's pin insert forward against its seat
// as the housing is screwed home. (Some commercial bushing replacements slit
// this ring to make it a spring; solid is used here so no thin component
// lead on the insert's board can snag in a slit while threading in.)

// Wing ring outer diameter
wing_od = 14.0;
// Wing ring inner diameter (also sets the wire-passage bore)
wing_id = 12.0;
// Wing ring length
wing_len = 9.4;


/* [Body] */
// Widest OD allowed anywhere on the print. 20.3mm = caliper measurement of a real NC3MXX shell, +0.1mm print-shrinkage compensation so the printed part sits flush
conn_shell_od = 20.4;
max_od = 20.4;
// Collar length - the flush shoulder that lands on the connector's rear face
collar_len = 1.8;
// Body tube length between the finger zone and the collar. Freely adjustable for the overall mic length you want; nothing else depends on it
body_len = 2.5;


/* [Hidden] */
$fn = 96;
eps = 0.01;

collar_od   = max_od;
body_od     = max_od;
wire_bore_d = wing_id; // constant wire-passage bore behind the finger zone

conn_thread_tooth_h = (conn_thread_major_d - conn_thread_minor_d) / 2;

pocket_id = capsule_od + 2*capsule_radial_clear; // one consistent bore, open
                                                  // straight to the front face

z_seat       = capsule_h + capsule_depth_clear; // capsule rear-face resting z (nub target)
z_finger_end = z_seat + finger_len;             // finger anchor end
// finger_r_out must stay meaningfully bigger than wire_bore_d/2: the anchor
// end of each finger sits in a zone the wire-passage bore also cuts through.
// If the two radii ever coincide exactly, the touching faces are numerically
// unstable in CGAL's exact kernel and can silently produce a non-manifold
// part (seen directly: rendered fine at 6.05mm, broke at exactly 6.0mm).
// The max() enforces a real margin no matter how other parameters are tuned.
finger_r_out    = max(pocket_id/2 + finger_wall, wire_bore_d/2 + 0.1);
finger_relief_d = 2*(finger_r_out + flex_clear);
nub_r           = (capsule_od - nub_overlap) / 2;

z_body        = z_finger_end;
z_collar      = z_body + body_len;
z_conn_thread = z_collar + collar_len;
z_wing        = z_conn_thread + conn_thread_len;
housing_len   = z_wing + wing_len;

// ---- size-budget / sanity guardrails (fail loudly instead of silently
//      rendering a broken or oversized part) ----
assert(body_od <= max_od + eps, "body_od exceeds max_od");
assert(collar_od <= max_od + eps, "collar_od exceeds max_od");
assert(conn_thread_major_d <= max_od + eps, "connector thread OD exceeds max_od");
assert(max_od <= conn_shell_od + eps, "max_od exceeds conn_shell_od");
assert(conn_thread_minor_d > wire_bore_d + 2, "rear thread root wall too thin");
assert(nub_r > 0, "nub_overlap too large - nub_r went negative");
assert(nub_r < pocket_id/2, "nub_overlap too small to catch the capsule");
assert(finger_r_out*2 <= body_od - 2, "finger relief zone too wide for body_od - raise body_od or shrink finger_wall/capsule_radial_clear");


// =============================================================================
//  GENERIC THREAD GENERATOR
//  Coarse single-start helical thread: twist-extrude a profile (core circle +
//  radial tooth lobe).
// =============================================================================
module thread_profile(minor_r, major_r, ang) {
    union() {
        circle(r = minor_r);
        intersection() {
            circle(r = major_r);
            polygon([
                [0, 0],
                [2*major_r*cos(-ang/2), 2*major_r*sin(-ang/2)],
                [2*major_r, 0],
                [2*major_r*cos( ang/2), 2*major_r*sin( ang/2)]
            ]);
        }
    }
}

module thread_solid(len, p, major_d, th, ang) {
    minor_r = major_d/2 - th;
    twist   = -360 * len / p;
    slices  = max(12, ceil(len / p * 24));
    linear_extrude(height = len, twist = twist, slices = slices, convexity = 8)
        thread_profile(minor_r, major_d/2, ang);
}


// =============================================================================
//  FRONT-TIP OUTER CHAMFER + FILLET
//  45-degree chamfer with a small rounded edge where the flat front face
//  meets the cylindrical OD, revolved from a 2D profile. The
//  offset(r) offset(delta=-r) pair is the standard erode-then-dilate trick
//  for rounding convex corners by an exact radius - no trig, no Minkowski
//  render cost. Self-supporting printed front-end-down: the OD is smallest
//  exactly at the tip and grows monotonically away from it.
// =============================================================================
module cap_tip_outer(od, chamfer_len, fillet_r) {
    z_end = chamfer_len + 0.5; // extra straight run past the chamfer, purely
                                // so it overlaps/unions cleanly with the body
    rotate_extrude()
        offset(r = fillet_r)
            offset(delta = -fillet_r)
                polygon([
                    [0,                  0],
                    [od/2 - chamfer_len, 0],
                    [od/2,               chamfer_len],
                    [od/2,               z_end],
                    [0,                  z_end]
                ]);
}


// =============================================================================
//  WING RING
// =============================================================================
module wing_ring(h) {
    difference() {
        cylinder(h = h, d = wing_od);
        translate([0,0,-eps]) cylinder(h = h + 2*eps, d = wing_id);
    }
}


// =============================================================================
//  SNAP FINGERS
//  Four cantilevers just behind the capsule pocket: fixed at their rear end
//  (fused into the housing wall), free at the front end, each with a small
//  inward nub the capsule's rear edge cams past on the way in, then catches
//  behind. Added AFTER the pocket/relief cavity is cut, standing as
//  protrusions into that hollow.
//
//  The tiny eps overlaps below matter: surfaces that only touch at an exact
//  coincident radius/plane (finger inner face == pocket wall; nub start ==
//  pocket cavity end) are numerically unstable in CGAL's exact kernel and
//  can silently produce a non-manifold result depending on incidental
//  precision in the input numbers.
// =============================================================================
module angular_sector(r, ang) {
    intersection() {
        circle(r = r);
        polygon([
            [0, 0],
            [2*r*cos(-ang/2), 2*r*sin(-ang/2)],
            [2*r, 0],
            [2*r*cos( ang/2), 2*r*sin( ang/2)]
        ]);
    }
}

module wedge_tube(inner_r, outer_r, ang, h) {
    linear_extrude(height = h, convexity = 4)
        difference() {
            angular_sector(outer_r, ang);
            circle(r = inner_r);
        }
}

module snap_fingers() {
    ang = 360/finger_count - finger_gap_deg;
    for (i = [0 : finger_count-1])
        rotate([0,0, i*360/finger_count])
            translate([0,0, z_seat - eps]) {
                // nub (free end, nearest the capsule) - narrows the passage
                // below capsule_od so the capsule's rear edge catches on it
                wedge_tube(nub_r, finger_r_out, ang, nub_len + eps);
                // cantilever body (relief-diameter inner face, no obstruction)
                translate([0,0, nub_len + eps])
                    wedge_tube(pocket_id/2 - eps, finger_r_out, ang, finger_len - nub_len);
            }
}


// =============================================================================
//  HOUSING CAVITY
// =============================================================================
module housing_cavity() {
    // capsule pocket: ONE consistent bore, open straight to the front face
    // (z=0) - the outer chamfer is handled separately by cap_tip_outer() in
    // housing(), this is purely the internal capsule-fit bore
    translate([0,0,-eps]) cylinder(h = z_seat + eps, d = pocket_id);
    // finger flex relief (cantilever portion only, not the anchor)
    translate([0,0, z_seat - eps])
        cylinder(h = (finger_len - finger_anchor_len) + eps, d = finger_relief_d);
    // constant wire bore, from behind the finger anchor to the rear tip
    translate([0,0, z_finger_end - finger_anchor_len - eps])
        cylinder(h = (housing_len - (z_finger_end - finger_anchor_len)) + 2*eps, d = wire_bore_d);
}


// =============================================================================
//  HOUSING  (one part: capsule snap boss -> body tube -> collar -> connector
//            thread -> wing ring). z=0 is the front tip (capsule opening).
// =============================================================================
module housing() {
    difference() {
        union() {
            // chamfered + rounded front outer edge
            cap_tip_outer(body_od, tip_chamfer_len, tip_fillet_r);
            // rest of the constant-OD tip + body + collar, starting exactly
            // where the chamfer reaches full diameter (cap_tip_outer already
            // overlaps 0.5mm past this point on its own, so this junction is
            // already safely overlapped)
            translate([0,0, tip_chamfer_len])
                cylinder(h = z_collar + collar_len - tip_chamfer_len, d = body_od);
            // connector-mating male thread
            // (tiny axial overlaps below - two solids that only touch at a
            // zero-thickness face can render as separate volumes in CGAL)
            translate([0,0, z_conn_thread - eps])
                thread_solid(conn_thread_len + eps, conn_thread_pitch,
                             conn_thread_major_d, conn_thread_tooth_h, conn_thread_tooth_ang);
            // wing ring
            translate([0,0, z_wing - eps])
                wing_ring(wing_len + eps);
        }
        housing_cavity();
    }
    snap_fingers();
}


// =============================================================================
//  FIT-TEST COUPONS
// =============================================================================
module fit_test_conn_thread() {
    // rear thread + wing ring stub, with a short collar to grip while turning.
    // Print this and confirm it screws smoothly into YOUR NC3MXX shell AND
    // that the wing ring reaches/pushes the pin insert, before a full print.
    difference() {
        union() {
            thread_solid(conn_thread_len, conn_thread_pitch,
                         conn_thread_major_d, conn_thread_tooth_h, conn_thread_tooth_ang);
            translate([0,0, conn_thread_len - eps])
                wing_ring(wing_len + eps);
            translate([0,0, -6])
                cylinder(h = 6 + eps, d = collar_od);
        }
        translate([0,0,-6-eps]) cylinder(h = conn_thread_len + wing_len + 6 + 2*eps, d = wire_bore_d);
    }
}

module fit_test_snap() {
    // just the front tip: opening + pocket + snap fingers + a short bore stub
    // behind them - tests capsule fit and retention without printing the
    // whole housing
    stub_len = z_finger_end + 6;
    difference() {
        union() {
            cap_tip_outer(body_od, tip_chamfer_len, tip_fillet_r);
            translate([0,0, tip_chamfer_len])
                cylinder(h = stub_len - tip_chamfer_len, d = body_od);
        }
        translate([0,0,-eps]) cylinder(h = z_seat + eps, d = pocket_id);
        translate([0,0, z_seat - eps])
            cylinder(h = (finger_len - finger_anchor_len) + eps, d = finger_relief_d);
        translate([0,0, z_finger_end - finger_anchor_len - eps])
            cylinder(h = (stub_len - (z_finger_end - finger_anchor_len)) + 2*eps, d = wire_bore_d);
    }
    snap_fingers();
}


// =============================================================================
//  REPRESENTATIVE CAPSULE  (preview only - excluded from render/export)
// =============================================================================
module capsule_dummy() {
    color("#888") cylinder(h = capsule_h, d = capsule_od);
}


// =============================================================================
//  RENDER
// =============================================================================
if      (part == "housing")              { color("#b8b8b8") housing(); %capsule_dummy(); }
else if (part == "fit_test_conn_thread") fit_test_conn_thread();
else if (part == "fit_test_snap")        { fit_test_snap(); %capsule_dummy(); }
else echo("Unknown part: set `part` to housing | fit_test_conn_thread | fit_test_snap");

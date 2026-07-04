// =============================================================================
//  AOM-5024 CAPSULE HOUSING FOR NEUTRIK NC3MXX
// =============================================================================
//  A one-piece, 3D-printable pencil-microphone body that:
//
//    - holds an electret capsule (designed around the PUI Audio
//      AOM-5024L-HD-R) in a friction-fit pocket at the front, and
//    - screws its rear end into a real Neutrik NC3MXX male XLR connector,
//      using the shell's own internal thread (where the stock cable
//      bushing/boot normally screws in - requires the NC3MXX revision that
//      has this thread machined inside the shell; older revisions and REAN
//      variants with the thread OUTSIDE the shell are not compatible).
//
//  The connector's metal shell, pin insert and latch are used as-is; this
//  part only replaces the cable bushing/boot, extending forward to carry the
//  capsule. A necked "seal zone" just behind the collar optionally accepts an
//  O-ring for weather sealing (see [O-ring seal zone]); it works dry too.
//
//  ASSEMBLY
//    1. Feed the mic wires in through the rear opening and out the front.
//    2. Solder the wires to the capsule's rear pads.
//    3. Pull the wire slack back while pushing the capsule into the FRONT
//       pocket, until its rear face lands on the internal lip (the depth
//       stop). Friction holds it; add a dab of hot glue for a permanent
//       bond.
//    4. OPTIONAL weather seal: drop a ~13 x 2.5 (ID x cord) O-ring into the
//       shell's smooth internal lip pocket, just above its threads.
//    5. Screw the housing's rear thread into the connector shell. The wing
//       ring reaches past the thread and pushes the pin insert into its seat;
//       the seal neck passes through the O-ring and the shell squeezes it home.
//
//  ADAPTING TO YOUR CAPSULE
//    Set capsule_od and capsule_h under [Capsule] below - the pocket bore,
//    pocket depth and lip position all derive from those two numbers.
//    Print "fit_test_capsule" (just the front tip, minutes of print time) to
//    confirm the fit before printing a full housing.
//
//  FIT TESTS - PRINT THESE FIRST
//    The connector-thread dimensions were estimated from a third-party
//    reference mesh, NOT from a Neutrik spec sheet - verify against YOUR
//    connector before committing to a full print:
//      fit_test_conn_thread - rear thread + wing ring stub
//      fit_test_capsule     - front tip only: pocket + lip
//
//  EXPORT
//    openscad -o stl/housing.stl              -D 'part="housing"'              aom5024_xlr_mic.scad
//    openscad -o stl/fit_test_conn_thread.stl -D 'part="fit_test_conn_thread"' aom5024_xlr_mic.scad
//    openscad -o stl/fit_test_capsule.stl     -D 'part="fit_test_capsule"'     aom5024_xlr_mic.scad
//
//  PRINTING
//    Orientation: front (capsule) end down on the bed, wing ring up. The tip
//    chamfer is designed to be self-supporting in this orientation; the lip
//    prints as a narrow internal overhang step, no support needed. PETG /
//    ABS / ASA recommended, 4 perimeters, 0.16-0.20mm layers, 15% infill.
// =============================================================================


/* [Part] */
// Part to render/export
part = "housing"; // [housing, fit_test_conn_thread, fit_test_capsule]


/* [Capsule] */
// Capsule body diameter. Measure YOUR capsule with calipers - the AOM-5024L-HD-R datasheet says 9.7mm, but an actual unit measured 9.8mm
capsule_od = 9.8;
// Capsule body height, front face to rear face (pocket depth derives from this)
capsule_h = 5.0;
// Extra pocket radius PER SIDE over capsule_od - a snug slip fit. The pocket is one consistent bore, open straight to the front face
capsule_radial_clear = 0.05;
// Extra pocket depth behind the capsule's nominal seat - tolerance for capsule height variation and solder blobs on the rear pads
capsule_depth_clear = 0.2;
// How far the retaining lip behind the pocket bites below capsule_od, total
// diametral. The lip's opening is capsule_od - lip_overlap (9.2mm at the
// defaults) - a narrow annular step that stops the capsule but leaves the
// opening wide enough to pass the mic wires through with ease
lip_overlap = 0.6;
// Axial thickness of the lip ring
lip_len = 1.5;

// NOTE on the pocket design: a single consistent bore diameter is used for
// the entire pocket, opening straight out at the front face. Do not be
// tempted to add a narrower "aperture" in front of a wider pocket - if the
// opening is smaller than the pocket behind it, the capsule has room to
// rattle, tilt, and sink too deep in the gap. The lip provides the positive
// depth stop; the bore is just a straight, snug sleeve, and the capsule is
// retained by friction plus optional glue.


/* [Front tip] */
// Axial run of the 45-degree outer chamfer at the front tip (radial rise is equal)
tip_chamfer_len = 1.0;
// Fillet radius rounding the chamfer's corners
tip_fillet_r = 0.3;


/* [Connector thread - Neutrik NC3MXX] */
// These are ESTIMATES mined from a third-party reference mesh, not a Neutrik
// spec sheet. They are confirmed working against one real NC3MXX shell, but
// print fit_test_conn_thread and check against YOURS first. If the thread
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
// Body tube length between the capsule shoulder and the collar. This is the
// ONLY free part of the length that sits OUTSIDE the connector shell (the barrel
// a mic clip grips): exposed length = 6.7 (capsule/lip) + body_len + 1.8 (collar),
// = 11.0mm at the default. Everything past the collar (seal neck + thread + wing)
// is inside the shell and print-validated - do not touch it. For a target exposed
// length L, set body_len = L - 8.5 (e.g. 13.5 doubles the exposed barrel to 22mm).
// NOTE: this is the exposed body, NOT the oring_neck_* "seal neck" (that is inside
// the shell). Adds 1:1 to the overall length; nothing else depends on it
body_len = 2.5;


/* [O-ring seal zone] */
// The boot necks down to a waist between the collar and the thread. It works
// as-is (dry), and it also lets you add an OPTIONAL O-ring for weather sealing:
// seat a 13 x 2.5mm (ID x cord) O-ring in the NC3MXX shell's smooth internal
// lip pocket just above its threads (a 3mm cord over-squeezes and will not fit),
// threads, then thread the boot in - the neck passes through the ring and the
// shell bore squeezes it against the neck to seal. No groove is needed: the
// ring lives in the shell, not on the boot. Print-tested sealing on a real shell.

// Neck outer diameter - the O-ring rides on this (loose in air, snug once the
// shell bore ~17mm confines it around the neck). Print-tuned winner
oring_neck_d = 13.5;
// Neck axial length = the shell's smooth lip-pocket depth, i.e. how far below
// the collar the thread starts. Measured ~2.5-2.6mm on a real shell
oring_neck_len = 2.6;
// Local wire bore through the neck zone, necked down from wire_bore_d so the
// sealing wall stays solid. Sized so the wall (oring_neck_d-bore)/2 ~ 1.85mm
// MATCHES the rear thread-root wall - an earlier 8.0 gave a 2.75mm wall that
// printed as an over-thick internal lip (a full 12->8 bore choke would be 0.75mm)
oring_neck_bore_d = 9.8;
// Internal chamfer run at the collar/neck junction. The bore steps inward here
// (wire_bore_d -> oring_neck_bore_d), and because the part prints tip-down that
// square step is a downward-facing internal overhang (it sags) and a sharp
// stress riser at the neck root. A conical chamfer prints self-supporting and
// fillets the junction, for a stronger, more reliable collar-to-neck connection
oring_neck_cham = 1.2;
// Neck-to-thread lead-in run. Above the neck the thread core (conn_thread_minor_d)
// is wider than the neck, so printed tip-down the thread starts as a floating
// ledge cantilevered over the narrower neck. This conical lead-in ramps the OD
// (and the bore) up to the thread over this axial run so the print widens
// gradually into the thread; it doubles as a thread entry taper. It is taken OUT
// of the thread length (the top turn sat in the shell's smooth lip and did not
// engage), so the wing-tip depth and overall length are unchanged. For a <=45deg
// cone keep this >= (conn_thread_minor_d - oring_neck_d)/2
oring_thread_lead = 1.2;


/* [Hidden] */
$fn = 96;
eps = 0.01;

collar_od   = max_od;
body_od     = max_od;
wire_bore_d = wing_id; // constant wire-passage bore behind the shoulder

conn_thread_tooth_h = (conn_thread_major_d - conn_thread_minor_d) / 2;

pocket_id = capsule_od + 2*capsule_radial_clear; // one consistent bore, open
                                                  // straight to the front face

z_seat    = capsule_h + capsule_depth_clear; // capsule rear-face resting z (lip face)
z_lip_end = z_seat + lip_len;                // rear side of the lip ring
lip_id    = capsule_od - lip_overlap;        // the lip's opening (wire passage)

z_body        = z_lip_end;
z_collar      = z_body + body_len;
z_neck        = z_collar + collar_len;             // seal neck (sealing land) starts after the collar
z_thread_lead = z_neck + oring_neck_len;           // neck->thread lead-in starts (full 13.5 sealing land ends here)
z_conn_thread = z_thread_lead + oring_thread_lead; // thread starts after the lead-in cone
conn_thread_len_net = conn_thread_len - oring_thread_lead; // lead-in comes OUT of the thread, so wing depth is unchanged
z_wing        = z_conn_thread + conn_thread_len_net;
wing_len_net  = wing_len - oring_neck_len;         // wing shortened so its tip depth (which seats the insert) is unchanged
housing_len   = z_wing + wing_len_net;             // net length: neck + lead-in up top, equal length taken off the wing/thread

// ---- size-budget / sanity guardrails (fail loudly instead of silently
//      rendering a broken or oversized part) ----
assert(body_od <= max_od + eps, "body_od exceeds max_od");
assert(collar_od <= max_od + eps, "collar_od exceeds max_od");
assert(conn_thread_major_d <= max_od + eps, "connector thread OD exceeds max_od");
assert(max_od <= conn_shell_od + eps, "max_od exceeds conn_shell_od");
assert(conn_thread_minor_d > wire_bore_d + 2, "rear thread root wall too thin");
assert(lip_overlap > 2*capsule_radial_clear + 0.1, "lip_overlap too small to reliably stop the capsule");
assert(lip_id > 4, "lip opening too small to pass the mic wires - lower lip_overlap");
assert(pocket_id <= body_od - 2, "front tip wall too thin - shrink capsule_od/capsule_radial_clear or raise body_od");
assert(oring_neck_d > oring_neck_bore_d + 1.5, "seal-neck wall too thin - lower oring_neck_bore_d or raise oring_neck_d");
assert(oring_neck_d + eps < conn_thread_minor_d, "seal neck must be a waist narrower than the thread root");
assert(oring_neck_cham < collar_len, "collar/neck chamfer longer than the collar - lower oring_neck_cham");
assert(oring_neck_cham + eps < oring_neck_bore_d/2, "collar/neck chamfer would over-run the necked bore");
assert(oring_thread_lead > 0 && oring_thread_lead < conn_thread_len - 3, "thread lead-in leaves too little engaging thread - lower oring_thread_lead");
assert(conn_thread_len_net > 3, "engaging thread too short after the lead-in subtraction");
assert(wing_len_net > 3, "wing too short after the neck subtraction - lower oring_neck_len or raise wing_len");


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
//  HOUSING CAVITY
//  The tiny eps overlaps matter: adjacent cavities that only touch at an
//  exact coincident plane are numerically unstable in OpenSCAD's exact CGAL
//  kernel and can silently produce a non-manifold result depending on
//  incidental precision in the input numbers. Always check the `Volumes:`
//  line after a render (should read 2 for a single part).
// =============================================================================
module housing_cavity() {
    // capsule pocket: ONE consistent bore, open straight to the front face
    // (z=0) - the outer chamfer is handled separately by cap_tip_outer() in
    // housing(), this is purely the internal capsule-fit bore
    translate([0,0,-eps]) cylinder(h = z_seat + eps, d = pocket_id);
    // wide opening through the lip ring (the capsule's depth stop) - the
    // mic wires pass through here with plenty of room
    translate([0,0, z_seat - eps])
        cylinder(h = lip_len + 2*eps, d = lip_id);
    // wire bore from behind the lip up to where the collar/neck chamfer starts.
    // The seal-neck zone is necked down (smaller hole = solid sealing wall)
    translate([0,0, z_lip_end])
        cylinder(h = (z_neck - oring_neck_cham) - z_lip_end + eps, d = wire_bore_d);
    // collar/neck junction: the bore steps inward (wire_bore_d -> neck bore). A
    // conical chamfer instead of a square step keeps that inner corner off the
    // print's overhang limit and fillets/reinforces the neck root
    translate([0,0, z_neck - oring_neck_cham - eps])
        cylinder(h = oring_neck_cham + eps, d1 = wire_bore_d, d2 = oring_neck_bore_d);
    // necked seal-zone bore (wall ~= the thread-root wall)
    translate([0,0, z_neck - eps])
        cylinder(h = oring_neck_len + 2*eps, d = oring_neck_bore_d);
    // lead-in zone: bore ramps back out (neck bore -> wire_bore_d) beneath the
    // external thread lead-in, keeping the wall ~constant. It widens going up, so
    // the inner wall is self-supporting
    translate([0,0, z_thread_lead - eps])
        cylinder(h = oring_thread_lead + 2*eps, d1 = oring_neck_bore_d, d2 = wire_bore_d);
    // wire bore the rest of the way to the rear
    translate([0,0, z_conn_thread - eps])
        cylinder(h = housing_len - z_conn_thread + 2*eps, d = wire_bore_d);
}


// =============================================================================
//  HOUSING  (one part: capsule pocket + lip -> body tube -> collar ->
//            connector thread -> wing ring). z=0 is the front tip.
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
            // seal neck: a waist between the collar and the thread (the O-ring's
            // sealing land). An O-ring seated in the shell's lip pocket seals
            // against this Ø oring_neck_d cylinder
            translate([0,0, z_neck - eps])
                cylinder(h = oring_neck_len + eps, d = oring_neck_d);
            // neck->thread lead-in cone: ramps the OD up from the neck to the
            // thread root so the thread does not start as a floating ledge over
            // the narrower neck (FDM-friendly), and eases thread entry
            translate([0,0, z_thread_lead - eps])
                cylinder(h = oring_thread_lead + eps, d1 = oring_neck_d, d2 = conn_thread_minor_d);
            // connector-mating male thread (shortened by the lead-in length)
            // (tiny axial overlaps below - two solids that only touch at a
            // zero-thickness face can render as separate volumes in CGAL)
            translate([0,0, z_conn_thread - eps])
                thread_solid(conn_thread_len_net + eps, conn_thread_pitch,
                             conn_thread_major_d, conn_thread_tooth_h, conn_thread_tooth_ang);
            // wing ring (shortened by the neck length so wing-tip depth is unchanged)
            translate([0,0, z_wing - eps])
                wing_ring(wing_len_net + eps);
        }
        housing_cavity();
    }
}


// =============================================================================
//  FIT-TEST COUPONS
// =============================================================================
module fit_test_conn_thread() {
    // rear thread + seal neck + wing ring stub, with a short collar to grip
    // while turning. Print this and confirm it screws smoothly into YOUR NC3MXX
    // shell AND that the wing ring reaches/pushes the pin insert - and, if you
    // are using the O-ring, drop it into the shell's lip pocket and check the
    // seal squeeze here - before committing to a full print.
    stub   = 6;                          // collar stub (grip + rim stop)
    z_lead = oring_neck_len;             // neck->thread lead-in start (local z)
    z_t    = z_lead + oring_thread_lead; // thread start
    z_w    = z_t + conn_thread_len_net;  // wing start
    total  = z_w + wing_len_net;         // overall reach from z=0 through the wing
    difference() {
        union() {
            // collar stub below z=0 (lands on the shell rim)
            translate([0,0, -stub]) cylinder(h = stub + eps, d = collar_od);
            // seal neck (sealing land)
            translate([0,0, -eps]) cylinder(h = oring_neck_len + eps, d = oring_neck_d);
            // neck->thread lead-in cone
            translate([0,0, z_lead - eps])
                cylinder(h = oring_thread_lead + eps, d1 = oring_neck_d, d2 = conn_thread_minor_d);
            // thread (shortened by the lead-in length)
            translate([0,0, z_t - eps])
                thread_solid(conn_thread_len_net + eps, conn_thread_pitch,
                             conn_thread_major_d, conn_thread_tooth_h, conn_thread_tooth_ang);
            // wing ring
            translate([0,0, z_w - eps]) wing_ring(wing_len_net + eps);
        }
        // bore: collar stub up to the collar/neck chamfer
        translate([0,0, -stub - eps])
            cylinder(h = stub - oring_neck_cham + eps, d = wire_bore_d);
        // collar/neck internal chamfer (matches housing)
        translate([0,0, -oring_neck_cham - eps])
            cylinder(h = oring_neck_cham + eps, d1 = wire_bore_d, d2 = oring_neck_bore_d);
        // necked seal-zone bore
        translate([0,0, -eps])
            cylinder(h = oring_neck_len + 2*eps, d = oring_neck_bore_d);
        // lead-in bore, ramping back out to the wire bore
        translate([0,0, z_lead - eps])
            cylinder(h = oring_thread_lead + 2*eps, d1 = oring_neck_bore_d, d2 = wire_bore_d);
        // wire bore the rest of the way
        translate([0,0, z_t - eps]) cylinder(h = total - z_t + 2*eps, d = wire_bore_d);
    }
}

module fit_test_capsule() {
    // just the front tip: pocket + lip + a short stub of the wire bore -
    // tests the capsule's friction fit and seating without printing the
    // whole housing
    stub_len = z_lip_end + 4;
    difference() {
        union() {
            cap_tip_outer(body_od, tip_chamfer_len, tip_fillet_r);
            translate([0,0, tip_chamfer_len])
                cylinder(h = stub_len - tip_chamfer_len, d = body_od);
        }
        translate([0,0,-eps]) cylinder(h = z_seat + eps, d = pocket_id);
        translate([0,0, z_seat - eps])
            cylinder(h = lip_len + 2*eps, d = lip_id);
        translate([0,0, z_lip_end])
            cylinder(h = stub_len - z_lip_end + eps, d = wire_bore_d);
    }
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
else if (part == "fit_test_capsule")     { fit_test_capsule(); %capsule_dummy(); }
else echo("Unknown part: set `part` to housing | fit_test_conn_thread | fit_test_capsule");

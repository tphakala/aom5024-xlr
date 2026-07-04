# AOM-5024 capsule housing for Neutrik NC3MXX - design notes

Engineering/provenance notes for `aom5024_xlr_mic.scad`: a parametric OpenSCAD
design for a one-piece pencil-mic body that holds a PUI Audio **AOM-5024L-HD-R**
electret capsule in a friction-fit pocket at the front and screws its rear end
into the **real** Neutrik **NC3MXX** metal shell's own internal thread (the
NC3MXX has threads machined inside the shell, where the stock cable
bushing/boot normally screws in). The real connector shell + pin insert are
used unmodified; only the bushing/boot is replaced, extended forward to carry
the capsule.

See `README.md` for the user-facing quick start (printing, assembly,
customization). This file records **where the numbers came from** and how
they were verified.

**Connector compatibility:** this fits the NC3MXX exactly. That model has
the bushing thread machined INSIDE the metal shell. Older Neutrik revisions
and REAN-branded variants have the thread on the OUTSIDE of the shell and
are NOT compatible with this design.

**Print-validated:** the housing has been printed in ASA with a 0.4mm nozzle
(Bambu Lab H2D) and came out right on the first try - thread fit, capsule
friction fit and seating all confirmed on real hardware. That print also
showed the then-current snap-fit fingers never actually flex in practice
(the capsule is inserted from the front, not pushed past them from the
rear), so they were simplified to the solid lip ring described below; the
exterior, pocket and thread are unchanged by that simplification.

> An earlier two-part variant (separate threaded cap holding the capsule) was
> retired in favor of this one-piece snap-fit design - fewer parts, shorter,
> and an assembly order that matches the actual build process (wires through,
> solder, push capsule in). Its threaded-cap joint also needed ~0.3mm of
> radial thread clearance to assemble on FDM, which let the cap sit visibly
> off-center on the housing; the one-piece design has no such joint.

## Files

- `aom5024_xlr_mic.scad` - the design (one printable part + two fit-test coupons)
- `stl/housing.stl` - the printable part
- `stl/fit_test_conn_thread.stl` - coupon: rear thread + wing ring stub
- `stl/fit_test_capsule.stl` - coupon: front tip only (pocket + lip),
  to test the capsule fit without printing the whole housing

All STL exports are re-rendered after every dimensional change and confirmed
manifold (`Simple: yes`, `Volumes: 2` in the OpenSCAD CLI render stats).

## How it goes together

```
[female XLR cable]  <--  [NC3MXX metal shell + pin insert] <-- [housing (one piece)]
                                                                   |
                                                     rear thread + wing ring
                                                                   |
                                                     body tube (wire routing)
                                                                   |
                                                     solid lip ring (depth stop)
                                                                   |
                                                     capsule pocket, open at the front
```

1. Feed mic wires through the housing from the rear opening, out the front.
2. Solder the wires to the capsule's rear pads (the AOM-5024L-HD-R has two
   solder pads, no lead wires).
3. Pull the wire slack back while pushing the capsule into the FRONT pocket,
   until its rear face lands flat on the lip. Friction holds it; a
   small dab of hot glue makes it permanent.
4. The housing's rear thread screws into the connector shell's internal
   thread. The **wing ring** (a solid ring just past the thread) reaches
   further into the shell than the thread does and pushes the connector's
   pin insert forward against its seat as the housing is tightened.

**The pocket + depth stop:** the capsule pocket is ONE consistent bore
diameter (`pocket_id` ≈ 9.9mm) for its entire depth, open straight out to the
front face - no separate, larger internal cavity behind a narrower opening.
Depth is set by a solid annular lip (`lip_len` = 1.5mm thick) starting at
exactly `capsule_h + capsule_depth_clear` - the capsule's rear face lands
flat against it. The lip's opening is `capsule_od - lip_overlap` (Ø9.2mm at
the defaults): only a 0.3mm/side step, plenty to stop the capsule, while
leaving the passage wide enough to feed the mic wires through with ease. Retention along the pocket walls is friction (≈0.1mm total
diametral clearance) plus optional glue. An earlier iteration used four
flexible snap fingers here instead; the ASA test print showed they only ever
act as this same lip (the capsule is inserted from the front and never cams
past them), so they were replaced with the simpler, stronger solid wall.

**The front outer edge** is a purely cosmetic 1.0mm-run 45° chamfer with a
0.3mm fillet where the flat front face meets the cylindrical OD - built so
the part is self-supporting when printed front-end-down (diameter is smallest
exactly at the tip and grows monotonically away from it).

## ⚠️ Estimated vs. measured - verify before committing filament

**A. Rear thread + wing ring (mates the REAL connector) - ESTIMATED**

Derived by mining the triangle mesh of a third-party commercial NC3MXX
bushing-replacement part (not included in this repository, and not a Neutrik
spec sheet). The values are confirmed working against one real NC3MXX shell
(full ASA print, threads in correctly), but shells vary - print
`fit_test_conn_thread.stl` to confirm them against *your* connector:

| parameter | value | how derived |
|---|---|---|
| `conn_thread_major_d` | 16.95 mm | crest diameter, mesh radius histogram |
| `conn_thread_minor_d` | 15.72 mm | root diameter, mesh radius histogram |
| `conn_thread_pitch` | 1.0 mm | z-spacing of repeated crest points at fixed θ |
| `conn_thread_len` | 5.3 mm | axial length of the threaded zone (~5 turns) |
| `wing_od` / `wing_id` | 14.0 / 12.0 mm | radius histogram above the thread zone |
| `wing_len` | 9.4 mm | axial length of that zone |

If the thread is tight, shave `conn_thread_major_d` down ~0.1-0.2mm at a time
(there's no clearance parameter for this thread - the mating female half is
real hardware, not something this file also prints).

The reference part's wing ring had a single slit (a flex spring); this design
uses a solid, uninterrupted ring instead. The slit is an opening a thin
component lead (e.g. the P48 resistor or capacitor on the insert's terminals)
could snag on while the housing is threaded in, and a rigid push does the
same job as the spring.

**B. Capsule - measured with calipers on an actual part**

AOM-5024L-HD-R datasheet nominal: 9.7±0.1mm dia × 5±0.2mm height. **Caliper
measurement on an actual unit: 9.8mm dia** - used for `capsule_od` since it
supersedes the datasheet for that specific part; measure yours. The pocket
bore is sized `capsule_radial_clear` = 0.05mm/side over that (≈9.9mm),
tightened over three passes after looser values (0.3, then 0.15, then
0.10mm/side) all felt loose in hand. Front face has a ~19-hole × Ø0.4mm sound
port cluster - not reproduced as printed holes (FDM can't resolve 0.4mm
reliably); the opening is left fully open instead.

**C. Capsule friction fit - print-verified on ASA**

The pocket holds the AOM-5024 in place with friction alone at the shipped
0.05mm/side clearance (verified on the ASA print); hot glue is optional
insurance. If a different capsule or material combination comes out too
tight, raise `capsule_radial_clear` one step (0.05 to 0.10); if loose,
measure the capsule and set `capsule_od` to match.

## Current computed dimensions (defaults as shipped)

| | value |
|---|---|
| Max OD anywhere on the print | 20.4 mm (`max_od`; print-compensated over a 20.3mm caliper measurement of the shell) |
| Overall length, capsule tip → connector rear face | ≈ 25.7 mm (`housing_len`) |
| Exposed length OUTSIDE the shell (capsule tip → collar face) | 11.0 mm = capsule/lip 6.7 + `body_len` 2.5 + collar 1.8. This is the barrel a mic clip grips |
| Length INSIDE the shell (collar face → wing tip, fixed) | 14.7 mm = seal neck + thread + wing; print-validated, do not change |
| Body tube length (`body_len`, freely adjustable) | 2.5 mm (the only free part of the exposed length; adds 1:1 to both exposed and overall length, nothing else depends on it) |
| Wire-passage bore (constant, behind the lip) | 12.0 mm (`wire_bore_d` = `wing_id`) |
| Capsule pocket | Ø9.9 mm × 5.2 mm deep (= `capsule_h` + `capsule_depth_clear`, one consistent bore, open to the front face) |
| Depth stop | solid lip ring, 1.5 mm thick (`lip_len`), opening Ø9.2 mm (`capsule_od - lip_overlap`), starting at `capsule_h + capsule_depth_clear` |
| Front outer edge (cosmetic) | 1.0mm-run 45° chamfer + 0.3mm fillet on the OD |
| Seal neck (O-ring seal zone) | Ø13.5 mm x 2.6 mm sealing land between collar and thread, wire bore necked to Ø9.8 mm there (`oring_neck_d` / `oring_neck_len` / `oring_neck_bore_d`); a Ø9.8→12 internal chamfer fillets the collar/neck junction and a Ø13.5→15.72 external cone leads the OD into the thread (`oring_neck_cham` / `oring_thread_lead`) - see below |

`max_od` is enforced by `assert()`s in the derived-values section - rendering
fails loudly if any parameter change pushes an OD past budget, rather than
silently printing an oversized part.

### Lengthening the exposed body (mic-clip fit)

The part splits at the collar face into an 11.0 mm section OUTSIDE the shell
(what a mic clip grips) and a fixed 14.7 mm section INSIDE the shell (seal
neck + thread + wing, print-validated - leave it alone). `body_len` is the
only free component of the exposed length and adds 1:1 to both the exposed and
overall length. For a target exposed length `L` (capsule tip to collar face):

```
body_len = L - 8.5          (L minus the fixed 6.7 mm capsule section + 1.8 mm collar)
```

Doubling the exposed barrel (11.0 -> 22.0 mm) is `body_len = 13.5`, giving a
36.7 mm total part with the thread/wing engagement unchanged. Verified by
measuring the exported STL bounding box (25.70 -> 36.70 mm, the 11.0 mm delta
landing entirely on the exposed body).

**Naming trap:** the code's `oring_neck_*` parameters are NOT this exposed
body. Despite "neck" in the name they are the O-ring **seal land inside the
shell**; changing them drives the thread and wing deeper and breaks the
print-validated seal fit. The exposed body is `body_len`, and only `body_len`.

## Re-exporting after edits

```
openscad -o stl/housing.stl              -D 'part="housing"'              aom5024_xlr_mic.scad
openscad -o stl/fit_test_conn_thread.stl -D 'part="fit_test_conn_thread"' aom5024_xlr_mic.scad
openscad -o stl/fit_test_capsule.stl     -D 'part="fit_test_capsule"'     aom5024_xlr_mic.scad
```

Threaded parts take ~15-100s to render at F6/CLI. **Always check the
`Volumes:` line in the render stats** (should read 2 for a single part).
Two solids that meet at a zero-thickness interface - stacked flush
end-to-end, or coinciding at an identical radius - can render as disjoint
volumes or non-manifold output in OpenSCAD's exact CGAL kernel, and whether
it manifests depends on the incidental numbers involved, so it can work by
coincidence until an unrelated parameter change breaks it. Every such
junction in this file carries a tiny (`eps` = 0.01mm) deliberate overlap,
and `finger_r_out` is margin-guarded with a `max()` for the same reason. If
you add or move any feature that stacks flush against another, give it the
same treatment.

## Suggested print settings

- **Material:** PETG or ABS/ASA (thread + wing-ring durability). ASA is
  print-verified.
- **Layer height:** 0.16-0.20 mm. 0.4mm nozzle is print-verified.
- **Perimeters:** 4 (thread strength, thin wing-ring walls).
- **Infill:** 15% is plenty (print-verified); the part is mostly walls.
- **Orientation:** front (capsule) end down on the bed, wing ring up. This is
  required, not optional: the tip chamfer is specifically built to widen as
  it prints upward in this orientation - printed the other way it would be a
  shrinking overhang. The internal lip prints as a narrow (0.35mm/side)
  overhang step over the pocket; it needs no support.

## O-ring seal zone (optional weather sealing)

The rear necks down to a Ø13.5 mm waist (`oring_neck_d`) for 2.6 mm
(`oring_neck_len`) between the collar and the thread, with the wire bore locally
necked to Ø9.8 mm (`oring_neck_bore_d`) so the sealing wall is a solid ~1.85 mm -
matching the rear thread-root wall (an earlier Ø8.0 bore left a 2.75 mm wall that
printed as an over-thick internal lip). The part works dry; it also accepts an
optional O-ring that seals the joint to the metal shell for outdoor use.

**Two chamfers tune the seal zone for FDM (printed tip-down, wing up).** Both were
added after a first O-ring print showed the earlier Ø8.0 choke as an over-thick
internal lip that sagged at its lower edge; the reworked seal zone below is
print-validated (ASA, 0.4 mm nozzle) - the underside and thread start come out
clean and the O-ring seals:

- **Collar/neck junction** (`oring_neck_cham`, 1.2 mm): the bore steps inward
  here (Ø12 → Ø9.8). A square step is a downward-facing internal overhang that
  sags, and a sharp stress riser at the neck root; a conical chamfer prints
  self-supporting and fillets the junction, strengthening the collar-to-neck
  connection.
- **Neck→thread lead-in** (`oring_thread_lead`, 1.2 mm): above the neck the
  thread core (Ø15.72) is wider than the neck (Ø13.5), so the thread would start
  as a floating ledge cantilevered over the narrower neck. An external cone ramps
  the OD (and the bore, back out to Ø12) up to the thread so the print widens
  gradually; it doubles as a thread entry taper. It is taken OUT of the thread
  length - the top turn sat in the shell's smooth lip and did not engage - so the
  engaging thread drops from ~5 to ~4 turns while the full 2.6 mm sealing land,
  the wing-tip depth and the 25.7 mm overall length are all unchanged.

**How it seals:** the NC3MXX shell has a smooth, unthreaded lip pocket just
inside its rear opening, above the internal threads (measured bore ~17 mm, depth
~2.5-2.6 mm - it matches the O-ring's width). An O-ring dropped into that pocket
is squeezed between the shell bore and the boot's seal neck as the boot threads
in. The ring lives in the shell, not on the boot, so no groove is needed.

**Provenance (measured / print-tuned against one real shell + one O-ring,
2026-07-03):** the O-ring is a 13 x 2.5 mm (ID x cord) nitrile ring; a 3 mm
cord over-squeezes at this neck/bore and will not fit. The neck diameter was
found by printing a row of stepped seal-test
plugs (Ø11.5-13.5 mm) and pushing each into the shell with the ring: Ø13.5
sealed snug/perfect - loose on the bare neck in air, tight once the shell bore
confines it (textbook radial seal). The thread + wing shift down by
`oring_neck_len` and the wing is shortened by the same amount
(`wing_len_net = wing_len - oring_neck_len`), so the overall length (25.7 mm)
and the wing-tip depth that seats the pin insert are unchanged - no over-travel.
`fit_test_conn_thread` carries the seal neck, so it doubles as the seal test;
verified sealing on the real shell. The shell's internal lip bore came from
caliper measurement, not the reference mesh (which is exterior-only in the rear
zone).

For a different shell or O-ring, tune `oring_neck_d` / `oring_neck_len` /
`oring_neck_bore_d` (and, if needed, the chamfer runs `oring_neck_cham` /
`oring_thread_lead`) and re-print `fit_test_conn_thread` to check the fit.

## Open items

- [ ] Decide if the 2.5mm `body_len` neck is too short in hand - one-line
      change either way.
- [ ] No strain relief at the connector's own rear - relies entirely on the
      shell + wing ring, same as commercial bushing replacements.
- [ ] Dimensions are only confirmed against one shell and one capsule so
      far; if a print doesn't fit for you, start from the fit-test coupons
      and the tuning advice above.
- [ ] O-ring seal zone confirmed against one shell + one O-ring only; the
      neck/lip numbers may need tuning for other shells or ring sizes (see the
      O-ring seal zone section for how).

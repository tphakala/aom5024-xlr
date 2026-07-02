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
rear), so they were simplified to the solid shoulder described below; the
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
- `stl/fit_test_capsule.stl` - coupon: front tip only (pocket + shoulder),
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
                                                     solid shoulder (depth stop)
                                                                   |
                                                     capsule pocket, open at the front
```

1. Feed mic wires through the housing from the rear opening, out the front.
2. Solder the wires to the capsule's rear pads (the AOM-5024L-HD-R has two
   solder pads, no lead wires).
3. Pull the wire slack back while pushing the capsule into the FRONT pocket,
   until its rear face lands flat on the shoulder. Friction holds it; a
   small dab of hot glue makes it permanent.
4. The housing's rear thread screws into the connector shell's internal
   thread. The **wing ring** (a solid ring just past the thread) reaches
   further into the shell than the thread does and pushes the connector's
   pin insert forward against its seat as the housing is tightened.

**The pocket + depth stop:** the capsule pocket is ONE consistent bore
diameter (`pocket_id` ≈ 9.9mm) for its entire depth, open straight out to the
front face - no separate, larger internal cavity behind a narrower opening.
Depth is set by a solid shoulder wall (`shoulder_len` = 1.5mm, with a
`wire_pass_d` = 4mm hole through it) positioned at exactly
`capsule_h + capsule_depth_clear` - the capsule's rear face lands flat
against it. Retention along the pocket walls is friction (≈0.1mm total
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
| Body tube length (`body_len`, freely adjustable) | 2.5 mm (a short connecting neck - raise it for a longer mic) |
| Wire-passage bore (constant, behind the shoulder) | 12.0 mm (`wire_bore_d` = `wing_id`) |
| Capsule pocket | Ø9.9 mm × 5.2 mm deep (= `capsule_h` + `capsule_depth_clear`, one consistent bore, open to the front face) |
| Depth stop | solid shoulder wall, 1.5 mm thick (`shoulder_len`) with a Ø4 mm wire-pass hole (`wire_pass_d`), starting at `capsule_h + capsule_depth_clear` |
| Front outer edge (cosmetic) | 1.0mm-run 45° chamfer + 0.3mm fillet on the OD |

`max_od` is enforced by `assert()`s in the derived-values section - rendering
fails loudly if any parameter change pushes an OD past budget, rather than
silently printing an oversized part.

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

- **Material:** PETG or ABS/ASA (thread + wing-ring + snap-finger
  durability). ASA is print-verified.
- **Layer height:** 0.16-0.20 mm. 0.4mm nozzle is print-verified.
- **Perimeters:** 4 (thread strength, thin wing-ring/snap-finger walls).
- **Infill:** 15% is plenty (print-verified); the part is mostly walls.
- **Orientation:** front (capsule) end down on the bed, wing ring up. This is
  required, not optional: the tip chamfer is specifically built to widen as
  it prints upward in this orientation - printed the other way it would be a
  shrinking overhang. The internal shoulder prints as a short annular bridge
  over the pocket; at Ø9.9mm it bridges cleanly without support.

## Open items

- [ ] Decide if the 2.5mm `body_len` neck is too short in hand - one-line
      change either way.
- [ ] No strain relief at the connector's own rear - relies entirely on the
      shell + wing ring, same as commercial bushing replacements.
- [ ] Dimensions are only confirmed against one shell and one capsule so
      far; if a print doesn't fit for you, start from the fit-test coupons
      and the tuning advice above.

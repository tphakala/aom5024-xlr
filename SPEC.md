# AOM-5024 capsule housing for Neutrik NC3MXX — design notes

Engineering/provenance notes for `aom5024_xlr_mic.scad`: a parametric OpenSCAD
design for a one-piece pencil-mic body that holds a PUI Audio **AOM-5024L-HD-R**
electret capsule in a snap-fit pocket at the front and screws its rear end into
the **real** Neutrik **NC3MXX** metal shell's own internal thread (the newer
NC3MXX revision has threads machined inside the shell, where the stock cable
bushing/boot normally screws in). The real connector shell + pin insert are
used unmodified; only the bushing/boot is replaced, extended forward to carry
the capsule.

See `README.md` for the user-facing quick start (printing, assembly,
customization). This file records **where the numbers came from** and the
dimensional corrections made against physical test prints.

> An earlier two-part variant (separate threaded cap holding the capsule) was
> retired in favor of this one-piece snap-fit design — fewer parts, shorter,
> and an assembly order that matches the actual build process (wires through,
> solder, push capsule in). Its threaded-cap joint also needed ~0.3mm of
> radial thread clearance to assemble on FDM, which let the cap sit visibly
> off-center on the housing; the one-piece design has no such joint.

## Files

- `aom5024_xlr_mic.scad` — the design (one printable part + two fit-test coupons)
- `stl/housing.stl` — the printable part
- `stl/fit_test_conn_thread.stl` — coupon: rear thread + wing ring stub
- `stl/fit_test_snap.stl` — coupon: front tip only (pocket + snap fingers),
  to test capsule retention without printing the whole housing

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
                                                     4 snap fingers, then capsule pocket
                                                                   |
                                                     front opening (capsule seats here)
```

1. Feed mic wires through the housing from the rear opening, out the front.
2. Solder the wires to the capsule's rear pads (the AOM-5024L-HD-R has two
   solder pads, no lead wires).
3. Push the capsule in from the rear, forward through the bore. Its leading
   edge cams the 4 fingers outward as it passes; once its front face reaches
   the front of the pocket, the fingers spring back in behind its rear edge
   and hold it captive. Optional dab of hot glue for a permanent bond — the
   snap alone is a mechanical retain, not guaranteed to survive repeated
   handling/vibration forever.
4. The housing's rear thread screws into the connector shell's internal
   thread. The **wing ring** (a solid ring just past the thread) reaches
   further into the shell than the thread does and pushes the connector's
   pin insert forward against its seat as the housing is tightened.

**The pocket + depth stop:** the capsule pocket is ONE consistent bore
diameter (`pocket_id` ≈ 9.9mm) for its entire depth, open straight out to the
front face — no separate, larger internal cavity behind a narrower opening.
Depth is set by the snap fingers (positioned at exactly
`capsule_h + capsule_depth_clear`), a positive tactile stop. Retention along
the pocket walls is friction (≈0.1mm total diametral clearance) plus the
fingers, plus optional glue.

**The front outer edge** is a purely cosmetic 1.0mm-run 45° chamfer with a
0.3mm fillet where the flat front face meets the cylindrical OD — built so
the part is self-supporting when printed front-end-down (diameter is smallest
exactly at the tip and grows monotonically away from it).

## ⚠️ Estimated vs. measured — verify before committing filament

**A. Rear thread + wing ring (mates the REAL connector) — ESTIMATED**

Derived by mining the triangle mesh of a third-party commercial NC3MXX
bushing-replacement part (not included in this repository, and not a Neutrik
spec sheet). The values have survived test prints against one real NC3MXX
shell, but treat them as estimates until `fit_test_conn_thread.stl` confirms
them against *your* connector:

| parameter | value | how derived |
|---|---|---|
| `conn_thread_major_d` | 16.95 mm | crest diameter, mesh radius histogram |
| `conn_thread_minor_d` | 15.72 mm | root diameter, mesh radius histogram |
| `conn_thread_pitch` | 1.0 mm | z-spacing of repeated crest points at fixed θ |
| `conn_thread_len` | 5.3 mm | axial length of the threaded zone (~5 turns) |
| `wing_od` / `wing_id` | 14.0 / 12.0 mm | radius histogram above the thread zone |
| `wing_len` | 9.4 mm | axial length of that zone (corrected — see history #1) |

If the thread is tight, shave `conn_thread_major_d` down ~0.1–0.2mm at a time
(there's no clearance parameter for this thread — the mating female half is
real hardware, not something this file also prints).

The reference part's wing ring had a single slit (a flex spring); this design
uses a solid, uninterrupted ring instead — see history #6.

**B. Capsule — measured with calipers on an actual part**

AOM-5024L-HD-R datasheet nominal: 9.7±0.1mm dia × 5±0.2mm height. **Caliper
measurement on an actual unit: 9.8mm dia** — used for `capsule_od` since it
supersedes the datasheet for that specific part; measure yours. The pocket
bore is sized `capsule_radial_clear` = 0.05mm/side over that (≈9.9mm),
tightened over three passes after looser values (0.3, then 0.15, then
0.10mm/side) all felt loose in hand. Front face has a ~19-hole × Ø0.4mm sound
port cluster — not reproduced as printed holes (FDM can't resolve 0.4mm
reliably); the opening is left fully open instead.

**C. Snap-fit fingers — starting values, tune per print**

`nub_overlap` (0.6mm total, i.e. 0.3mm/side flex) and
`finger_wall`/`finger_len` are reasonable starting values for a short
PETG/ABS/ASA cantilever. If the capsule won't snap past the fingers, *lower*
`nub_overlap` (shallower catch, easier entry) or increase `finger_len`
(longer, more flexible cantilever). If it snaps in too loosely, raise
`nub_overlap`.

## Current computed dimensions (defaults as shipped)

| | value |
|---|---|
| Max OD anywhere on the print | 20.4 mm (`max_od`; print-compensated over a 20.3mm caliper measurement of the shell) |
| Overall length, capsule tip → connector rear face | ≈ 28.2 mm (`housing_len`) |
| Body tube length (`body_len`, freely adjustable) | 2.5 mm (a short connecting neck — raise it for a longer mic) |
| Wire-passage bore (constant, behind the finger anchor) | 12.0 mm (`wire_bore_d` = `wing_id`) |
| Capsule pocket | Ø9.9 mm × 5.2 mm deep (= `capsule_h` + `capsule_depth_clear`, one consistent bore, open to the front face) |
| Depth stop | the snap fingers, positioned exactly at `capsule_h + capsule_depth_clear` |
| Front outer edge (cosmetic) | 1.0mm-run 45° chamfer + 0.3mm fillet on the OD |
| Snap fingers | 4× cantilevers, 4.0 mm long, 1.0 mm wall, nubs catch at Ø9.2 mm (0.6 mm below the 9.8mm capsule OD), `finger_r_out` margin-guarded above `wire_bore_d/2` (see history #5) |

`max_od` is enforced by `assert()`s in the derived-values section — rendering
fails loudly if any parameter change pushes an OD past budget, rather than
silently printing an oversized part.

## Revision history — corrections made against physical test prints

Lessons baked into the current numbers, in order:

1. **Wing ring length was wrong by more than 2× (4.5mm → 9.4mm).** The
   original mesh measurement only sampled the reference tube's two end rings
   without checking there was *zero* mesh data in between — the absence is
   itself the signal: a straight prismatic tube needs no intermediate
   vertices, so the two rings found are the ends of one continuous ~9.4mm
   tube, not a short feature. At 4.5mm the wings didn't reach far enough into
   the shell to preload the pin insert. `conn_thread_len` was also tightened
   5.0 → 5.3mm on the same re-check.
2. **`max_od` raised 19.8 → 20.3 → 20.4mm** across two print-and-caliper
   cycles: prints consistently read slightly undersized against the real
   20.3mm shell (normal FDM shrinkage), so nominal carries a
   print-compensation margin.
3. **Capsule pocket redesigned to one consistent bore.** The original design
   had a narrower front aperture in front of a wider internal pocket — a hole
   bigger than its own opening. The capsule squeezed through the opening into
   0.6mm of unconstrained radial slop: room to rattle, tilt off-axis, and
   sink too deep. Fixed by using ONE bore diameter for the entire pocket,
   open straight to the front face, with the snap fingers as the positive
   depth stop. `capsule_radial_clear` was then tightened 0.3 → 0.15 → 0.10 →
   0.05mm/side over successive feel tests.
4. **Decorative grip ribs removed; body shortened.** `body_len` cut to a
   2.5mm neck (the wing-ring correction in #1 added back ~4.9mm of required
   length).
5. **Exact-touching-face CGAL trap, found three separate times.** Two solids
   that meet at a zero-thickness interface (stacked flush end-to-end, or
   coinciding at an identical radius) can render as disjoint volumes or
   non-manifold output in OpenSCAD's exact kernel — and whether it manifests
   depends on the incidental numbers involved, so it can "work by
   coincidence" for months. Instances: thread/wing-ring stacked flush;
   chamfer/body junction; `finger_r_out` landing on exactly `wire_bore_d/2`
   (rendered fine at 6.05mm, broke at exactly 6.0mm). Every junction now gets
   a tiny (`eps` = 0.01mm) axial overlap, and `finger_r_out` is
   margin-guarded with a `max()` so future parameter tuning can't recreate
   the coincidence. **If you add or move any feature that stacks flush
   against another, give it the same treatment — and always check the
   `Volumes:` line after a render** (should read 2 for a single part).
6. **Wing ring simplified: slit removed, now a solid ring.** The reference
   part's slit made it a flexible C-ring (spring-preloading the insert), but
   the slit is an opening a thin component lead (e.g. the P48 resistor or
   capacitor on the insert's terminals) could snag on while the housing is
   threaded in — a real assembly failure mode. A solid ring still does the
   actual job (pushing the insert into its seat) via a rigid push rather than
   spring force.

## Re-exporting after edits

```
openscad -o stl/housing.stl              -D 'part="housing"'              aom5024_xlr_mic.scad
openscad -o stl/fit_test_conn_thread.stl -D 'part="fit_test_conn_thread"' aom5024_xlr_mic.scad
openscad -o stl/fit_test_snap.stl        -D 'part="fit_test_snap"'        aom5024_xlr_mic.scad
```

Threaded parts take ~15–100s to render at F6/CLI. Always check the
`Volumes:` line in the render stats (see history #5).

## Suggested print settings

- **Material:** PETG or ABS/ASA (thread + wing-ring + snap-finger durability).
- **Layer height:** 0.16–0.20 mm.
- **Perimeters:** 4 (thread strength, thin wing-ring/snap-finger walls).
- **Infill:** 40–60%.
- **Orientation:** front (capsule) end down on the bed, wing ring up. This is
  required, not optional: the tip chamfer is specifically built to widen as
  it prints upward in this orientation — printed the other way it would be a
  shrinking overhang. The snap fingers' vertical slot cuts don't need support
  at any angle.

## Open items

- [ ] Confirm the (solid) wing ring reaches and pushes the pin insert into
      place on more than one shell.
- [ ] `capsule_radial_clear` = 0.05mm/side was tuned by feel over multiple
      passes without a print-and-check between the last two — if the capsule
      won't seat, loosen this first.
- [ ] Decide if the 2.5mm `body_len` neck is too short in hand — one-line
      change either way.
- [ ] No strain relief at the connector's own rear — relies entirely on the
      shell + wing ring, same as commercial bushing replacements.

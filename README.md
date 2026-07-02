# AOM-5024 XLR pencil mic body

A one-piece, 3D-printable pencil-microphone body for the PUI Audio
**AOM-5024L-HD-R** electret capsule that screws directly into a genuine
Neutrik **NC3MXX** male XLR connector.

The design reuses the real connector's metal shell, pin insert and latch
unmodified - the printed part only replaces the cable bushing/boot, threading
into the shell's own internal thread and extending forward to carry the
capsule in a snap-fit pocket. Total length from capsule tip to the
connector's rear face is about **28 mm**, giving a very compact plug-on mic.

![Printed housing next to a Neutrik NC3MXX connector](images/with_connector.png)

> **Compatibility warning:** this is designed for the NC3MXX exactly. That
> model has the bushing thread machined INSIDE the metal XLR shell. Older
> Neutrik revisions and the variants sold under the REAN brand have the
> thread on the OUTSIDE of the shell; those are NOT compatible with this
> design.

```
[capsule] [snap fingers] [neck] [thread + wing ring] --> screws into --> [Neutrik NC3MXX]
                     one printed part                                     real connector
```

![Housing from both ends](images/housing.png)

## Electronics

This body is designed for **simple P48 phantom-power circuitry - just a
resistor and a capacitor** - both of which fit inside the XLR connector
housing itself (on/around the pin insert's terminals). There is no PCB pocket
in the printed part and none is needed: the mic wires run from the insert
through the housing's 12 mm bore to the capsule's rear solder pads.

## Bill of materials

- **Neutrik NC3MXX** male XLR connector - must have the bushing thread
  machined *inside* the shell (see the compatibility warning above)
- **PUI Audio AOM-5024L-HD-R** electret capsule (or another capsule - see
  [Adapting to your capsule](#adapting-to-your-capsule))
- Resistor + capacitor for the P48 circuit
- Thin wire; optionally a dab of hot glue for permanent capsule retention

## Print the fit tests first

The connector-thread and wing-ring dimensions were estimated from a reference
mesh, **not** from a Neutrik spec sheet. Both coupons are tiny and print in
minutes:

| coupon | verifies |
|---|---|
| `stl/fit_test_conn_thread.stl` | rear thread screws smoothly into *your* shell, and the wing ring reaches/pushes the pin insert into its seat |
| `stl/fit_test_snap.stl` | front tip only - the capsule snaps in with reasonable force and stays retained |

![Fit-test coupons](images/fit_tests.png)

If the thread binds, reduce `conn_thread_major_d` ~0.1-0.2 mm at a time. If
the capsule won't snap past the fingers, lower `nub_overlap` or raise
`finger_len`; if it sits loose, raise `nub_overlap`.

## Printing

The design is print-verified: ASA with a 0.4 mm nozzle (Bambu Lab H2D) came
out right on the first try.

- **Material:** PETG, ABS or ASA (thread, wing-ring and snap-finger durability)
- **Layer height:** 0.16-0.20 mm, **perimeters:** 4
- **Infill:** 15 % is plenty; the part is mostly walls
- **Orientation:** front (capsule) end **down** on the bed, wing ring up.
  This matters: the tip chamfer is shaped to be self-supporting in this
  orientation, and the snap-finger slots print without support.

## Adapting to your capsule

Open `aom5024_xlr_mic.scad` in OpenSCAD - the parameters are organized for
the built-in Customizer (Window → Customizer). The pocket bore, pocket depth
and snap-finger positions all derive from two numbers under **[Capsule]**:

| parameter | default | meaning |
|---|---|---|
| `capsule_od` | 9.8 | capsule body **diameter** - measure yours with calipers (the AOM-5024 datasheet says 9.7 mm, an actual unit measured 9.8 mm) |
| `capsule_h` | 5.0 | capsule body **height/depth**, front face to rear face |
| `capsule_radial_clear` | 0.05 | extra pocket radius per side - a snug slip fit |
| `capsule_depth_clear` | 0.2 | extra pocket depth for height variation / solder blobs |

Other things you may want to tweak:

| parameter | default | meaning |
|---|---|---|
| `body_len` | 2.5 | neck length between capsule section and connector - raise for a longer mic body; nothing else depends on it |
| `nub_overlap` | 0.6 | how hard the snap fingers catch the capsule |
| `finger_len` | 4.0 | snap finger flexibility (longer = easier snap-in) |

Guardrail `assert()`s fail the render loudly if a parameter combination
produces an oversized or broken part. After any change, print
`fit_test_snap.stl` before a full housing.

## Exporting STLs

```
openscad -o stl/housing.stl              -D 'part="housing"'              aom5024_xlr_mic.scad
openscad -o stl/fit_test_conn_thread.stl -D 'part="fit_test_conn_thread"' aom5024_xlr_mic.scad
openscad -o stl/fit_test_snap.stl        -D 'part="fit_test_snap"'        aom5024_xlr_mic.scad
```

Pre-rendered STLs with the default parameters are included in `stl/`.

## Assembly

1. Solder the P48 resistor/capacitor circuit on the XLR pin insert's
   terminals, with the two mic wires attached.
2. Feed the mic wires through the printed housing (rear opening → out the
   front).
3. Solder the wires to the capsule's rear pads.
4. Push the capsule in from the rear, forward through the bore, until it
   snaps behind the fingers. Optionally add a dab of hot glue.
5. Screw the housing into the connector shell. The wing ring pushes the pin
   insert into its seat as the thread tightens.

## Design notes

Dimensional provenance and the reasoning behind the geometry live in
[SPEC.md](SPEC.md). The preview images are rendered from the STLs with
`scripts/render_previews.py` (Blender, headless).

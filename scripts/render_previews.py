# Renders the preview images in images/ from the STLs in stl/.
# Run headless from the repository root:
#   blender -b -P scripts/render_previews.py
import math
import os

import bpy
from mathutils import Vector

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STL_DIR = os.path.join(ROOT, "stl")
IMG_DIR = os.path.join(ROOT, "images")
os.makedirs(IMG_DIR, exist_ok=True)

RES = (1600, 1000)
SAMPLES = 96


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = SAMPLES
    scene.cycles.use_denoising = True
    scene.render.resolution_x, scene.render.resolution_y = RES
    scene.view_settings.view_transform = "Standard"

    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.92, 0.92, 0.93, 1.0)
    bg.inputs[1].default_value = 0.35
    scene.world = world
    return scene


def plastic_material():
    mat = bpy.data.materials.get("print_plastic")
    if mat is None:
        mat = bpy.data.materials.new("print_plastic")
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = (0.38, 0.41, 0.47, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.45
    return mat


def metal_material():
    mat = bpy.data.materials.get("nickel")
    if mat is None:
        mat = bpy.data.materials.new("nickel")
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = (0.52, 0.52, 0.54, 1.0)
        bsdf.inputs["Metallic"].default_value = 0.9
        bsdf.inputs["Roughness"].default_value = 0.35
    return mat


def floor_material():
    mat = bpy.data.materials.get("floor")
    if mat is None:
        mat = bpy.data.materials.new("floor")
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = (0.90, 0.90, 0.91, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.9
    return mat


def rubber_material():
    mat = bpy.data.materials.get("rubber")
    if mat is None:
        mat = bpy.data.materials.new("rubber")
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = (0.015, 0.015, 0.015, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.55
    return mat


def bore_rear(obj, radius, depth):
    """Cut a cylindrical recess into the +z end of an object (used to carve
    the bushing-thread opening back into the Neutrik shell, whose STEP export
    is one fused solid with the boot and gets a flat cap when sliced)."""
    top = max((obj.matrix_world @ Vector(c)).z for c in obj.bound_box)
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth,
                                        location=(0, 0, top - depth / 2 + 1.0),
                                        vertices=96)
    cutter = bpy.context.active_object
    mod = obj.modifiers.new("bore", "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.solver = "EXACT"
    mod.object = cutter
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier="bore")
    bpy.data.objects.remove(cutter, do_unlink=True)


def import_stl(name, euler=(0, 0, 0), x=0.0, directory=None, material=None,
               rear_bore=None):
    """Import an STL, rotate it, rest it on the floor centered at (x, 0)."""
    bpy.ops.wm.stl_import(filepath=os.path.join(directory or STL_DIR, name))
    obj = bpy.context.selected_objects[0]
    if rear_bore:
        bore_rear(obj, *rear_bore)
    obj.rotation_euler = [math.radians(a) for a in euler]
    bpy.context.view_layer.update()
    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    min_z = min(c.z for c in corners)
    cx = (min(c.x for c in corners) + max(c.x for c in corners)) / 2
    cy = (min(c.y for c in corners) + max(c.y for c in corners)) / 2
    obj.location = (obj.location.x - cx + x,
                    obj.location.y - cy,
                    obj.location.z - min_z)
    obj.data.materials.clear()
    obj.data.materials.append(metal_material() if material == "metal"
                              else plastic_material())
    return obj


def add_sun(direction, energy, angle_deg):
    light = bpy.data.lights.new("sun", type="SUN")
    light.energy = energy
    light.angle = math.radians(angle_deg)
    lamp = bpy.data.objects.new("sun", light)
    bpy.context.collection.objects.link(lamp)
    lamp.rotation_euler = Vector(direction).to_track_quat("Z", "Y").to_euler()
    return lamp


def add_floor():
    bpy.ops.mesh.primitive_plane_add(size=4000, location=(0, 0, 0))
    plane = bpy.context.active_object
    plane.data.materials.append(floor_material())
    return plane


def frame_camera(objs, azim_deg=30.0, elev_deg=16.0, margin=1.12):
    corners = [o.matrix_world @ Vector(c) for o in objs for c in o.bound_box]
    lo = Vector((min(c.x for c in corners), min(c.y for c in corners), min(c.z for c in corners)))
    hi = Vector((max(c.x for c in corners), max(c.y for c in corners), max(c.z for c in corners)))
    center = (lo + hi) / 2
    radius = (hi - lo).length / 2

    cam_data = bpy.data.cameras.new("cam")
    cam = bpy.data.objects.new("cam", cam_data)
    bpy.context.collection.objects.link(cam)
    bpy.context.scene.camera = cam
    cam_data.clip_end = 100000

    scene = bpy.context.scene
    aspect = scene.render.resolution_y / scene.render.resolution_x
    fov_h = cam_data.angle
    fov_v = 2 * math.atan(math.tan(fov_h / 2) * aspect)
    dist = margin * radius / math.tan(min(fov_h, fov_v) / 2)

    azim, elev = math.radians(azim_deg), math.radians(elev_deg)
    offset = Vector((math.cos(elev) * math.sin(azim),
                     -math.cos(elev) * math.cos(azim),
                     math.sin(elev))) * dist
    cam.location = center + offset
    cam.rotation_euler = (cam.location - center).to_track_quat("Z", "Y").to_euler()
    return cam


def render(path):
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("wrote", path)


def build_and_render(filename, parts):
    reset_scene()
    objs = [import_stl(name, euler=rot, x=x) for (name, rot, x) in parts]
    add_floor()
    add_sun((0.5, -1.0, 0.9), energy=2.5, angle_deg=15)
    add_sun((-1.0, -0.3, 0.5), energy=0.8, angle_deg=30)
    frame_camera(objs)
    render(os.path.join(IMG_DIR, filename))


def build_and_render_ex(filename, parts, azim=30.0, elev=16.0):
    """parts: list of dicts passed to import_stl."""
    reset_scene()
    objs = [import_stl(**p) for p in parts]
    add_floor()
    add_sun((0.5, -1.0, 0.9), energy=2.5, angle_deg=15)
    add_sun((-1.0, -0.3, 0.5), energy=0.8, angle_deg=30)
    frame_camera(objs, azim_deg=azim, elev_deg=elev)
    render(os.path.join(IMG_DIR, filename))


def add_oring(x, z, major=8.0, minor=1.25):
    """A rubber O-ring (torus) resting around the housing axis at height z.
    major/minor give ID 13.5 / cord 2.5 (OD 18.5), sitting on the Ø13.5 seal
    neck. z is the neck's mid-height in the housing's own frame (the housing is
    imported tip-down with no rotation, so model z == world z)."""
    bpy.ops.mesh.primitive_torus_add(location=(x, 0, z),
                                     major_radius=major, minor_radius=minor,
                                     major_segments=96, minor_segments=28)
    ring = bpy.context.active_object
    ring.data.materials.append(rubber_material())
    bpy.ops.object.shade_smooth()
    return ring


def build_oring_render():
    """Two housings, thread/seal-neck end up: left bare, right with an O-ring
    seated in the seal neck - shows the optional weather seal in place."""
    reset_scene()
    # seal-neck mid-height in the model: z_neck..z_conn_thread ~ 11.0..13.6
    neck_z = 12.3
    left = import_stl("housing.stl", euler=(0, 0, 0), x=-15)   # without O-ring
    right = import_stl("housing.stl", euler=(0, 0, 0), x=15)   # with O-ring
    add_oring(x=15, z=neck_z)
    add_floor()
    add_sun((0.5, -1.0, 0.9), energy=2.5, angle_deg=15)
    add_sun((-1.0, -0.3, 0.5), energy=0.8, angle_deg=30)
    frame_camera([left, right], azim_deg=24, elev_deg=15)
    render(os.path.join(IMG_DIR, "oring_seal.png"))


# housing twice: thread/wing-ring end up (as modeled) and capsule end up
build_and_render("housing.png", [
    ("housing.stl", (0, 0, 0), -16),
    ("housing.stl", (180, 0, 0), 16),
])

# the two fit-test coupons
build_and_render("fit_tests.png", [
    ("fit_test_conn_thread.stl", (0, 0, 0), -18),
    ("fit_test_capsule.stl", (0, 0, 0), 18),
])

# the optional O-ring weather seal: bare housing vs one with the O-ring seated
# in the seal neck
build_oring_render()

# housing next to a real Neutrik NC3MXX connector (shell only, stock boot
# removed - the printed housing replaces the boot), coaxial, thread facing
# the shell's rear opening. Requires reference/NC3MXX_shell.stl converted
# from Neutrik's official STEP model - NOT redistributable, so it is
# gitignored and this image simply isn't re-rendered if the file is absent.
NEUTRIK_STL = os.path.join(ROOT, "reference")
if os.path.exists(os.path.join(NEUTRIK_STL, "NC3MXX_shell.stl")):
    build_and_render_ex("with_connector.png", [
        dict(name="NC3MXX_shell.stl", euler=(0, 90, 0), x=-25,
             directory=NEUTRIK_STL, material="metal", rear_bore=(8.5, 10.0)),
        # housing rear (thread + wing ring) faces the shell's rear opening,
        # ready to be threaded in
        dict(name="housing.stl", euler=(0, -90, 0), x=30),
    ], azim=18, elev=22)
else:
    print("reference/NC3MXX_shell.stl not found - skipping with_connector.png")

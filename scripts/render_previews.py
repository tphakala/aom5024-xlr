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


def import_stl(name, euler=(0, 0, 0), x=0.0, directory=None, material=None):
    """Import an STL, rotate it, rest it on the floor centered at (x, 0)."""
    bpy.ops.wm.stl_import(filepath=os.path.join(directory or STL_DIR, name))
    obj = bpy.context.selected_objects[0]
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

# housing next to a real Neutrik NC3MXX connector (shell only, stock boot
# removed - the printed housing replaces the boot), coaxial, thread facing
# the shell's rear opening. Requires reference/NC3MXX_shell.stl converted
# from Neutrik's official STEP model - NOT redistributable, so it is
# gitignored and this image simply isn't re-rendered if the file is absent.
NEUTRIK_STL = os.path.join(ROOT, "reference")
if os.path.exists(os.path.join(NEUTRIK_STL, "NC3MXX_shell.stl")):
    build_and_render_ex("with_connector.png", [
        dict(name="NC3MXX_shell.stl", euler=(0, 90, 0), x=-25,
             directory=NEUTRIK_STL, material="metal"),
        dict(name="housing.stl", euler=(0, 90, 0), x=30),
    ], azim=18, elev=22)
else:
    print("reference/NC3MXX_shell.stl not found - skipping with_connector.png")

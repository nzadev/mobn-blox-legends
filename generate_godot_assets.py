#!/usr/bin/env python3
import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter

BASE_DIR = "/home/nza/.gemini/antigravity/scratch/mobn_blox_legends/assets"

DIRS = [
    "icons",
    "portraits",
    "skills",
    "items",
    "spells",
    "textures/faces",
    "textures/torsos",
    "textures/terrain",
    "ui",
    "audio",
]

for d in DIRS:
    os.makedirs(os.path.join(BASE_DIR, d), exist_ok=True)

HEROES = [
    {
        "id": "laylul", "name": "Laylul", "role": "Marksman",
        "skin": "#f8d2b4", "hair": "#ffcf24", "hairStyle": "twintails",
        "torso": "#e8e4f0", "coat": "#d8cfe8", "trim": "#d49b27", "pants": "#1e1b2e",
        "aura": "#38bdf8", "weapon": "cannon", "eye": "#0284c7",
        "skills": [
            ("atk", "#38bdf8", "cannon"),
            ("1", "#facc15", "bolt"),
            ("2", "#a855f7", "orb"),
            ("3", "#22d3ee", "laser"),
        ]
    },
    {
        "id": "sabro", "name": "Sabro", "role": "Assassin",
        "skin": "#94a3b8", "hair": "#e2e8f0", "hairStyle": "cyber_helm",
        "torso": "#1e3a8a", "coat": "#172554", "trim": "#ef4444", "pants": "#0f172a",
        "aura": "#3b82f6", "weapon": "dual_blades", "eye": "#ef4444",
        "skills": [
            ("atk", "#38bdf8", "slash"),
            ("1", "#38bdf8", "orbit"),
            ("2", "#60a5fa", "dash"),
            ("3", "#ef4444", "triple"),
        ]
    },
    {
        "id": "yuzong", "name": "Yu Zong", "role": "Fighter",
        "skin": "#64748b", "hair": "#1e1b4b", "hairStyle": "horns",
        "torso": "#18181b", "coat": "#27272a", "trim": "#e11d48", "pants": "#09090b",
        "aura": "#e11d48", "weapon": "dragon_claws", "eye": "#e11d48",
        "skills": [
            ("atk", "#f43f5e", "claw"),
            ("1", "#e11d48", "spin"),
            ("2", "#be123c", "slam"),
            ("3", "#f43f5e", "dragon"),
        ]
    },
    {
        "id": "kajee", "name": "Kajee", "role": "Support",
        "skin": "#f59e0b", "hair": "#fef08a", "hairStyle": "bird_crest",
        "torso": "#4c1d95", "coat": "#3b0764", "trim": "#eab308", "pants": "#1e1b4b",
        "aura": "#eab308", "weapon": "whip", "eye": "#38bdf8",
        "skills": [
            ("atk", "#facc15", "bolt"),
            ("1", "#facc15", "orbit"),
            ("2", "#fde047", "dash"),
            ("3", "#eab308", "chain"),
        ]
    },
    {
        "id": "yeen", "name": "Yeen", "role": "Fighter",
        "skin": "#fbd38d", "hair": "#eab308", "hairStyle": "spiky",
        "torso": "#991b1b", "coat": "#7f1d1d", "trim": "#fbbf24", "pants": "#1c1917",
        "aura": "#f97316", "weapon": "gauntlets", "eye": "#f59e0b",
        "skills": [
            ("atk", "#f97316", "fist"),
            ("1", "#f97316", "fist"),
            ("2", "#fbbf24", "dash"),
            ("3", "#dc2626", "domain"),
        ]
    },
    {
        "id": "kimee", "name": "Kimee", "role": "Marksman",
        "skin": "#fde68a", "hair": "#facc15", "hairStyle": "short_bob",
        "torso": "#ec4899", "coat": "#f472b6", "trim": "#fdf2f8", "pants": "#831843",
        "aura": "#ec4899", "weapon": "splat_gun", "eye": "#ec4899",
        "skills": [
            ("atk", "#ec4899", "cannon"),
            ("1", "#ec4899", "bolt"),
            ("2", "#f472b6", "dash"),
            ("3", "#f43f5e", "laser"),
        ]
    },
    {
        "id": "minotor", "name": "Minotor", "role": "Tank",
        "skin": "#c2410c", "hair": "#fef3c7", "hairStyle": "bull_horns",
        "torso": "#9a3412", "coat": "#7c2d12", "trim": "#fbbf24", "pants": "#431407",
        "aura": "#ea580c", "weapon": "giant_hammer", "eye": "#fde047",
        "skills": [
            ("atk", "#f59e0b", "hammer"),
            ("1", "#f97316", "slam"),
            ("2", "#4ade80", "heal"),
            ("3", "#ea580c", "quake"),
        ]
    },
    {
        "id": "esteez", "name": "Esteez", "role": "Support",
        "skin": "#fef3c7", "hair": "#f8fafc", "hairStyle": "elf_crown",
        "torso": "#1e3a8a", "coat": "#1d4ed8", "trim": "#facc15", "pants": "#172554",
        "aura": "#4ade80", "weapon": "tome_scroll", "eye": "#38bdf8",
        "skills": [
            ("atk", "#38bdf8", "orb"),
            ("1", "#4ade80", "heal"),
            ("2", "#38bdf8", "orbit"),
            ("3", "#22c55e", "heal"),
        ]
    },
    {
        "id": "masteryee", "name": "Master Yee", "role": "Assassin",
        "skin": "#fcd34d", "hair": "#1e293b", "hairStyle": "goggles_helm",
        "torso": "#334155", "coat": "#1e293b", "trim": "#84cc16", "pants": "#0f172a",
        "aura": "#84cc16", "weapon": "katana", "eye": "#84cc16",
        "skills": [
            ("atk", "#a3e635", "slash"),
            ("1", "#84cc16", "dash"),
            ("2", "#a3e635", "heal"),
            ("3", "#65a30d", "triple"),
        ]
    },
    {
        "id": "ketootoo", "name": "Ketootoo", "role": "Marksman",
        "skin": "#fed7aa", "hair": "#451a03", "hairStyle": "cap_hood",
        "torso": "#374151", "coat": "#1f2937", "trim": "#38bdf8", "pants": "#111827",
        "aura": "#60a5fa", "weapon": "dual_pistols", "eye": "#38bdf8",
        "skills": [
            ("atk", "#60a5fa", "cannon"),
            ("1", "#38bdf8", "bolt"),
            ("2", "#60a5fa", "orb"),
            ("3", "#3b82f6", "laser"),
        ]
    },
    {
        "id": "alucardox", "name": "Alucardox", "role": "Fighter",
        "skin": "#fde68a", "hair": "#fef08a", "hairStyle": "spiky",
        "torso": "#1e3a8a", "coat": "#991b1b", "trim": "#fbbf24", "pants": "#172554",
        "aura": "#3b82f6", "weapon": "greatsword", "eye": "#3b82f6",
        "skills": [
            ("atk", "#60a5fa", "slash"),
            ("1", "#3b82f6", "slam"),
            ("2", "#60a5fa", "spin"),
            ("3", "#2563eb", "laser"),
        ]
    },
    {
        "id": "gusionox", "name": "Gusionox", "role": "Assassin",
        "skin": "#fed7aa", "hair": "#78350f", "hairStyle": "spiky",
        "torso": "#f8fafc", "coat": "#1e3a8a", "trim": "#38bdf8", "pants": "#0f172a",
        "aura": "#22d3ee", "weapon": "dual_blades", "eye": "#22d3ee",
        "skills": [
            ("atk", "#22d3ee", "slash"),
            ("1", "#22d3ee", "dash"),
            ("2", "#38bdf8", "orbit"),
            ("3", "#06b6d4", "triple"),
        ]
    },
]

def hex_to_rgba(h, alpha=255):
    h = h.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), alpha)

def darken(rgba, factor=0.65):
    return (int(rgba[0]*factor), int(rgba[1]*factor), int(rgba[2]*factor), rgba[3])

def lighten(rgba, factor=1.3):
    return (min(255, int(rgba[0]*factor)), min(255, int(rgba[1]*factor)), min(255, int(rgba[2]*factor)), rgba[3])

def make_face_texture(hero):
    skin = hex_to_rgba(hero["skin"])
    img = Image.new("RGBA", (256, 256), skin)
    d = ImageDraw.Draw(img)
    hid = hero["id"]

    # Subtle anime face shading at forehead & chin
    d.rectangle([0, 0, 256, 36], fill=darken(skin, 0.88))
    d.rectangle([0, 224, 256, 256], fill=darken(skin, 0.90))

    if hid == "minotor":
        # Fierce Minotaur Beast Face with glowing golden eyes & nostril ring
        d.polygon([(36, 78), (108, 96), (98, 126), (36, 114)], fill=hex_to_rgba("#fde047"))
        d.polygon([(220, 78), (148, 96), (158, 126), (220, 114)], fill=hex_to_rgba("#fde047"))
        d.ellipse([66, 94, 86, 114], fill=hex_to_rgba("#dc2626"))
        d.ellipse([170, 94, 190, 114], fill=hex_to_rgba("#dc2626"))
        d.rounded_rectangle([62, 134, 194, 212], radius=18, fill=hex_to_rgba("#7c2d12"), outline=hex_to_rgba("#431407"), width=4)
        d.ellipse([86, 156, 108, 178], fill=hex_to_rgba("#270903"))
        d.ellipse([148, 156, 170, 178], fill=hex_to_rgba("#270903"))
        d.arc([94, 168, 162, 236], start=330, end=210, fill=hex_to_rgba("#facc15"), width=12)
    elif hid == "yuzong":
        # Fierce Black Dragon Sovereign face with glowing crimson dragon marks & fangs
        d.polygon([(24, 72), (112, 92), (104, 126), (30, 112)], fill=hex_to_rgba("#09090b"))
        d.polygon([(232, 72), (144, 92), (152, 126), (226, 112)], fill=hex_to_rgba("#09090b"))
        d.polygon([(40, 86), (104, 98), (96, 118), (44, 108)], fill=hex_to_rgba("#f43f5e"))
        d.polygon([(216, 86), (152, 98), (160, 118), (212, 108)], fill=hex_to_rgba("#f43f5e"))
        d.rectangle([118, 42, 138, 92], fill=hex_to_rgba("#e11d48"))
        d.line([(82, 184), (128, 174), (174, 184)], fill=hex_to_rgba("#09090b"), width=8)
        d.polygon([(88, 184), (96, 202), (104, 182)], fill=(255, 255, 255, 255))
        d.polygon([(152, 182), (160, 202), (168, 184)], fill=(255, 255, 255, 255))
    elif hid in ("sabro", "masteryee"):
        # Cyber Ninja / Wuju Goggles face
        d.rounded_rectangle([24, 76, 232, 146], radius=14, fill=hex_to_rgba("#0f172a"), outline=hex_to_rgba(hero["trim"]), width=5)
        if hid == "sabro":
            d.polygon([(40, 96), (116, 112), (40, 128)], fill=hex_to_rgba("#ef4444"))
            d.polygon([(216, 96), (140, 112), (216, 128)], fill=hex_to_rgba("#ef4444"))
        else:
            for gx, gy in [(76, 110), (128, 96), (180, 110), (128, 126)]:
                d.ellipse([gx-14, gy-14, gx+14, gy+14], fill=hex_to_rgba("#a3e635"), outline=(255, 255, 255, 220), width=3)
        d.rounded_rectangle([42, 158, 214, 240], radius=12, fill=hex_to_rgba("#1e293b"), outline=hex_to_rgba(hero["trim"]), width=3)
    else:
        # High-Detail Anime Hero Face (Multi-layered sparkling iris, eyelashes, blush, nose shadow)
        d.ellipse([30, 146, 82, 172], fill=(244, 114, 182, 105))
        d.ellipse([174, 146, 226, 172], fill=(244, 114, 182, 105))
        brow = darken(hex_to_rgba(hero["hair"]), 0.7)
        d.line([(42, 82), (74, 74), (104, 84)], fill=brow, width=8)
        d.line([(152, 84), (182, 74), (214, 82)], fill=brow, width=8)
        iris_col = hex_to_rgba(hero["eye"])
        for cx in (72, 184):
            d.rounded_rectangle([cx - 28, 96, cx + 28, 150], radius=10, fill=(255, 255, 255, 255))
            d.polygon([(cx - 32, 94), (cx + 30, 92), (cx + 28, 106), (cx - 28, 108)], fill=hex_to_rgba("#0f172a"))
            d.rounded_rectangle([cx - 20, 102, cx + 20, 148], radius=12, fill=darken(iris_col, 0.55))
            d.rounded_rectangle([cx - 16, 110, cx + 16, 146], radius=10, fill=iris_col)
            d.ellipse([cx - 10, 124, cx + 10, 144], fill=lighten(iris_col, 1.35))
            d.ellipse([cx - 8, 114, cx + 8, 132], fill=hex_to_rgba("#082f49"))
            d.ellipse([cx - 16, 104, cx - 4, 116], fill=(255, 255, 255, 255))
            d.ellipse([cx + 6, 128, cx + 14, 136], fill=(255, 255, 255, 240))
        d.polygon([(125, 144), (131, 144), (128, 154)], fill=darken(skin, 0.8))
        d.arc([106, 162, 150, 196], start=15, end=165, fill=hex_to_rgba("#7c2d12"), width=6)

    img.save(os.path.join(BASE_DIR, "textures/faces", f"{hid}_face.png"))

def make_torso_texture(hero):
    coat = hex_to_rgba(hero["coat"])
    torso = hex_to_rgba(hero["torso"])
    trim = hex_to_rgba(hero["trim"])
    aura = hex_to_rgba(hero["aura"])
    img = Image.new("RGBA", (256, 256), torso)
    d = ImageDraw.Draw(img)
    hid = hero["id"]

    # Outer jacket lapels
    d.polygon([(0, 0), (82, 0), (64, 256), (0, 256)], fill=coat)
    d.polygon([(256, 0), (174, 0), (192, 256), (256, 256)], fill=coat)

    # Metallic trim borders along jacket opening
    d.line([(82, 0), (64, 256)], fill=trim, width=10)
    d.line([(174, 0), (192, 256)], fill=trim, width=10)

    # Center Chest Core Emblem / Diagonal Cross Straps
    d.line([(68, 28), (188, 168)], fill=darken(coat, 0.7), width=14)
    d.line([(188, 28), (68, 168)], fill=darken(coat, 0.7), width=14)
    d.polygon([(128, 52), (164, 96), (128, 140), (92, 96)], fill=trim, outline=(255, 255, 255, 220), width=3)
    d.polygon([(128, 66), (150, 96), (128, 126), (106, 96)], fill=aura)

    # Tactical Utility Belt & Glowing Buckle
    d.rectangle([0, 192, 256, 228], fill=hex_to_rgba("#0f172a"), outline=trim, width=4)
    d.rounded_rectangle([98, 186, 158, 234], radius=8, fill=trim, outline=(255, 255, 255, 240), width=3)
    d.ellipse([114, 196, 142, 224], fill=aura)

    img.save(os.path.join(BASE_DIR, "textures/torsos", f"{hid}_torso.png"))

def make_portrait(hero):
    w, h = 240, 280
    img = Image.new("RGBA", (w, h), hex_to_rgba("#090d16"))
    d = ImageDraw.Draw(img)

    aura = hex_to_rgba(hero["aura"])
    trim = hex_to_rgba(hero["trim"])
    coat = hex_to_rgba(hero["coat"])
    skin = hex_to_rgba(hero["skin"])
    hair = hex_to_rgba(hero["hair"])

    # Rich Diagonal Energy Background Gradient
    for y in range(h):
        t = y / h
        r = int(15 * (1 - t) + aura[0] * 0.35 * t)
        g = int(23 * (1 - t) + aura[1] * 0.35 * t)
        b = int(42 * (1 - t) + aura[2] * 0.45 * t)
        d.line([(0, y), (w, y)], fill=(min(255, r), min(255, g), min(255, b), 255))

    # Glowing Magic Rune Halo behind Hero
    d.ellipse([30, 28, 210, 208], outline=(aura[0], aura[1], aura[2], 140), width=5)
    d.ellipse([48, 46, 192, 190], fill=(aura[0], aura[1], aura[2], 55), outline=(trim[0], trim[1], trim[2], 170), width=3)

    # Back Hair / Twintails / Cape
    if hero["hairStyle"] == "twintails":
        d.polygon([(46, 68), (12, 260), (54, 265), (72, 92)], fill=hair, outline=darken(hair, 0.7), width=3)
        d.polygon([(194, 68), (228, 260), (186, 265), (168, 92)], fill=hair, outline=darken(hair, 0.7), width=3)
        d.polygon([(36, 54), (68, 44), (62, 78)], fill=hex_to_rgba("#0284c7"))
        d.polygon([(204, 54), (172, 44), (178, 78)], fill=hex_to_rgba("#0284c7"))
    else:
        d.polygon([(38, 135), (202, 135), (224, 275), (16, 275)], fill=darken(coat, 0.65))

    # Armored Pauldrons & Torso
    d.polygon([(24, 155), (86, 135), (154, 135), (216, 155), (204, 278), (36, 278)], fill=coat, outline=trim, width=4)
    d.polygon([(12, 155), (68, 135), (56, 195), (14, 185)], fill=lighten(coat, 1.15), outline=trim, width=3)
    d.polygon([(228, 155), (172, 135), (184, 195), (226, 185)], fill=lighten(coat, 1.15), outline=trim, width=3)

    # Glowing Core Gem on Chest
    d.polygon([(120, 165), (144, 195), (120, 225), (96, 195)], fill=trim, outline=(255, 255, 255, 230), width=2)
    d.polygon([(120, 175), (134, 195), (120, 215), (106, 195)], fill=aura)

    # Neck & Sculpted Anime Head
    d.rectangle([102, 120, 138, 152], fill=darken(skin, 0.85))
    d.rounded_rectangle([68, 48, 172, 142], radius=22, fill=skin, outline=darken(skin, 0.75), width=3)

    # Face Details from generated face texture
    face_path = os.path.join(BASE_DIR, "textures/faces", f"{hero['id']}_face.png")
    if os.path.exists(face_path):
        f_img = Image.open(face_path).resize((92, 82))
        img.paste(f_img, (74, 56), f_img)

    # Layered Spiky / Sculpted Hair & Headgear
    d.polygon([(62, 66), (76, 32), (120, 26), (164, 32), (178, 66), (154, 58), (120, 72), (86, 58)], fill=hair, outline=darken(hair, 0.7), width=2)
    d.polygon([(64, 56), (56, 118), (74, 108), (76, 64)], fill=hair)
    d.polygon([(176, 56), (184, 118), (166, 108), (164, 64)], fill=hair)

    if hero["hairStyle"] in ("horns", "bull_horns"):
        d.polygon([(68, 46), (26, 8), (48, 58)], fill=trim, outline=(255, 255, 255, 220), width=2)
        d.polygon([(172, 46), (214, 8), (192, 58)], fill=trim, outline=(255, 255, 255, 220), width=2)
    elif hero["hairStyle"] in ("cyber_helm", "goggles_helm"):
        d.polygon([(120, 10), (134, 54), (106, 54)], fill=trim, outline=(255, 255, 255, 230), width=2)
    elif hero["hairStyle"] in ("elf_crown", "bird_crest"):
        d.polygon([(82, 46), (98, 18), (120, 34), (142, 18), (158, 46)], fill=trim, outline=(255, 255, 255, 230), width=2)

    # Foreground Weapon Silhouette Accent
    d.polygon([(175, 230), (226, 115), (236, 125), (192, 242)], fill=aura, outline=(255, 255, 255, 220), width=2)

    # Metallic Card Border Frame
    d.rectangle([2, 2, w - 3, h - 3], outline=trim, width=5)
    d.rectangle([8, 8, w - 9, h - 9], outline=(255, 255, 255, 90), width=2)

    img.save(os.path.join(BASE_DIR, "portraits", f"{hero['id']}.png"))

def make_skill_icon(hero_id, key, color_hex, motif):
    s = 128
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    col = hex_to_rgba(color_hex)
    dark = (max(10, col[0] // 4), max(14, col[1] // 4), max(28, col[2] // 4), 255)
    d.ellipse([4, 4, s - 4, s - 4], fill=dark, outline=col, width=6)
    d.ellipse([14, 14, s - 14, s - 14], outline=(255, 255, 255, 90), width=2)

    if motif == "cannon":
        d.polygon([(28, 76), (82, 34), (98, 52), (44, 94)], fill=col)
        d.ellipse([76, 28, 106, 58], fill=(255, 255, 255, 230))
    elif motif == "bolt":
        d.polygon([(70, 18), (34, 68), (62, 68), (48, 110), (96, 54), (66, 54)], fill=col, outline=(255, 255, 255, 220))
    elif motif == "orb":
        d.ellipse([34, 34, 94, 94], fill=col)
        d.ellipse([48, 48, 80, 80], fill=(255, 255, 255, 240))
    elif motif == "laser":
        d.polygon([(18, 92), (96, 18), (110, 32), (32, 106)], fill=col)
        d.line([(24, 98), (102, 24)], fill=(255, 255, 255, 255), width=8)
    elif motif == "slash":
        d.arc([20, 20, 108, 108], start=210, end=30, fill=col, width=14)
        d.line([(32, 92), (96, 28)], fill=(255, 255, 255, 240), width=6)
    elif motif == "orbit":
        d.ellipse([24, 24, 104, 104], outline=col, width=8)
        for ang in (0, 90, 180, 270):
            rad = math.radians(ang)
            cx = int(64 + math.cos(rad) * 40)
            cy = int(64 + math.sin(rad) * 40)
            d.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill=(255, 255, 255, 240), outline=col, width=3)
    elif motif == "dash":
        d.polygon([(22, 84), (72, 34), (72, 52), (104, 52), (54, 102), (54, 84)], fill=col)
    elif motif == "triple":
        for offset in (-18, 0, 18):
            d.line([(28, 92 + offset // 2), (98, 26 + offset // 2)], fill=col if offset != 0 else (255, 255, 255, 255), width=9)
    elif motif in ("claw", "Dragon", "dragon"):
        for ox in (-16, 0, 16):
            d.line([(34 + ox, 26), (54 + ox, 64), (42 + ox, 102)], fill=col, width=8)
    elif motif in ("spin", "quake", "domain"):
        d.ellipse([22, 36, 106, 96], outline=col, width=10)
        d.ellipse([42, 48, 86, 84], fill=(255, 255, 255, 210))
    elif motif in ("slam", "hammer", "fist"):
        d.rectangle([38, 30, 90, 74], fill=col, outline=(255, 255, 255, 230), width=4)
        d.rectangle([56, 74, 72, 106], fill=hex_to_rgba("#fde047"))
    elif motif in ("heal", "chain"):
        d.rectangle([52, 28, 76, 100], fill=col)
        d.rectangle([28, 52, 100, 76], fill=col)
        d.rectangle([56, 32, 72, 96], fill=(255, 255, 255, 220))
    else:
        d.ellipse([36, 36, 92, 92], fill=col)

    img.save(os.path.join(BASE_DIR, "skills", f"{hero_id}_{key}.png"))

def make_terrain_texture(filename, base_hex, n1_hex, n2_hex, is_brick=False):
    random.seed(42)
    img = Image.new("RGBA", (256, 256), hex_to_rgba(base_hex))
    d = ImageDraw.Draw(img)
    if is_brick:
        c1 = hex_to_rgba(n1_hex)
        for y in range(0, 256, 32):
            d.line([(0, y), (256, y)], fill=c1, width=3)
            offset = 0 if (y // 32) % 2 == 0 else 32
            for x in range(offset, 256, 64):
                d.line([(x, y), (x, y + 32)], fill=c1, width=3)
    else:
        c1 = hex_to_rgba(n1_hex)
        c2 = hex_to_rgba(n2_hex)
        for i in range(650):
            col = c1 if i % 2 == 0 else c2
            x = random.randint(0, 248)
            y = random.randint(0, 248)
            s = random.randint(4, 10)
            d.rectangle([x, y, x + s, y + s], fill=col)
    img.save(os.path.join(BASE_DIR, "textures/terrain", filename))

for h in HEROES:
    make_face_texture(h)
    make_torso_texture(h)
    make_portrait(h)
    for key, col, motif in h["skills"]:
        make_skill_icon(h["id"], key, col, motif)

make_terrain_texture("grass.png", "#6ba656", "#76b55f", "#5d9449", False)
make_terrain_texture("stone.png", "#9ca3af", "#8c939e", "#abb2bf", False)
make_terrain_texture("brick.png", "#d6d3d1", "#a8a29e", "#e7e5e4", True)

ITEMS = [
    ("item_boots", "#3b82f6", "dash"),
    ("item_dual_swords", "#a855f7", "triple"),
    ("item_axe", "#dc2626", "hammer"),
    ("item_claw", "#e11d48", "claw"),
    ("item_cannon", "#f59e0b", "cannon"),
    ("item_emerald_blade", "#10b981", "slash"),
    ("item_scythe", "#22c55e", "slash"),
    ("item_staff", "#eab308", "bolt"),
    ("item_armor", "#f97316", "orb"),
    ("item_shield", "#22d3ee", "orbit"),
    ("item_wings", "#e11d48", "spin"),
]
for item_id, col, motif in ITEMS:
    make_skill_icon("equip", item_id, col, motif)
    os.replace(
        os.path.join(BASE_DIR, "skills", f"equip_{item_id}.png"),
        os.path.join(BASE_DIR, "items", f"{item_id}.png"),
    )

SPELLS = [
    ("spell_flicker", "#38bdf8", "dash"),
    ("spell_vengeance", "#a855f7", "orbit"),
    ("spell_execute", "#f43f5e", "laser"),
    ("spell_recall", "#38bdf8", "spin"),
    ("spell_regen", "#4ade80", "heal"),
]
for sp_id, col, motif in SPELLS:
    make_skill_icon("sp", sp_id, col, motif)
    os.replace(
        os.path.join(BASE_DIR, "skills", f"sp_{sp_id}.png"),
        os.path.join(BASE_DIR, "spells", f"{sp_id}.png"),
    )

print("GENERATED_V2_HERO_TEXTURES_AND_PORTRAITS_OK")

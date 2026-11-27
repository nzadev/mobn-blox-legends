#!/usr/bin/env python3
import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

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
        "aura": "#38bdf8", "weapon": "cannon",
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
        "aura": "#3b82f6", "weapon": "dual_blades",
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
        "aura": "#e11d48", "weapon": "dragon_claws",
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
        "aura": "#eab308", "weapon": "whip",
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
        "aura": "#f97316", "weapon": "gauntlets",
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
        "aura": "#ec4899", "weapon": "splat_gun",
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
        "aura": "#ea580c", "weapon": "giant_hammer",
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
        "aura": "#4ade80", "weapon": "tome_scroll",
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
        "aura": "#84cc16", "weapon": "katana",
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
        "aura": "#60a5fa", "weapon": "dual_pistols",
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
        "aura": "#3b82f6", "weapon": "greatsword",
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
        "aura": "#22d3ee", "weapon": "dual_blades",
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

def make_face_texture(hero):
    img = Image.new("RGBA", (256, 256), hex_to_rgba(hero["skin"]))
    d = ImageDraw.Draw(img)
    hid = hero["id"]
    if hid == "minotor":
        d.rectangle([46, 92, 94, 120], fill=hex_to_rgba("#fde047"))
        d.rectangle([162, 92, 210, 120], fill=hex_to_rgba("#fde047"))
        d.rectangle([68, 140, 188, 214], fill=hex_to_rgba("#7c2d12"))
        d.ellipse([100, 170, 156, 226], outline=hex_to_rgba("#facc15"), width=10)
    elif hid == "yuzong":
        d.rectangle([36, 88, 220, 130], fill=hex_to_rgba("#09090b"))
        d.rectangle([50, 98, 106, 118], fill=hex_to_rgba("#e11d48"))
        d.rectangle([150, 98, 206, 118], fill=hex_to_rgba("#e11d48"))
        d.line([96, 186, 160, 182], fill=hex_to_rgba("#e11d48"), width=6)
    else:
        d.ellipse([36, 151, 80, 173], fill=(244, 114, 182, 95))
        d.ellipse([176, 151, 220, 173], fill=(244, 114, 182, 95))
        brow = hex_to_rgba("#b45309" if hid == "laylul" else "#1e293b")
        d.line([46, 86, 74, 80, 98, 88], fill=brow, width=8)
        d.line([158, 88, 182, 80, 210, 86], fill=brow, width=8)
        iris = hex_to_rgba("#f59e0b" if hid == "yeen" else ("#38bdf8" if hid == "esteez" else "#0284c7"))
        for cx in (74, 182):
            d.rectangle([cx - 28, 100, cx + 28, 110], fill=hex_to_rgba("#0f172a"))
            d.rectangle([cx - 24, 108, cx + 24, 150], fill=(255, 255, 255, 255))
            d.rectangle([cx - 18, 110, cx + 18, 148], fill=hex_to_rgba("#0c4a6e"))
            d.rectangle([cx - 14, 116, cx + 14, 146], fill=iris)
            d.rectangle([cx - 7, 122, cx + 7, 140], fill=hex_to_rgba("#082f49"))
            d.rectangle([cx - 14, 112, cx - 3, 123], fill=(255, 255, 255, 255))
            d.rectangle([cx + 6, 132, cx + 13, 139], fill=(255, 255, 255, 255))
        d.arc([110, 156, 146, 192], start=20, end=160, fill=hex_to_rgba("#9a3412"), width=6)
    img.save(os.path.join(BASE_DIR, "textures/faces", f"{hid}_face.png"))

def make_torso_texture(hero):
    img = Image.new("RGBA", (256, 256), hex_to_rgba(hero["torso"]))
    d = ImageDraw.Draw(img)
    hid = hero["id"]
    if hid == "laylul":
        d.rectangle([0, 0, 62, 256], fill=hex_to_rgba("#d8cfe8"))
        d.rectangle([194, 0, 256, 256], fill=hex_to_rgba("#d8cfe8"))
        stripes = ["#6b21a8", "#a855f7", "#d97706", "#6b21a8"]
        for i, col in enumerate(stripes):
            d.rectangle([72 + i * 28, 18, 90 + i * 28, 110], fill=hex_to_rgba(col))
        d.rectangle([64, 12, 192, 120], outline=hex_to_rgba("#d97706"), width=8)
        d.rectangle([68, 125, 188, 225], fill=hex_to_rgba("#3b0764"))
        d.rectangle([0, 198, 256, 224], fill=hex_to_rgba("#facc15"))
        d.rectangle([112, 194, 144, 228], fill=hex_to_rgba("#38bdf8"))
    else:
        d.rectangle([0, 0, 68, 256], fill=hex_to_rgba(hero["coat"]))
        d.rectangle([188, 0, 256, 256], fill=hex_to_rgba(hero["coat"]))
        d.rectangle([62, 0, 74, 256], fill=hex_to_rgba(hero["trim"]))
        d.rectangle([182, 0, 194, 256], fill=hex_to_rgba(hero["trim"]))
        d.rectangle([0, 206, 256, 230], fill=hex_to_rgba(hero["trim"]))
    img.save(os.path.join(BASE_DIR, "textures/torsos", f"{hid}_torso.png"))

def make_portrait(hero):
    w, h = 180, 200
    img = Image.new("RGBA", (w, h), hex_to_rgba("#0f172a"))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(30 * (1 - t) + 9 * t)
        g = int(58 * (1 - t) + 13 * t)
        b = int(138 * (1 - t) + 22 * t)
        d.line([(0, y), (w, y)], fill=(r, g, b, 255))

    aura = hex_to_rgba(hero["aura"], 90)
    d.ellipse([25, 30, 155, 160], fill=aura)

    if hero["hairStyle"] == "twintails":
        d.rectangle([14, 48, 42, 193], fill=hex_to_rgba(hero["hair"]))
        d.rectangle([138, 48, 166, 193], fill=hex_to_rgba(hero["hair"]))
        d.rectangle([26, 40, 46, 56], fill=hex_to_rgba("#0284c7"))
        d.rectangle([134, 40, 154, 56], fill=hex_to_rgba("#0284c7"))

    d.rectangle([28, 118, 152, 200], fill=hex_to_rgba(hero["coat"]))
    d.rectangle([58, 118, 122, 200], fill=hex_to_rgba(hero["torso"]))
    d.rectangle([50, 118, 60, 200], fill=hex_to_rgba(hero["trim"]))
    d.rectangle([120, 118, 130, 200], fill=hex_to_rgba(hero["trim"]))

    d.rectangle([50, 42, 130, 116], fill=hex_to_rgba(hero["skin"]))
    d.rectangle([46, 26, 134, 52], fill=hex_to_rgba(hero["hair"]))

    if hero["hairStyle"] in ("horns", "bull_horns"):
        d.rectangle([36, 10, 52, 38], fill=hex_to_rgba(hero["trim"]))
        d.rectangle([128, 10, 144, 38], fill=hex_to_rgba(hero["trim"]))
    elif hero["hairStyle"] in ("cyber_helm", "goggles_helm"):
        d.rectangle([48, 66, 132, 84], fill=hex_to_rgba(hero["trim"]))

    if hero["id"] == "yuzong":
        d.rectangle([58, 72, 80, 82], fill=hex_to_rgba("#e11d48"))
        d.rectangle([100, 72, 122, 82], fill=hex_to_rgba("#e11d48"))
    else:
        d.rectangle([62, 68, 78, 86], fill=hex_to_rgba("#0f172a"))
        d.rectangle([102, 68, 118, 86], fill=hex_to_rgba("#0f172a"))
        d.rectangle([64, 72, 76, 84], fill=hex_to_rgba("#38bdf8"))
        d.rectangle([104, 72, 116, 84], fill=hex_to_rgba("#38bdf8"))
        d.rectangle([64, 70, 69, 75], fill=(255, 255, 255, 255))
        d.rectangle([104, 70, 109, 75], fill=(255, 255, 255, 255))

    d.arc([82, 92, 98, 106], start=20, end=160, fill=hex_to_rgba("#7c2d12"), width=3)
    d.rectangle([0, 0, w - 1, h - 1], outline=hex_to_rgba(hero["trim"]), width=4)
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
    import random
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

print("GENERATED_ALL_TEXTURES_AND_ICONS_OK")


class_name RobloxHeroBuilder
extends RefCounted

static func make_mat(hex_str: String, rough: float = 0.4, metal: float = 0.15, emit_intensity: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var col := Color.from_string(hex_str, Color.WHITE)
	mat.albedo_color = col
	mat.roughness = rough
	mat.metallic = metal
	if emit_intensity > 0.0:
		mat.emission_enabled = true
		mat.emission = col
		mat.emission_energy_multiplier = emit_intensity
	return mat

static func make_box(size: Vector3, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func make_cone(rad: float, h: float, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.02
	cm.bottom_radius = rad
	cm.height = h
	cm.radial_segments = 6
	mi.mesh = cm
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func make_cyl(r_top: float, r_bot: float, h: float, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r_top
	cm.bottom_radius = r_bot
	cm.height = h
	cm.radial_segments = 12
	mi.mesh = cm
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func make_torus(r_in: float, r_out: float, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = r_in
	tm.outer_radius = r_out
	mi.mesh = tm
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func build_hero_rig(hero: HeroData, skin_override: Dictionary = {}) -> RobloxHeroRig:
	var coat_hex: String = skin_override.get("coat", hero.coat_color)
	var hair_hex: String = skin_override.get("hair", hero.hair_color)
	var trim_hex: String = skin_override.get("trim", hero.trim_color)

	var rig := RobloxHeroRig.new()
	rig.name = "RobloxRig_" + hero.id
	rig.hero_id = hero.id

	var mat_skin := make_mat(hero.skin_color, 0.38, 0.06)
	var mat_hair := make_mat(hair_hex, 0.34, 0.16)
	var mat_coat := make_mat(coat_hex, 0.4, 0.28)
	var mat_trim := make_mat(trim_hex, 0.22, 0.78, 0.38)
	var mat_aura := make_mat(hero.aura_color, 0.15, 0.4, 0.95)
	var mat_pants := make_mat(hero.pants_color, 0.52, 0.05)
	var mat_weapon := make_mat(hero.weapon_color, 0.2, 0.85, 0.45)

	var left_leg_pivot := _build_leg(-0.28, mat_pants, mat_trim, mat_coat)
	var right_leg_pivot := _build_leg(0.28, mat_pants, mat_trim, mat_coat)
	rig.add_child(left_leg_pivot)
	rig.add_child(right_leg_pivot)
	rig.left_leg_pivot = left_leg_pivot
	rig.right_leg_pivot = right_leg_pivot

	var torso_group := Node3D.new()
	torso_group.position = Vector3(0.0, 1.56, 0.0)
	torso_group.add_child(make_box(Vector3(1.08, 1.12, 0.56), mat_coat))

	if ResourceLoader.exists(hero.torso_tex_path):
		var front_mat := StandardMaterial3D.new()
		front_mat.albedo_texture = load(hero.torso_tex_path) as Texture2D
		front_mat.roughness = 0.4
		var chest_quad := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.06, 1.1)
		chest_quad.mesh = qm
		chest_quad.material_override = front_mat
		chest_quad.position = Vector3(0.0, 0.0, 0.285)
		torso_group.add_child(chest_quad)

	torso_group.add_child(make_box(Vector3(0.82, 0.48, 0.1), mat_coat, Vector3(0.0, 0.16, 0.29)))
	torso_group.add_child(make_box(Vector3(0.24, 0.24, 0.16), mat_aura, Vector3(0.0, 0.16, 0.34), Vector3(0.0, 0.0, PI / 4.0)))
	torso_group.add_child(make_box(Vector3(1.14, 0.18, 0.62), mat_trim, Vector3(0.0, -0.44, 0.0)))

	for tx: float in [-0.56, 0.56]:
		torso_group.add_child(make_box(Vector3(0.16, 0.46, 0.58), mat_coat, Vector3(tx, -0.62, 0.0), Vector3(0.0, 0.0, 0.18 if tx < 0.0 else -0.18)))

	for dir: float in [-1.0, 1.0]:
		torso_group.add_child(make_box(Vector3(0.46, 0.28, 0.68), mat_trim, Vector3(dir * 0.54, 0.48, 0.02), Vector3(0.0, 0.0, dir * -0.22)))
		torso_group.add_child(make_cone(0.14, 0.38, mat_aura, Vector3(dir * 0.66, 0.66, 0.02), Vector3(0.0, 0.0, dir * -0.45)))

	if hero.id == "yuzong":
		for dir: float in [-1.0, 1.0]:
			for i: int in range(3):
				var fi: float = float(i)
				torso_group.add_child(make_box(
					Vector3(0.16, 1.15 - fi * 0.22, 0.14),
					mat_trim,
					Vector3(dir * (0.55 + fi * 0.32), 0.35 - fi * 0.15, -0.38 - fi * 0.05),
					Vector3(0.0, 0.0, dir * (-0.55 - fi * 0.25))
				))
	elif hero.id == "kimee":
		for jx: float in [-0.28, 0.28]:
			torso_group.add_child(make_cyl(0.18, 0.22, 0.88, mat_trim, Vector3(jx, 0.05, -0.45)))
			torso_group.add_child(make_cone(0.16, 0.42, mat_aura, Vector3(jx, -0.55, -0.45), Vector3(PI, 0.0, 0.0)))
	elif hero.id in ["esteez", "kajee"]:
		torso_group.add_child(make_torus(0.88, 0.98, mat_aura, Vector3(0.0, 0.55, -0.42), Vector3(PI / 2.0, 0.0, 0.0)))
		torso_group.add_child(make_box(Vector3(1.16, 1.45, 0.1), mat_coat, Vector3(0.0, -0.45, -0.32), Vector3(0.16, 0.0, 0.0)))
	elif hero.id in ["sabro", "masteryee", "gusionox"]:
		for dir: float in [-1.0, 1.0]:
			torso_group.add_child(make_box(Vector3(0.12, 1.1, 0.28), mat_aura, Vector3(dir * 0.48, 0.28, -0.42), Vector3(-0.25, 0.0, dir * -0.42)))
	else:
		torso_group.add_child(make_box(Vector3(1.14, 1.38, 0.1), mat_coat, Vector3(0.0, -0.45, -0.32), Vector3(0.14, 0.0, 0.0)))

	rig.add_child(torso_group)
	rig.torso_group = torso_group

	var head_group := Node3D.new()
	head_group.position = Vector3(0.0, 2.55, 0.0)
	head_group.add_child(make_box(Vector3(0.88, 0.88, 0.88), mat_skin))

	if ResourceLoader.exists(hero.face_tex_path):
		var face_mat := StandardMaterial3D.new()
		face_mat.albedo_texture = load(hero.face_tex_path) as Texture2D
		face_mat.roughness = 0.38
		var face_quad := MeshInstance3D.new()
		var fqm := QuadMesh.new()
		fqm.size = Vector2(0.86, 0.86)
		face_quad.mesh = fqm
		face_quad.material_override = face_mat
		face_quad.position = Vector3(0.0, 0.0, 0.445)
		head_group.add_child(face_quad)

	head_group.add_child(make_box(Vector3(0.98, 0.34, 0.98), mat_hair, Vector3(0.0, 0.4, 0.0)))
	head_group.add_child(make_box(Vector3(0.96, 0.88, 0.28), mat_hair, Vector3(0.0, 0.04, -0.4)))

	for i: int in [-1, 0, 1]:
		var fi: float = float(i)
		head_group.add_child(make_cone(0.24, 0.56, mat_hair, Vector3(fi * 0.32, 0.68, -0.12), Vector3(-0.28, 0.0, fi * -0.32)))

	head_group.add_child(make_box(Vector3(0.18, 0.84, 0.34), mat_hair, Vector3(-0.46, -0.06, 0.28)))
	head_group.add_child(make_box(Vector3(0.18, 0.84, 0.34), mat_hair, Vector3(0.46, -0.06, 0.28)))
	head_group.add_child(make_box(Vector3(0.44, 0.28, 0.2), mat_hair, Vector3(-0.24, 0.28, 0.44), Vector3(0.0, 0.0, 0.22)))
	head_group.add_child(make_box(Vector3(0.44, 0.28, 0.2), mat_hair, Vector3(0.24, 0.28, 0.44), Vector3(0.0, 0.0, -0.22)))

	if hero.hair_style == "twintails":
		head_group.add_child(make_box(Vector3(0.94, 0.22, 0.36), mat_aura, Vector3(0.0, 0.42, 0.36)))
		var bow_mat := make_mat("#0284c7", 0.25, 0.4)
		for dir: float in [-1.0, 1.0]:
			head_group.add_child(make_box(Vector3(0.36, 0.3, 0.36), bow_mat, Vector3(dir * 0.58, 0.36, -0.05), Vector3(0.0, 0.0, dir * 0.25)))
			var t_group := Node3D.new()
			t_group.position = Vector3(dir * 0.66, 0.34, -0.08)
			t_group.rotation.z = dir * -0.2
			t_group.add_child(make_box(Vector3(0.38, 0.98, 0.38), mat_hair, Vector3(dir * 0.08, -0.44, 0.0)))
			t_group.add_child(make_box(Vector3(0.44, 1.18, 0.44), mat_hair, Vector3(dir * 0.22, -1.38, 0.06), Vector3(0.0, 0.0, dir * 0.1)))
			t_group.add_child(make_cone(0.28, 0.95, mat_hair, Vector3(dir * 0.3, -2.25, 0.12), Vector3(PI, 0.0, 0.0)))
			head_group.add_child(t_group)
			if dir < 0.0:
				rig.left_tail_group = t_group
			else:
				rig.right_tail_group = t_group
	elif hero.hair_style in ["horns", "bull_horns"]:
		var is_bull: bool = (hero.hair_style == "bull_horns")
		for dir: float in [-1.0, 1.0]:
			head_group.add_child(make_box(Vector3(0.24, 0.48, 0.24), mat_trim, Vector3(dir * 0.52, 0.46, 0.05), Vector3(0.0, 0.0, dir * -0.48)))
			head_group.add_child(make_cone(0.18, 0.85 if is_bull else 0.72, mat_aura, Vector3(dir * 0.74, 0.88, 0.08), Vector3(0.0, 0.0, dir * (0.15 if is_bull else -0.25))))
	elif hero.hair_style in ["cyber_helm", "goggles_helm"]:
		head_group.add_child(make_box(Vector3(0.96, 0.26, 0.96), mat_aura, Vector3(0.0, 0.08, 0.05)))
		head_group.add_child(make_box(Vector3(0.16, 0.62, 0.82), mat_trim, Vector3(0.0, 0.62, 0.08)))
	elif hero.hair_style in ["elf_crown", "bird_crest"]:
		for i: int in [-1, 0, 1]:
			var fi: float = float(i)
			head_group.add_child(make_cone(0.14, 0.56 - absf(fi) * 0.12, mat_trim, Vector3(fi * 0.26, 0.68, 0.38)))

	rig.add_child(head_group)
	rig.head_group = head_group

	var left_arm := _build_arm(-0.82, mat_coat, mat_trim, mat_skin)
	var right_arm := _build_arm(0.82, mat_coat, mat_trim, mat_skin)
	rig.add_child(left_arm)
	rig.add_child(right_arm)
	rig.left_arm_pivot = left_arm
	rig.right_arm_pivot = right_arm

	_attach_unique_hero_weapon(hero.id, right_arm, left_arm, mat_weapon, mat_trim, mat_aura, mat_coat, rig)
	return rig

static func _attach_unique_hero_weapon(
	hid: String,
	right_arm: Node3D,
	left_arm: Node3D,
	mat_weapon: Material,
	mat_trim: Material,
	mat_aura: Material,
	mat_coat: Material,
	rig: RobloxHeroRig
) -> void:
	var wg := Node3D.new()
	wg.position = Vector3(0.0, -0.9, 0.38)
	var lwg := Node3D.new()
	lwg.position = Vector3(0.0, -0.9, 0.38)

	match hid:
		"laylul":
			# Malefic Hex Void Cannon with twin stabilizer fins & glowing plasma coils
			wg.add_child(make_box(Vector3(0.56, 0.58, 1.55), mat_weapon, Vector3(0.0, 0.0, 0.45)))
			wg.add_child(make_cyl(0.24, 0.28, 1.95, mat_trim, Vector3(0.0, 0.06, 1.05), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_torus(0.28, 0.36, mat_aura, Vector3(0.0, 0.06, 1.45), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_torus(0.32, 0.42, mat_aura, Vector3(0.0, 0.06, 1.92), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_box(Vector3(0.95, 0.14, 0.65), mat_trim, Vector3(0.0, 0.06, 0.85)))
		"sabro":
			# Dual Cyber Ronin Katanas + 4 Floating Orbiting Drones around waist
			for arm_g: Node3D in [wg, lwg]:
				arm_g.add_child(make_box(Vector3(0.38, 0.12, 0.16), mat_trim, Vector3(0.0, 0.0, 0.18)))
				arm_g.add_child(make_box(Vector3(0.12, 0.08, 1.85), mat_weapon, Vector3(0.0, 0.0, 1.12)))
				arm_g.add_child(make_box(Vector3(0.06, 0.11, 1.78), mat_aura, Vector3(0.0, 0.02, 1.12)))
		"yuzong":
			# Sha Dragon Gauntlets with 3 curved crimson dragon talons on BOTH hands
			for arm_g: Node3D in [wg, lwg]:
				arm_g.add_child(make_box(Vector3(0.58, 0.48, 0.58), mat_trim, Vector3(0.0, 0.05, 0.05)))
				for ci: int in [-1, 0, 1]:
					var fci: float = float(ci)
					arm_g.add_child(make_cone(0.10, 0.92, mat_aura, Vector3(fci * 0.17, 0.0, 0.62), Vector3(PI / 2.0, 0.0, 0.0)))
		"kajee":
			# Multi-Segmented Electric Chain Whip + Left Buckler Shield
			for seg: int in range(6):
				var fs: float = float(seg)
				wg.add_child(make_box(
					Vector3(0.16, 0.16, 0.36),
					mat_aura if seg % 2 == 0 else mat_trim,
					Vector3(sin(fs * 0.65) * 0.24, cos(fs * 0.5) * 0.12, 0.3 + fs * 0.35),
					Vector3(0.0, sin(fs) * 0.35, 0.0)
				))
			lwg.add_child(make_torus(0.32, 0.46, mat_trim, Vector3(-0.15, 0.1, 0.1), Vector3(0.0, PI / 2.0, 0.0)))
		"yeen":
			# Colossal Lieh Spike Cestus Gauntlets + Golden Martial Rings on BOTH fists
			for arm_g: Node3D in [wg, lwg]:
				arm_g.add_child(make_box(Vector3(0.68, 0.64, 0.72), mat_weapon, Vector3(0.0, 0.0, 0.18)))
				arm_g.add_child(make_torus(0.38, 0.46, mat_trim, Vector3(0.0, 0.15, 0.15)))
				for ki: int in [-1, 0, 1]:
					arm_g.add_child(make_cone(0.11, 0.38, mat_aura, Vector3(float(ki) * 0.18, 0.0, 0.68), Vector3(PI / 2.0, 0.0, 0.0)))
		"kimee":
			# Twin-Nozzle Chemical Splat Gun with Top Green Acid Reservoir Tank
			wg.add_child(make_box(Vector3(0.46, 0.48, 1.35), mat_weapon, Vector3(0.0, 0.0, 0.45)))
			var acid_mat := make_mat("#4ade80", 0.15, 0.2, 0.95)
			wg.add_child(make_cyl(0.24, 0.24, 0.75, acid_mat, Vector3(0.0, 0.42, 0.45), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_cyl(0.12, 0.14, 0.65, mat_trim, Vector3(-0.14, 0.05, 1.25), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_cyl(0.12, 0.14, 0.65, mat_trim, Vector3(0.14, 0.05, 1.25), Vector3(PI / 2.0, 0.0, 0.0)))
		"minotor":
			# Colossal Double-Headed Minoan Quake Warhammer with Lava Spikes
			wg.add_child(make_cyl(0.12, 0.12, 2.35, mat_coat, Vector3(0.0, 0.0, 0.75), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_box(Vector3(1.55, 0.92, 0.92), mat_weapon, Vector3(0.0, 0.0, 1.62)))
			wg.add_child(make_box(Vector3(1.68, 0.48, 0.48), mat_aura, Vector3(0.0, 0.0, 1.62)))
			wg.add_child(make_cone(0.22, 0.55, mat_trim, Vector3(0.0, 0.0, 2.25), Vector3(PI / 2.0, 0.0, 0.0)))
		"esteez":
			# Royal Crescent Moon Scepter (Right Hand) + Floating Open Scripture Tome (Left Hand)
			wg.add_child(make_cyl(0.08, 0.08, 2.1, mat_trim, Vector3(0.0, 0.0, 0.65), Vector3(PI / 2.0, 0.0, 0.0)))
			wg.add_child(make_torus(0.36, 0.48, mat_aura, Vector3(0.0, 0.0, 1.65), Vector3(PI / 2.0, 0.0, 0.0)))
			lwg.add_child(make_box(Vector3(0.55, 0.12, 0.72), mat_trim, Vector3(0.0, 0.25, 0.45), Vector3(0.3, 0.0, 0.25)))
			lwg.add_child(make_box(Vector3(0.48, 0.16, 0.64), mat_aura, Vector3(0.0, 0.32, 0.45), Vector3(0.3, 0.0, 0.25)))
		"masteryee":
			# Wuju Jade Ring-Pommel Long Katana with 3 glowing emerald power gems
			wg.add_child(make_torus(0.14, 0.20, mat_trim, Vector3(0.0, 0.0, -0.15)))
			wg.add_child(make_box(Vector3(0.46, 0.14, 0.18), mat_trim, Vector3(0.0, 0.0, 0.22)))
			wg.add_child(make_box(Vector3(0.14, 0.08, 2.05), mat_weapon, Vector3(0.0, 0.0, 1.25)))
			for gi: int in range(3):
				wg.add_child(make_box(Vector3(0.18, 0.14, 0.18), mat_aura, Vector3(0.0, 0.0, 0.55 + float(gi) * 0.45)))
		"ketootoo":
			# Twin Hex-Tech Arcane Revolvers (One in Right Hand, One in Left Hand)
			for arm_g: Node3D in [wg, lwg]:
				arm_g.add_child(make_box(Vector3(0.24, 0.36, 0.28), mat_coat, Vector3(0.0, -0.1, 0.15)))
				arm_g.add_child(make_box(Vector3(0.28, 0.28, 0.95), mat_weapon, Vector3(0.0, 0.08, 0.52)))
				arm_g.add_child(make_cyl(0.12, 0.12, 0.42, mat_aura, Vector3(0.0, 0.08, 0.95), Vector3(PI / 2.0, 0.0, 0.0)))
		"alucardox":
			# Colossal Demon-Runed Buster Greatsword with Jagged Crimson Core
			wg.add_child(make_box(Vector3(0.88, 0.18, 0.24), mat_trim, Vector3(0.0, 0.0, 0.25)))
			wg.add_child(make_box(Vector3(0.46, 0.10, 2.45), mat_weapon, Vector3(0.0, 0.0, 1.48)))
			wg.add_child(make_box(Vector3(0.22, 0.14, 2.25), mat_aura, Vector3(0.0, 0.0, 1.45)))
			wg.add_child(make_cone(0.24, 0.55, mat_weapon, Vector3(0.0, 0.0, 2.85), Vector3(PI / 2.0, 0.0, 0.0)))
		"gusionox":
			# 5-Dagger Glowing Fan in Left Hand + Primary Assassin Dagger in Right Hand
			wg.add_child(make_cone(0.14, 1.25, mat_aura, Vector3(0.0, 0.0, 0.72), Vector3(PI / 2.0, 0.0, 0.0)))
			for di: int in range(-2, 3):
				var fdi: float = float(di)
				lwg.add_child(make_cone(
					0.08,
					0.95,
					mat_aura,
					Vector3(fdi * 0.22, 0.0, 0.55),
					Vector3(PI / 2.0, fdi * 0.25, 0.0)
				))

	right_arm.add_child(wg)
	left_arm.add_child(lwg)
	rig.weapon_group = wg
	rig.left_weapon_group = lwg

static func build_monster_rig(monster_id: String, col_hex: String, scale_f: float) -> Node3D:
	var g := Node3D.new()
	g.name = "MonsterRig_" + monster_id
	var mat_body := make_mat(col_hex, 0.45, 0.2)
	var tex_path: String = "res://assets/textures/monsters/%s_tex.png" % monster_id
	if ResourceLoader.exists(tex_path):
		mat_body.albedo_texture = load(tex_path) as Texture2D

	var mat_trim := make_mat("#facc15", 0.25, 0.7, 0.45)
	var mat_glow := make_mat(col_hex, 0.15, 0.3, 1.15)
	var mat_dark := make_mat("#1e1b2e", 0.6, 0.2)

	if monster_id == "crimson_buff":
		# Colossal 4-Legged Molten Magma Fiend with Back Lava Spikes & Curved Demon Horns
		g.add_child(make_box(Vector3(1.6 * scale_f, 1.3 * scale_f, 2.2 * scale_f), mat_body, Vector3(0.0, 1.0 * scale_f, 0.0)))
		g.add_child(make_box(Vector3(1.25 * scale_f, 1.05 * scale_f, 1.1 * scale_f), mat_body, Vector3(0.0, 1.45 * scale_f, 1.15 * scale_f)))
		for lx: float in [-0.65, 0.65]:
			for lz: float in [-0.75, 0.75]:
				g.add_child(make_box(Vector3(0.45 * scale_f, 0.95 * scale_f, 0.45 * scale_f), mat_dark, Vector3(lx * scale_f, 0.48 * scale_f, lz * scale_f)))
		for hx: float in [-0.52, 0.52]:
			g.add_child(make_cone(0.24 * scale_f, 1.05 * scale_f, mat_trim, Vector3(hx * scale_f, 2.15 * scale_f, 1.15 * scale_f), Vector3(0.45, 0.0, -hx * 0.5)))
		for si: int in range(3):
			g.add_child(make_cone(0.22 * scale_f, 0.85 * scale_f, mat_glow, Vector3(0.0, 1.85 * scale_f, (-0.7 + float(si) * 0.65) * scale_f), Vector3(-0.35, 0.0, 0.0)))
	elif monster_id == "azure_golem":
		# Giant Ancient Rune Golem with Floating Crystal Core & Massive Stone Fists
		g.add_child(make_box(Vector3(1.85 * scale_f, 1.65 * scale_f, 1.25 * scale_f), mat_body, Vector3(0.0, 1.55 * scale_f, 0.0)))
		g.add_child(make_box(Vector3(0.95 * scale_f, 0.85 * scale_f, 0.95 * scale_f), mat_body, Vector3(0.0, 2.65 * scale_f, 0.1 * scale_f)))
		g.add_child(make_torus(0.55 * scale_f, 0.68 * scale_f, mat_glow, Vector3(0.0, 1.6 * scale_f, 0.65 * scale_f), Vector3(PI / 2.0, 0.0, 0.0)))
		for dir: float in [-1.0, 1.0]:
			g.add_child(make_box(Vector3(0.62 * scale_f, 1.45 * scale_f, 0.62 * scale_f), mat_body, Vector3(dir * 1.35 * scale_f, 1.35 * scale_f, 0.25 * scale_f)))
			g.add_child(make_box(Vector3(0.75 * scale_f, 0.75 * scale_f, 0.75 * scale_f), mat_glow, Vector3(dir * 1.35 * scale_f, 0.55 * scale_f, 0.35 * scale_f)))
			g.add_child(make_box(Vector3(0.55 * scale_f, 0.95 * scale_f, 0.55 * scale_f), mat_dark, Vector3(dir * 0.52 * scale_f, 0.48 * scale_f, 0.0)))
	elif monster_id == "river_crab":
		# Golden Armored River Scuttler Crab with Twin Pincer Claws & Gem Shell
		g.add_child(make_cyl(1.15 * scale_f, 1.35 * scale_f, 0.85 * scale_f, mat_body, Vector3(0.0, 0.65 * scale_f, 0.0)))
		g.add_child(make_cone(0.55 * scale_f, 0.75 * scale_f, mat_trim, Vector3(0.0, 1.35 * scale_f, 0.0)))
		for dir: float in [-1.0, 1.0]:
			g.add_child(make_box(Vector3(0.55 * scale_f, 0.42 * scale_f, 0.95 * scale_f), mat_trim, Vector3(dir * 1.15 * scale_f, 0.65 * scale_f, 0.85 * scale_f), Vector3(0.0, dir * -0.35, 0.0)))
			for li: int in range(3):
				g.add_child(make_box(Vector3(0.75 * scale_f, 0.18 * scale_f, 0.18 * scale_f), mat_dark, Vector3(dir * 1.25 * scale_f, 0.35 * scale_f, (-0.5 + float(li) * 0.5) * scale_f), Vector3(0.0, 0.0, dir * -0.45)))
	else:
		# Razor Tusk Forest Boar with Armored Spine Crest & Ivory Tusks
		g.add_child(make_box(Vector3(1.35 * scale_f, 1.15 * scale_f, 1.85 * scale_f), mat_body, Vector3(0.0, 0.85 * scale_f, 0.0)))
		g.add_child(make_box(Vector3(1.05 * scale_f, 0.88 * scale_f, 0.95 * scale_f), mat_body, Vector3(0.0, 1.05 * scale_f, 1.05 * scale_f)))
		for dir: float in [-1.0, 1.0]:
			g.add_child(make_cone(0.16 * scale_f, 0.75 * scale_f, mat_trim, Vector3(dir * 0.48 * scale_f, 0.95 * scale_f, 1.65 * scale_f), Vector3(0.85, 0.0, dir * -0.25)))
			for lz: float in [-0.65, 0.65]:
				g.add_child(make_box(Vector3(0.32 * scale_f, 0.65 * scale_f, 0.32 * scale_f), mat_dark, Vector3(dir * 0.45 * scale_f, 0.32 * scale_f, lz * scale_f)))

	return g

static func build_minion_rig(team_str: String, role_idx: int) -> Node3D:
	var g := Node3D.new()
	g.name = "MinionRig_%s_%d" % [team_str, role_idx]
	var b_col: String = "#1d4ed8" if team_str == "blue" else "#b91c1c"
	var h_col: String = "#60a5fa" if team_str == "blue" else "#f87171"
	var glow_col: String = "#38bdf8" if team_str == "blue" else "#ef4444"

	var mat_armor := make_mat(b_col, 0.45, 0.35)
	var tex_path: String = "res://assets/textures/minions/minion_%s_tex.png" % team_str
	if ResourceLoader.exists(tex_path):
		mat_armor.albedo_texture = load(tex_path) as Texture2D

	var mat_trim := make_mat(h_col, 0.3, 0.6, 0.3)
	var mat_glow := make_mat(glow_col, 0.2, 0.3, 0.95)
	var mat_skin := make_mat("#fde68a", 0.45, 0.05)

	if role_idx == 2:
		# Siege Cannon Cart Minion (Index 2) with 4 Wheels & Heavy Mortar Barrel
		g.add_child(make_box(Vector3(1.15, 0.55, 1.45), mat_armor, Vector3(0.0, 0.52, 0.0)))
		g.add_child(make_cyl(0.24, 0.32, 1.45, mat_trim, Vector3(0.0, 0.95, 0.25), Vector3(PI / 2.8, 0.0, 0.0)))
		g.add_child(make_torus(0.22, 0.28, mat_glow, Vector3(0.0, 1.25, 0.78), Vector3(PI / 2.8, 0.0, 0.0)))
		for wx: float in [-0.62, 0.62]:
			for wz: float in [-0.48, 0.48]:
				g.add_child(make_cyl(0.28, 0.28, 0.16, mat_trim, Vector3(wx, 0.28, wz), Vector3(0.0, 0.0, PI / 2.0)))
	elif role_idx == 1:
		# Arcane Caster Mage Minion (Index 1) with Wizard Cone Hat & Glowing Orb Staff
		g.add_child(make_box(Vector3(0.76, 0.98, 0.58), mat_armor, Vector3(0.0, 0.65, 0.0)))
		g.add_child(make_box(Vector3(0.62, 0.62, 0.62), mat_skin, Vector3(0.0, 1.45, 0.0)))
		g.add_child(make_cone(0.55, 0.78, mat_trim, Vector3(0.0, 2.05, 0.0)))
		g.add_child(make_cyl(0.06, 0.06, 1.35, mat_trim, Vector3(0.48, 0.85, 0.25)))
		g.add_child(make_cone(0.22, 0.38, mat_glow, Vector3(0.48, 1.58, 0.25)))
	else:
		# Armored Melee Knight Minion (Index 0) with Tower Shield, Broadsword & Visor Helm
		g.add_child(make_box(Vector3(0.82, 1.02, 0.62), mat_armor, Vector3(0.0, 0.68, 0.0)))
		g.add_child(make_box(Vector3(0.64, 0.64, 0.64), mat_skin, Vector3(0.0, 1.48, 0.0)))
		g.add_child(make_box(Vector3(0.72, 0.38, 0.72), mat_trim, Vector3(0.0, 1.78, 0.0)))
		g.add_child(make_box(Vector3(0.14, 0.85, 0.65), mat_trim, Vector3(-0.52, 0.78, 0.22), Vector3(0.0, 0.25, 0.0)))
		g.add_child(make_box(Vector3(0.12, 0.10, 1.15), mat_glow, Vector3(0.52, 0.78, 0.55)))

	return g

static func _build_leg(x_pos: float, mat_pants: Material, mat_trim: Material, mat_coat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x_pos, 1.02, 0.0)
	pivot.add_child(make_box(Vector3(0.45, 0.54, 0.46), mat_pants, Vector3(0.0, -0.26, 0.0)))
	pivot.add_child(make_box(Vector3(0.49, 0.2, 0.52), mat_trim, Vector3(0.0, -0.52, 0.04)))
	pivot.add_child(make_box(Vector3(0.5, 0.46, 0.52), mat_coat, Vector3(0.0, -0.78, 0.01)))
	pivot.add_child(make_box(Vector3(0.54, 0.12, 0.6), mat_trim, Vector3(0.0, -0.97, 0.04)))
	return pivot

static func _build_arm(x_offset: float, mat_coat: Material, mat_trim: Material, mat_skin: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x_offset, 2.02, 0.0)
	pivot.add_child(make_box(Vector3(0.5, 0.52, 0.52), mat_coat, Vector3(0.0, -0.22, 0.0)))
	pivot.add_child(make_box(Vector3(0.55, 0.36, 0.56), mat_trim, Vector3(0.0, -0.56, 0.0)))
	pivot.add_child(make_box(Vector3(0.42, 0.38, 0.42), mat_skin, Vector3(0.0, -0.84, 0.0)))
	return pivot

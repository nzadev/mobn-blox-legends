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

static func build_hero_rig(hero: HeroData, skin_override: Dictionary = {}) -> RobloxHeroRig:
	var coat_hex: String = skin_override.get("coat", hero.coat_color)
	var hair_hex: String = skin_override.get("hair", hero.hair_color)
	var trim_hex: String = skin_override.get("trim", hero.trim_color)

	var rig := RobloxHeroRig.new()
	rig.name = "RobloxRig_" + hero.id

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
			torso_group.add_child(make_box(Vector3(0.36, 0.88, 0.36), mat_trim, Vector3(jx, 0.05, -0.45)))
			torso_group.add_child(make_cone(0.16, 0.42, mat_aura, Vector3(jx, -0.55, -0.45), Vector3(PI, 0.0, 0.0)))
	elif hero.id in ["esteez", "kajee"]:
		var halo := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.88
		tm.outer_radius = 0.98
		halo.mesh = tm
		halo.material_override = mat_aura
		halo.position = Vector3(0.0, 0.55, -0.42)
		halo.rotation.x = PI / 2.0
		torso_group.add_child(halo)
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

	var weapon_group := Node3D.new()
	weapon_group.position = Vector3(0.0, -0.9, 0.38)
	if hero.weapon_type in ["cannon", "splat_gun"]:
		weapon_group.add_child(make_box(Vector3(0.52, 0.56, 1.5), mat_weapon, Vector3(0.0, 0.0, 0.45)))
		weapon_group.add_child(make_box(Vector3(0.4, 0.4, 1.85), mat_trim, Vector3(0.0, 0.08, 0.95)))
		weapon_group.add_child(make_box(Vector3(0.62, 0.62, 0.18), mat_aura, Vector3(0.0, 0.08, 1.75)))
		right_arm.rotation.x = 0.55
	elif hero.weapon_type == "giant_hammer":
		weapon_group.add_child(make_box(Vector3(0.2, 0.2, 2.2), mat_coat, Vector3(0.0, 0.0, 0.65)))
		weapon_group.add_child(make_box(Vector3(1.35, 0.85, 0.85), mat_weapon, Vector3(0.0, 0.0, 1.48)))
		weapon_group.add_child(make_box(Vector3(1.45, 0.45, 0.45), mat_aura, Vector3(0.0, 0.0, 1.48)))
		right_arm.rotation.x = 0.45
	elif hero.weapon_type in ["dual_blades", "katana", "greatsword"]:
		var is_great: bool = (hero.weapon_type == "greatsword")
		var bw: float = 0.36 if is_great else 0.16
		var bl: float = 2.25 if is_great else 1.75
		weapon_group.add_child(make_box(Vector3(0.72 if is_great else 0.42, 0.14, 0.18), mat_trim, Vector3(0.0, 0.0, 0.22)))
		weapon_group.add_child(make_box(Vector3(bw, 0.08, bl), mat_weapon, Vector3(0.0, 0.0, 0.25 + bl * 0.5)))
		weapon_group.add_child(make_box(Vector3(bw * 0.5, 0.11, bl * 0.92), mat_aura, Vector3(0.0, 0.0, 0.25 + bl * 0.5)))
		if hero.weapon_type == "dual_blades":
			left_arm.add_child(make_box(Vector3(bw, 0.08, bl), mat_weapon, Vector3(0.0, -0.9, 0.72)))
			left_arm.add_child(make_box(Vector3(bw * 0.5, 0.11, bl * 0.92), mat_aura, Vector3(0.0, -0.9, 0.72)))
	elif hero.weapon_type in ["dragon_claws", "gauntlets"]:
		for ci: int in [-1, 0, 1]:
			var fci: float = float(ci)
			weapon_group.add_child(make_cone(0.09, 0.75, mat_aura, Vector3(fci * 0.16, 0.0, 0.45), Vector3(PI / 2.0, 0.0, 0.0)))
			left_arm.add_child(make_cone(0.09, 0.75, mat_aura, Vector3(fci * 0.16, -0.9, 0.55), Vector3(PI / 2.0, 0.0, 0.0)))
	else:
		weapon_group.add_child(make_box(Vector3(0.14, 0.14, 1.85), mat_trim, Vector3(0.0, 0.0, 0.55)))
		var orb := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.38
		sm.height = 0.76
		orb.mesh = sm
		orb.material_override = mat_aura
		orb.position = Vector3(0.0, 0.0, 1.45)
		weapon_group.add_child(orb)

	right_arm.add_child(weapon_group)
	rig.weapon_group = weapon_group
	return rig

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

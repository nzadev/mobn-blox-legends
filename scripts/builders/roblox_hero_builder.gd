class_name RobloxHeroBuilder
extends RefCounted

static func make_mat(hex_str: String, rough: float = 0.45, metal: float = 0.1, emit_intensity: float = 0.0) -> StandardMaterial3D:
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

static func build_hero_rig(hero: HeroData, skin_override: Dictionary = {}) -> RobloxHeroRig:
	var coat_hex: String = skin_override.get("coat", hero.coat_color)
	var hair_hex: String = skin_override.get("hair", hero.hair_color)
	var trim_hex: String = skin_override.get("trim", hero.trim_color)

	var rig := RobloxHeroRig.new()
	rig.name = "RobloxRig_" + hero.id

	var mat_skin := make_mat(hero.skin_color, 0.42, 0.05)
	var mat_hair := make_mat(hair_hex, 0.38, 0.12)
	var mat_coat := make_mat(coat_hex, 0.45, 0.22)
	var mat_trim := make_mat(trim_hex, 0.28, 0.68, 0.35)
	var mat_pants := make_mat(hero.pants_color, 0.58, 0.05)
	var mat_weapon := make_mat(hero.weapon_color, 0.25, 0.78, 0.45)

	var left_leg_pivot := Node3D.new()
	left_leg_pivot.position = Vector3(-0.27, 1.0, 0.0)
	left_leg_pivot.add_child(make_box(Vector3(0.47, 1.0, 0.47), mat_pants, Vector3(0.0, -0.5, 0.0)))
	left_leg_pivot.add_child(make_box(Vector3(0.51, 0.3, 0.53), mat_coat, Vector3(0.0, -0.86, 0.02)))
	left_leg_pivot.add_child(make_box(Vector3(0.53, 0.1, 0.55), mat_trim, Vector3(0.0, -0.98, 0.02)))
	rig.add_child(left_leg_pivot)
	rig.left_leg_pivot = left_leg_pivot

	var right_leg_pivot := Node3D.new()
	right_leg_pivot.position = Vector3(0.27, 1.0, 0.0)
	right_leg_pivot.add_child(make_box(Vector3(0.47, 1.0, 0.47), mat_pants, Vector3(0.0, -0.5, 0.0)))
	right_leg_pivot.add_child(make_box(Vector3(0.51, 0.3, 0.53), mat_coat, Vector3(0.0, -0.86, 0.02)))
	right_leg_pivot.add_child(make_box(Vector3(0.53, 0.1, 0.55), mat_trim, Vector3(0.0, -0.98, 0.02)))
	rig.add_child(right_leg_pivot)
	rig.right_leg_pivot = right_leg_pivot

	var torso_group := Node3D.new()
	torso_group.position = Vector3(0.0, 1.55, 0.0)
	torso_group.add_child(make_box(Vector3(1.06, 1.1, 0.54), mat_coat))

	if ResourceLoader.exists(hero.torso_tex_path):
		var front_mat := StandardMaterial3D.new()
		front_mat.albedo_texture = load(hero.torso_tex_path) as Texture2D
		front_mat.roughness = 0.45
		var chest_plate := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.04, 1.08)
		chest_plate.mesh = qm
		chest_plate.material_override = front_mat
		chest_plate.position = Vector3(0.0, 0.0, 0.275)
		torso_group.add_child(chest_plate)

	torso_group.add_child(make_box(Vector3(0.32, 0.22, 0.62), mat_coat, Vector3(-0.36, 0.48, 0.02)))
	torso_group.add_child(make_box(Vector3(0.32, 0.22, 0.62), mat_coat, Vector3(0.36, 0.48, 0.02)))

	if hero.id in ["laylul", "yuzong", "esteez", "kajee"]:
		torso_group.add_child(make_box(Vector3(1.12, 1.35, 0.12), mat_coat, Vector3(0.0, -0.45, -0.32), Vector3(0.12, 0.0, 0.0)))

	rig.add_child(torso_group)
	rig.torso_group = torso_group

	var head_group := Node3D.new()
	head_group.position = Vector3(0.0, 2.52, 0.0)
	head_group.add_child(make_box(Vector3(0.86, 0.86, 0.86), mat_skin))

	if ResourceLoader.exists(hero.face_tex_path):
		var face_mat := StandardMaterial3D.new()
		face_mat.albedo_texture = load(hero.face_tex_path) as Texture2D
		face_mat.roughness = 0.4
		var face_quad := MeshInstance3D.new()
		var fqm := QuadMesh.new()
		fqm.size = Vector2(0.84, 0.84)
		face_quad.mesh = fqm
		face_quad.material_override = face_mat
		face_quad.position = Vector3(0.0, 0.0, 0.435)
		head_group.add_child(face_quad)

	head_group.add_child(make_box(Vector3(0.96, 0.3, 0.96), mat_hair, Vector3(0.0, 0.38, 0.0)))
	head_group.add_child(make_box(Vector3(0.94, 0.84, 0.24), mat_hair, Vector3(0.0, 0.04, -0.38)))
	head_group.add_child(make_box(Vector3(0.16, 0.78, 0.32), mat_hair, Vector3(-0.44, -0.04, 0.28)))
	head_group.add_child(make_box(Vector3(0.16, 0.78, 0.32), mat_hair, Vector3(0.44, -0.04, 0.28)))
	head_group.add_child(make_box(Vector3(0.42, 0.24, 0.18), mat_hair, Vector3(-0.24, 0.28, 0.43), Vector3(0.0, 0.0, 0.18)))
	head_group.add_child(make_box(Vector3(0.42, 0.24, 0.18), mat_hair, Vector3(0.24, 0.28, 0.43), Vector3(0.0, 0.0, -0.18)))

	if hero.hair_style == "twintails":
		var bow_mat := make_mat("#0284c7", 0.3, 0.1)
		for dir: float in [-1.0, 1.0]:
			head_group.add_child(make_box(Vector3(0.32, 0.28, 0.32), bow_mat, Vector3(dir * 0.56, 0.34, -0.05), Vector3(0.0, 0.0, dir * 0.25)))
			var t_group := Node3D.new()
			t_group.position = Vector3(dir * 0.64, 0.32, -0.08)
			t_group.rotation.z = dir * -0.18
			t_group.add_child(make_box(Vector3(0.36, 0.95, 0.36), mat_hair, Vector3(dir * 0.08, -0.42, 0.0)))
			t_group.add_child(make_box(Vector3(0.42, 1.15, 0.42), mat_hair, Vector3(dir * 0.2, -1.35, 0.05), Vector3(0.0, 0.0, dir * 0.08)))
			t_group.add_child(make_box(Vector3(0.34, 0.9, 0.34), mat_hair, Vector3(dir * 0.26, -2.22, 0.12), Vector3(0.0, 0.0, dir * 0.15)))
			head_group.add_child(t_group)
			if dir < 0.0:
				rig.left_tail_group = t_group
			else:
				rig.right_tail_group = t_group
	elif hero.hair_style in ["horns", "bull_horns"]:
		var h_len: float = 0.72 if hero.hair_style == "bull_horns" else 0.58
		head_group.add_child(make_box(Vector3(0.2, h_len, 0.2), mat_trim, Vector3(-0.46, 0.55, 0.05), Vector3(0.0, 0.0, 0.38)))
		head_group.add_child(make_box(Vector3(0.2, h_len, 0.2), mat_trim, Vector3(0.46, 0.55, 0.05), Vector3(0.0, 0.0, -0.38)))
	elif hero.hair_style in ["cyber_helm", "goggles_helm"]:
		var visor_mat := make_mat(trim_hex, 0.2, 0.8, 1.2)
		head_group.add_child(make_box(Vector3(0.92, 0.24, 0.92), visor_mat, Vector3(0.0, 0.08, 0.04)))
		head_group.add_child(make_box(Vector3(0.16, 0.48, 0.65), mat_trim, Vector3(0.0, 0.56, 0.1)))
	elif hero.hair_style in ["elf_crown", "bird_crest"]:
		head_group.add_child(make_box(Vector3(0.72, 0.38, 0.22), mat_trim, Vector3(0.0, 0.56, 0.38)))

	rig.add_child(head_group)
	rig.head_group = head_group

	var left_arm := _build_arm(-0.8, mat_coat, mat_trim, mat_skin)
	var right_arm := _build_arm(0.8, mat_coat, mat_trim, mat_skin)
	rig.add_child(left_arm)
	rig.add_child(right_arm)
	rig.left_arm_pivot = left_arm
	rig.right_arm_pivot = right_arm

	var weapon_group := Node3D.new()
	weapon_group.position = Vector3(0.0, -0.92, 0.35)
	if hero.weapon_type in ["cannon", "splat_gun"]:
		weapon_group.add_child(make_box(Vector3(0.44, 0.44, 1.65), mat_weapon, Vector3(0.0, 0.0, 0.5)))
		weapon_group.add_child(make_box(Vector3(0.54, 0.54, 0.48), mat_trim, Vector3(0.0, 0.0, 0.12)))
		right_arm.rotation.x = 0.55
	elif hero.weapon_type == "giant_hammer":
		weapon_group.add_child(make_box(Vector3(0.18, 0.18, 1.8), mat_coat, Vector3(0.0, 0.0, 0.48)))
		weapon_group.add_child(make_box(Vector3(1.05, 0.7, 0.7), mat_weapon, Vector3(0.0, 0.0, 1.25)))
		right_arm.rotation.x = 0.45
	elif hero.weapon_type in ["dual_blades", "katana", "greatsword"]:
		var bw: float = 0.3 if hero.weapon_type == "greatsword" else 0.14
		var bl: float = 1.95 if hero.weapon_type == "greatsword" else 1.55
		weapon_group.add_child(make_box(Vector3(bw, 0.08, bl), mat_weapon, Vector3(0.0, 0.0, bl * 0.48)))
		if hero.weapon_type == "dual_blades":
			left_arm.add_child(make_box(Vector3(bw, 0.08, bl), mat_weapon, Vector3(0.0, -0.92, 0.72)))
	else:
		var orb := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.35
		sm.height = 0.7
		orb.mesh = sm
		orb.material_override = mat_weapon
		orb.position = Vector3(0.0, 0.0, 0.48)
		weapon_group.add_child(orb)

	right_arm.add_child(weapon_group)
	rig.weapon_group = weapon_group
	return rig

static func _build_arm(x_offset: float, mat_coat: Material, mat_trim: Material, mat_skin: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x_offset, 2.0, 0.0)
	pivot.add_child(make_box(Vector3(0.52, 0.68, 0.54), mat_coat, Vector3(0.0, -0.26, 0.0)))
	pivot.add_child(make_box(Vector3(0.54, 0.14, 0.56), mat_trim, Vector3(0.0, -0.58, 0.0)))
	pivot.add_child(make_box(Vector3(0.42, 0.45, 0.42), mat_skin, Vector3(0.0, -0.82, 0.0)))
	return pivot


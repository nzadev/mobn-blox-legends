class_name ArenaBattleWorld
extends Node3D

signal floating_text_spawned(world_pos: Vector3, text: String, color_hex: String)
signal gold_popup_spawned(world_pos: Vector3, amount: int)
signal player_level_up(new_level: int)
signal hero_killed(killer: CombatUnit, victim: CombatUnit, callout: String)
signal match_ended(result: String)

var mode: String = "LOBBY"
var running: bool = false

var lobby_root: Node3D
var lobby_camera: Camera3D
var lobby_hero_rig: RobloxHeroRig = null

var arena_root: Node3D
var battle_camera: Camera3D
var target_lock_ring: MeshInstance3D

var hero_units: Array[CombatUnit] = []
var minion_units: Array[CombatUnit] = []
var creep_units: Array[CombatUnit] = []
var turret_units: Array[CombatUnit] = []

var obstacles: Array[Dictionary] = []
var bushes: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var vfx_list: Array[Dictionary] = []

var player_unit: CombatUnit = null
var match_time: float = 38.0
var blue_kills: int = 0
var red_kills: int = 1
var minion_wave_timer: float = 4.0
var first_blood_taken: bool = false

var shake_timer: float = 0.0
var shake_intensity: float = 0.0

var joy_vec: Vector2 = Vector2.ZERO
var holding_attack: bool = false

func _ready() -> void:
	_setup_world_environment()
	_setup_lobby_environment()
	_setup_battle_root()

func _setup_world_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0b172a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#dbeafe")
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -35.0, 0.0)
	sun.light_color = Color("#fffbeb")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _setup_lobby_environment() -> void:
	lobby_root = Node3D.new()
	lobby_root.name = "LobbyRoot"
	add_child(lobby_root)

	lobby_camera = Camera3D.new()
	lobby_camera.fov = 36.0
	lobby_camera.position = Vector3(0.0, 2.35, 5.2)
	lobby_root.add_child(lobby_camera)
	lobby_camera.look_at(Vector3(0.0, 1.75, 0.0), Vector3.UP)
	lobby_camera.current = true

	var rim := OmniLight3D.new()
	rim.light_color = Color("#38bdf8")
	rim.light_energy = 1.8
	rim.omni_range = 16.0
	rim.position = Vector3(-3.0, 4.0, -2.0)
	lobby_root.add_child(rim)

	var ped_group := Node3D.new()
	var base_cyl := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.75
	cm.bottom_radius = 2.05
	cm.height = 0.35
	base_cyl.mesh = cm
	base_cyl.material_override = RobloxHeroBuilder.make_mat("#1e293b", 0.3, 0.6)
	base_cyl.position.y = -0.18
	ped_group.add_child(base_cyl)

	var gold_ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 1.72
	tm.outer_radius = 1.84
	gold_ring.mesh = tm
	gold_ring.material_override = RobloxHeroBuilder.make_mat("#facc15", 0.25, 0.7, 0.5)
	gold_ring.position.y = 0.01
	ped_group.add_child(gold_ring)

	var inner_disc := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 1.5
	dm.bottom_radius = 1.5
	dm.height = 0.02
	inner_disc.mesh = dm
	var d_mat := RobloxHeroBuilder.make_mat("#38bdf8", 0.2, 0.1, 0.4)
	d_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	d_mat.albedo_color.a = 0.35
	inner_disc.material_override = d_mat
	inner_disc.position.y = 0.02
	ped_group.add_child(inner_disc)

	lobby_root.add_child(ped_group)

	var moon := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.4
	sm.height = 2.8
	moon.mesh = sm
	moon.material_override = RobloxHeroBuilder.make_mat("#e2e8f0", 0.2, 0.0, 0.8)
	moon.position = Vector3(2.4, 3.8, -6.5)
	lobby_root.add_child(moon)

	var bx_list: Array[float] = [-3.2, 1.2, 3.6]
	for idx: int in range(bx_list.size()):
		var bx: float = bx_list[idx]
		var banner := RobloxHeroBuilder.make_box(
			Vector3(1.1, 3.4, 0.08),
			RobloxHeroBuilder.make_mat("#1d4ed8", 0.6, 0.1),
			Vector3(bx, 3.3, -4.5 - float(idx % 2) * 0.5)
		)
		var border := RobloxHeroBuilder.make_box(
			Vector3(1.18, 3.46, 0.05),
			RobloxHeroBuilder.make_mat("#f59e0b", 0.3, 0.5),
			banner.position + Vector3(0.0, 0.0, -0.03)
		)
		lobby_root.add_child(banner)
		lobby_root.add_child(border)

func _setup_battle_root() -> void:
	arena_root = Node3D.new()
	arena_root.name = "ArenaRoot"
	arena_root.visible = false
	add_child(arena_root)

	battle_camera = Camera3D.new()
	battle_camera.fov = 42.0
	battle_camera.far = 220.0
	battle_camera.position = Vector3(-6.5, 21.5, 24.0)
	arena_root.add_child(battle_camera)
	battle_camera.look_at(Vector3(-6.5, 0.8, 5.3), Vector3.UP)

	target_lock_ring = MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 1.15
	tm.outer_radius = 1.38
	target_lock_ring.mesh = tm
	target_lock_ring.material_override = RobloxHeroBuilder.make_mat("#ef4444", 0.2, 0.1, 0.9)
	target_lock_ring.position.y = 0.08
	target_lock_ring.visible = false
	arena_root.add_child(target_lock_ring)

func set_lobby_hero(hero: HeroData, skin_override: Dictionary = {}) -> void:
	if lobby_hero_rig != null and is_instance_valid(lobby_hero_rig):
		lobby_hero_rig.queue_free()
		lobby_hero_rig = null
	lobby_hero_rig = RobloxHeroBuilder.build_hero_rig(hero, skin_override)
	lobby_hero_rig.position = Vector3(-0.25, 0.0, 0.0)
	lobby_hero_rig.rotation.y = 0.18
	lobby_root.add_child(lobby_hero_rig)

func rotate_lobby_hero(delta_yaw: float) -> void:
	if lobby_hero_rig != null and is_instance_valid(lobby_hero_rig):
		lobby_hero_rig.rotation.y += delta_yaw

func switch_to_lobby() -> void:
	mode = "LOBBY"
	running = false
	arena_root.visible = false
	lobby_root.visible = true
	lobby_camera.current = true
	battle_camera.current = false
	AudioSynthesizer.start_bgm("LOBBY")

func trigger_screen_shake(intensity: float = 0.4, duration: float = 0.28) -> void:
	shake_intensity = maxf(shake_intensity, intensity)
	shake_timer = maxf(shake_timer, duration)

func build_arena_map() -> void:
	for child: Node in arena_root.get_children():
		if child != battle_camera and child != target_lock_ring:
			child.queue_free()

	obstacles.clear()
	bushes.clear()
	turret_units.clear()
	creep_units.clear()
	minion_units.clear()
	hero_units.clear()
	projectiles.clear()
	vfx_list.clear()

	var grass_mat := StandardMaterial3D.new()
	if ResourceLoader.exists("res://assets/textures/terrain/grass.png"):
		grass_mat.albedo_texture = load("res://assets/textures/terrain/grass.png") as Texture2D
		grass_mat.uv1_scale = Vector3(18.0, 18.0, 1.0)
	else:
		grass_mat.albedo_color = Color("#6ba656")
	grass_mat.roughness = 0.88

	var grass_floor := RobloxHeroBuilder.make_box(Vector3(110.0, 0.2, 110.0), grass_mat, Vector3(0.0, -0.1, 0.0))
	arena_root.add_child(grass_floor)

	var stone_mat := StandardMaterial3D.new()
	if ResourceLoader.exists("res://assets/textures/terrain/stone.png"):
		stone_mat.albedo_texture = load("res://assets/textures/terrain/stone.png") as Texture2D
		stone_mat.uv1_scale = Vector3(12.0, 12.0, 1.0)
	else:
		stone_mat.albedo_color = Color("#9ca3af")
	stone_mat.roughness = 0.78

	var lane_mat := RobloxHeroBuilder.make_mat("#b4b8ab", 0.75, 0.05)
	var mid_lane := RobloxHeroBuilder.make_box(Vector3(10.5, 0.08, 92.0), lane_mat, Vector3(0.0, 0.02, 0.0), Vector3(0.0, PI / 4.0, 0.0))
	arena_root.add_child(mid_lane)

	var brick_mat := StandardMaterial3D.new()
	if ResourceLoader.exists("res://assets/textures/terrain/brick.png"):
		brick_mat.albedo_texture = load("res://assets/textures/terrain/brick.png") as Texture2D
		brick_mat.uv1_scale = Vector3(6.0, 2.0, 1.0)
	else:
		brick_mat.albedo_color = Color("#d6d3d1")
	brick_mat.roughness = 0.6
	var cap_mat := RobloxHeroBuilder.make_mat("#a8a29e", 0.5, 0.05)

	_create_brick_wall(16.0, -18.0, 22.0, -PI / 5.0, brick_mat, cap_mat)
	_create_brick_wall(-16.0, 18.0, 22.0, -PI / 5.0, brick_mat, cap_mat)
	_create_brick_wall(0.0, -44.0, 70.0, 0.0, brick_mat, cap_mat)
	_create_brick_wall(0.0, 44.0, 70.0, 0.0, brick_mat, cap_mat)
	_create_brick_wall(-44.0, 0.0, 70.0, PI / 2.0, brick_mat, cap_mat)
	_create_brick_wall(44.0, 0.0, 70.0, PI / 2.0, brick_mat, cap_mat)

	_create_river_pool(-11.0, -9.0, 9.8, 5.6, stone_mat)
	_create_river_pool(13.0, 11.0, 8.8, 4.8, stone_mat)

	_create_rock_cluster(-8.0, 6.0, 3.2, 7)
	_create_rock_cluster(7.0, -6.0, 3.2, 7)
	_create_rock_cluster(-21.0, -2.0, 3.5, 8)
	_create_rock_cluster(21.0, 2.0, 3.5, 8)
	_create_rock_cluster(-4.0, -22.0, 3.2, 7)
	_create_rock_cluster(4.0, 22.0, 3.2, 7)

	_create_bush_patch(-4.5, 2.5, 3.1)
	_create_bush_patch(4.5, -2.5, 3.1)
	_create_bush_patch(-11.0, -3.2, 3.0)
	_create_bush_patch(-11.0, -14.8, 3.0)
	_create_bush_patch(11.0, 4.2, 3.0)
	_create_bush_patch(13.0, -13.0, 3.2)
	_create_bush_patch(-15.0, 14.0, 3.2)

	_create_turret(-32.0, 32.0, "blue", true)
	_create_turret(-18.0, 18.0, "blue", false)
	_create_turret(-28.0, 10.0, "blue", false)
	_create_turret(-10.0, 28.0, "blue", false)

	_create_turret(32.0, -32.0, "red", true)
	_create_turret(18.0, -18.0, "red", false)
	_create_turret(28.0, -10.0, "red", false)
	_create_turret(10.0, -28.0, "red", false)

	_spawn_jungle_creep(-10.5, 8.5, "crimson_buff", "Crimson Molten Fiend", "#dc2626", 1.35)
	_spawn_jungle_creep(14.0, -4.0, "azure_golem", "Azure Sentinel Golem", "#2563eb", 1.35)
	_spawn_jungle_creep(-4.0, -14.0, "river_crab", "Golden Scuttler Crab", "#f59e0b", 1.0)
	_spawn_jungle_creep(4.0, 14.0, "forest_boar", "Razor Tusk Boar", "#d97706", 1.0)

func _create_brick_wall(x: float, z: float, length: float, rot_y: float, b_mat: Material, c_mat: Material) -> void:
	var wg := Node3D.new()
	wg.position = Vector3(x, 0.0, z)
	wg.rotation.y = rot_y
	wg.add_child(RobloxHeroBuilder.make_box(Vector3(length, 1.8, 1.4), b_mat, Vector3(0.0, 0.9, 0.0)))
	wg.add_child(RobloxHeroBuilder.make_box(Vector3(length + 0.3, 0.3, 1.65), c_mat, Vector3(0.0, 1.9, 0.0)))
	arena_root.add_child(wg)

func _create_river_pool(cx: float, cz: float, outer_r: float, inner_r: float, stone_mat: Material) -> void:
	var water := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = outer_r
	cm.bottom_radius = outer_r
	cm.height = 0.12
	water.mesh = cm
	water.material_override = RobloxHeroBuilder.make_mat("#0ea5e9", 0.2, 0.15, 0.25)
	water.position = Vector3(cx, 0.04, cz)
	arena_root.add_child(water)

	var island := MeshInstance3D.new()
	var icm := CylinderMesh.new()
	icm.top_radius = inner_r
	icm.bottom_radius = inner_r + 0.3
	icm.height = 0.25
	island.mesh = icm
	island.material_override = stone_mat
	island.position = Vector3(cx, 0.1, cz)
	arena_root.add_child(island)

func _create_rock_cluster(cx: float, cz: float, radius: float, count: int) -> void:
	var g := Node3D.new()
	g.position = Vector3(cx, 0.0, cz)
	var r_mat1 := RobloxHeroBuilder.make_mat("#78716c", 0.85, 0.05)
	var r_mat2 := RobloxHeroBuilder.make_mat("#57534e", 0.9, 0.05)
	for i: int in range(count):
		var ang: float = (float(i) / float(count)) * TAU
		var dist: float = 0.0 if i == 0 else radius * randf_range(0.45, 0.85)
		var w: float = randf_range(1.6, 3.0)
		var h: float = randf_range(1.8, 3.5)
		var d: float = randf_range(1.6, 3.0)
		var box := RobloxHeroBuilder.make_box(
			Vector3(w, h, d),
			r_mat1 if (i % 2 == 0) else r_mat2,
			Vector3(cos(ang) * dist, h * 0.5, sin(ang) * dist),
			Vector3(0.0, randf() * PI, 0.0)
		)
		g.add_child(box)
	arena_root.add_child(g)
	obstacles.append({"x": cx, "z": cz, "r": radius * 0.85})

func _create_bush_patch(bx: float, bz: float, radius: float) -> void:
	var bg := Node3D.new()
	bg.position = Vector3(bx, 0.0, bz)
	var cones: Array[MeshInstance3D] = []
	for i: int in range(14):
		var mi := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.05
		cm.bottom_radius = 0.78
		cm.height = 2.2
		cm.radial_segments = 6
		mi.mesh = cm
		var b_mat := RobloxHeroBuilder.make_mat("#2d8a6e", 0.65, 0.05)
		mi.material_override = b_mat
		var ang: float = (float(i) / 14.0) * TAU
		var rad: float = 0.5 if i < 4 else radius * 0.62
		mi.position = Vector3(cos(ang) * rad, 0.98, sin(ang) * rad)
		mi.rotation = Vector3(randf_range(-0.24, 0.24), 0.0, randf_range(-0.24, 0.24))
		bg.add_child(mi)
		cones.append(mi)
	arena_root.add_child(bg)
	bushes.append({"x": bx, "z": bz, "r": radius, "node": bg, "cones": cones})

func _create_turret(tx: float, tz: float, team_str: String, is_nexus_flag: bool) -> void:
	var u := CombatUnit.new()
	u.unit_id = "turret_%s_%d" % [team_str, turret_units.size()]
	u.unit_name = ("%s Base" if is_nexus_flag else "%s Turret") % team_str.to_upper()
	u.team = team_str
	u.is_turret = true
	u.is_nexus = is_nexus_flag
	u.position = Vector3(tx, 0.0, tz)
	u.unit_radius = 2.6 if is_nexus_flag else 1.7
	u.health.setup(6500.0 if is_nexus_flag else 3400.0, 0.0, 35.0)
	u.atk = 210.0 if is_nexus_flag else 165.0
	u.attack_range = 9.0

	var col_hex: String = "#3b82f6" if team_str == "blue" else "#ef4444"
	var base := MeshInstance3D.new()
	var bcm := CylinderMesh.new()
	bcm.top_radius = 2.8 if is_nexus_flag else 1.6
	bcm.bottom_radius = 3.2 if is_nexus_flag else 2.0
	bcm.height = 0.8
	base.mesh = bcm
	base.material_override = RobloxHeroBuilder.make_mat("#334155", 0.6, 0.2)
	base.position.y = 0.4
	u.add_child(base)

	var pillar_mat := RobloxHeroBuilder.make_mat("#cbd5e1", 0.5, 0.1)
	var turret_tex: String = "res://assets/textures/turrets/turret_%s_tex.png" % team_str
	if ResourceLoader.exists(turret_tex):
		pillar_mat.albedo_texture = load(turret_tex) as Texture2D

	var pillar := RobloxHeroBuilder.make_box(
		Vector3(2.2 if is_nexus_flag else 1.3, 4.2 if is_nexus_flag else 3.2, 2.2 if is_nexus_flag else 1.3),
		pillar_mat,
		Vector3(0.0, 2.4 if is_nexus_flag else 1.9, 0.0)
	)
	u.add_child(pillar)

	var crystal := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.15 if is_nexus_flag else 0.75
	sm.height = sm.radius * 2.0
	crystal.mesh = sm
	crystal.material_override = RobloxHeroBuilder.make_mat(col_hex, 0.2, 0.4, 0.9)
	crystal.position.y = 5.2 if is_nexus_flag else 4.1
	u.add_child(crystal)
	u.crystal_mesh = crystal

	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 8.3
	tm.outer_radius = 8.48
	ring.mesh = tm
	var r_mat := RobloxHeroBuilder.make_mat(col_hex, 0.3, 0.1, 0.4)
	r_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	r_mat.albedo_color.a = 0.24
	ring.material_override = r_mat
	ring.position.y = 0.06
	u.add_child(ring)

	arena_root.add_child(u)
	turret_units.append(u)

func _spawn_jungle_creep(x: float, z: float, monster_id: String, c_name: String, col_hex: String, scale_f: float) -> void:
	var u := CombatUnit.new()
	u.unit_id = "creep_%s_%d" % [monster_id, creep_units.size()]
	u.unit_name = c_name
	u.team = "neutral"
	u.is_creep = true
	u.home_pos = Vector3(x, 0.0, z)
	u.position = u.home_pos
	u.unit_radius = 1.15 * scale_f
	u.health.setup(roundf(1450.0 * scale_f), 0.0, 12.0)
	u.atk = roundf(75.0 * scale_f)
	u.move_speed = 3.4
	u.attack_range = 2.6
	u.level = 4

	u.add_child(RobloxHeroBuilder.build_monster_rig(monster_id, col_hex, scale_f))
	arena_root.add_child(u)
	creep_units.append(u)

func start_match() -> void:
	mode = "BATTLE"
	running = true
	match_time = 38.0
	blue_kills = 0
	red_kills = 1
	first_blood_taken = false

	lobby_root.visible = false
	arena_root.visible = true
	lobby_camera.current = false
	battle_camera.current = true

	build_arena_map()

	var blue_spawns: Array[Vector3] = [
		Vector3(-6.5, 0.0, 6.5),
		Vector3(-9.5, 0.0, 8.0),
		Vector3(-11.0, 0.0, 15.0),
		Vector3(-18.0, 0.0, 8.0),
		Vector3(-8.0, 0.0, 18.0)
	]
	for idx: int in range(GameDatabase.blue_roster.size()):
		var slot: Dictionary = GameDatabase.blue_roster[idx]
		var is_p: bool = (idx == 0)
		var pos: Vector3 = blue_spawns[idx] if idx < blue_spawns.size() else Vector3(-24.0, 0.0, 24.0)
		var hero_d: HeroData = slot["hero"]
		var u := _create_hero_unit(
			hero_d,
			"blue",
			String(slot["player_name"]),
			pos,
			is_p,
			GameDatabase.selected_skin if is_p else {},
			GameDatabase.selected_build if is_p else null
		)
		if is_p:
			player_unit = u
		hero_units.append(u)

	var red_spawns: Array[Vector3] = [
		Vector3(-0.5, 0.0, -0.5),
		Vector3(6.5, 0.0, -5.5),
		Vector3(12.0, 0.0, -11.0),
		Vector3(17.0, 0.0, -7.0),
		Vector3(7.0, 0.0, -17.0)
	]
	for idx: int in range(GameDatabase.red_roster.size()):
		var slot: Dictionary = GameDatabase.red_roster[idx]
		var pos: Vector3 = red_spawns[idx] if idx < red_spawns.size() else Vector3(24.0, 0.0, -24.0)
		var hero_d: HeroData = slot["hero"]
		var u := _create_hero_unit(hero_d, "red", String(slot["player_name"]), pos, false, {}, null)
		if idx == 0:
			u.health.current_hp = roundf(u.health.max_hp * 0.42)
		hero_units.append(u)

	spawn_minion_wave()
	AudioSynthesizer.start_bgm("BATTLE")
	AudioSynthesizer.announce("Welcome to Mobile Blox Legends! Five seconds till the enemy reaches the battlefield. Smash them!")

func _create_hero_unit(
	hero_d: HeroData,
	team_str: String,
	p_name: String,
	pos: Vector3,
	is_p: bool,
	skin_ovr: Dictionary,
	build_d: BuildData
) -> CombatUnit:
	var u := CombatUnit.new()
	u.unit_id = "%s_%s_%d" % [team_str, hero_d.id, randi() % 9999]
	u.unit_name = p_name
	u.team = team_str
	u.is_hero = true
	u.is_player = is_p
	u.hero_data = hero_d
	u.position = pos
	u.rotation.y = PI * 0.75 if team_str == "blue" else -PI * 0.25
	u.level = 3
	u.gold = 850
	u.deaths = 1 if is_p else 0

	var b_atk: float = build_d.bonus_atk if build_d else 20.0
	var b_crit: float = build_d.bonus_crit if build_d else 0.15
	var b_aspd: float = build_d.bonus_atk_spd if build_d else 0.2
	var b_hp: float = build_d.bonus_hp if build_d else 200.0
	var b_spd: float = build_d.bonus_spd if build_d else 0.3

	u.health.setup(hero_d.max_hp + b_hp, hero_d.max_mana, hero_d.base_def)
	u.atk = hero_d.base_atk + b_atk
	u.move_speed = hero_d.move_speed + b_spd
	u.attack_range = hero_d.attack_range
	u.attack_speed = hero_d.attack_speed + b_aspd
	u.crit_chance = b_crit
	u.skills_comp.setup_from_hero(hero_d, build_d.spell_cd if build_d else 30.0)
	u.orbit_timer = 8.0 if hero_d.id == "sabro" else 0.0

	var rig := RobloxHeroBuilder.build_hero_rig(hero_d, skin_ovr)
	u.add_child(rig)
	u.rig = rig

	var ring_col: String = "#facc15" if is_p else ("#38bdf8" if team_str == "blue" else "#ef4444")
	var foot_ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.95
	tm.outer_radius = 1.15
	foot_ring.mesh = tm
	foot_ring.material_override = RobloxHeroBuilder.make_mat(ring_col, 0.2, 0.1, 0.6)
	foot_ring.position.y = 0.05
	u.add_child(foot_ring)

	var aura_ring := MeshInstance3D.new()
	var atm := TorusMesh.new()
	atm.inner_radius = 1.48
	atm.outer_radius = 1.62
	aura_ring.mesh = atm
	aura_ring.material_override = RobloxHeroBuilder.make_mat("#facc15", 0.2, 0.3, 0.8)
	aura_ring.position.y = 1.25
	aura_ring.visible = (u.orbit_timer > 0.0)
	u.add_child(aura_ring)
	u.aura_ring_mesh = aura_ring

	arena_root.add_child(u)
	return u

func spawn_minion_wave() -> void:
	for i: int in range(3):
		_create_minion("blue", -14.0 - float(i) * 1.8, 14.0 + float(i) * 1.8, i)
		_create_minion("red", 14.0 + float(i) * 1.8, -14.0 - float(i) * 1.8, i)

func _create_minion(team_str: String, x: float, z: float, idx: int) -> void:
	var u := CombatUnit.new()
	var role_names: Array[String] = ["Knight Minion", "Mage Minion", "Siege Cannon"]
	u.unit_id = "minion_%s_%d_%d" % [team_str, Time.get_ticks_msec(), idx]
	u.unit_name = "%s %s" % [team_str.capitalize(), role_names[idx % 3]]
	u.team = team_str
	u.is_minion = true
	u.position = Vector3(x, 0.0, z)
	u.unit_radius = 0.75 if idx == 2 else 0.6
	u.health.setup(820.0 if idx == 2 else 620.0, 0.0, 8.0 if idx == 2 else 6.0)
	u.atk = 58.0 if idx == 2 else 46.0
	u.move_speed = 4.1
	u.attack_range = 6.5 if idx >= 1 else 2.3

	u.add_child(RobloxHeroBuilder.build_minion_rig(team_str, idx % 3))
	arena_root.add_child(u)
	minion_units.append(u)

func get_valid_targets(source: CombatUnit, max_range: float = 999.0) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var all_groups: Array = [hero_units, minion_units, creep_units, turret_units]
	for grp: Array in all_groups:
		for t: CombatUnit in grp:
			if t == null or not is_instance_valid(t) or t.is_dead() or t.team == source.team:
				continue
			var d: float = Vector2(t.position.x - source.position.x, t.position.z - source.position.z).length()
			if d <= max_range:
				list.append({"target": t, "dist": d})

	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_hero: int = 0 if (a["target"] as CombatUnit).is_hero else 1
		var b_hero: int = 0 if (b["target"] as CombatUnit).is_hero else 1
		if a_hero != b_hero:
			return a_hero < b_hero
		return float(a["dist"]) < float(b["dist"])
	)
	return list

func trigger_basic_attack(u: CombatUnit) -> void:
	if u == null or u.is_dead() or u.stun_timer > 0.0 or u.atk_cd > 0.0:
		return
	u.atk_cd = 1.0 / maxf(0.2, u.attack_speed)
	u.recall_timer = 0.0

	var candidates: Array[Dictionary] = get_valid_targets(u, u.attack_range + 0.8)
	var aim_angle: float = u.rotation.y
	var primary: CombatUnit = candidates[0]["target"] if candidates.size() > 0 else null
	if primary != null:
		aim_angle = atan2(primary.position.x - u.position.x, primary.position.z - u.position.z)
		u.rotation.y = aim_angle

	if u.rig != null:
		u.rig.animate_character(0.016, false, true)

	var aura_col: String = u.hero_data.aura_color if u.hero_data else "#38bdf8"
	if u.attack_range > 4.5:
		if u.is_player:
			AudioSynthesizer.shoot()
		_spawn_projectile({
			"owner": u,
			"x": u.position.x + sin(aim_angle) * 0.8,
			"z": u.position.z + cos(aim_angle) * 0.8,
			"vx": sin(aim_angle) * 26.0,
			"vz": cos(aim_angle) * 26.0,
			"color": aura_col,
			"radius": 0.32,
			"max_dist": u.attack_range + 1.5,
			"dmg": u.atk,
			"stun": 0.0,
			"aoe_radius": 0.0
		})
	else:
		if u.is_player:
			AudioSynthesizer.slash()
		_spawn_ring_explosion(u.position.x + sin(aim_angle) * 1.4, u.position.z + cos(aim_angle) * 1.4, 2.2, aura_col)
		for c: Dictionary in candidates:
			if float(c["dist"]) <= u.attack_range + 1.1:
				apply_damage(u, c["target"] as CombatUnit, u.atk, false)

func trigger_skill(u: CombatUnit, slot_idx: int) -> void:
	if u == null or u.is_dead() or u.stun_timer > 0.0 or u.hero_data == null:
		return
	var slot_key: String = str(slot_idx)
	if not u.skills_comp.is_ready(slot_key):
		return
	if slot_idx >= u.hero_data.skills.size():
		return
	var sk: SkillData = u.hero_data.skills[slot_idx]
	if not u.health.spend_mana(sk.mana_cost):
		return

	u.skills_comp.start_cooldown(slot_key, sk.cooldown)
	u.recall_timer = 0.0

	var candidates: Array[Dictionary] = get_valid_targets(u, sk.cast_range + 2.5)
	var aim_angle: float = u.rotation.y
	var primary: CombatUnit = candidates[0]["target"] if candidates.size() > 0 else null
	if primary != null:
		aim_angle = atan2(primary.position.x - u.position.x, primary.position.z - u.position.z)
		u.rotation.y = aim_angle

	if u.rig != null:
		u.rig.trigger_skill_pose(slot_idx, 0.55)

	var total_dmg: float = sk.base_damage + u.atk * sk.atk_ratio
	if u.is_player:
		if slot_idx == 1:
			AudioSynthesizer.skill1()
		elif slot_idx == 2:
			AudioSynthesizer.skill2()
		else:
			AudioSynthesizer.ultimate()
			trigger_screen_shake(0.48, 0.38)

	_execute_unique_hero_skill(u, slot_idx, sk, aim_angle, primary, total_dmg)

func trigger_battle_action(u: CombatUnit, action_type: String) -> void:
	if u == null or u.is_dead():
		return
	if not u.skills_comp.is_ready(action_type):
		return

	if action_type == "recall":
		u.skills_comp.start_cooldown("recall", 8.0)
		u.recall_timer = 3.0
		_spawn_ring_explosion(u.position.x, u.position.z, 2.2, "#38bdf8")
		floating_text_spawned.emit(u.position + Vector3(0.0, 2.8, 0.0), "RECALLING...", "#38bdf8")
	elif action_type == "regen":
		u.skills_comp.start_cooldown("regen", 12.0)
		u.regen_timer = 4.0
		if u.is_player:
			AudioSynthesizer.confirm()
		_spawn_ring_explosion(u.position.x, u.position.z, 2.0, "#4ade80")
	elif action_type == "spell":
		u.skills_comp.start_cooldown("spell")
		var blink_dist: float = 6.2
		_spawn_ring_explosion(u.position.x, u.position.z, 1.8, "#38bdf8")
		u.position.x = _clamp_map(u.position.x + sin(u.rotation.y) * blink_dist)
		u.position.z = _clamp_map(u.position.z + cos(u.rotation.y) * blink_dist)
		_spawn_ring_explosion(u.position.x, u.position.z, 2.2, "#38bdf8")
		if u.is_player:
			AudioSynthesizer.skill1()
		floating_text_spawned.emit(u.position + Vector3(0.0, 2.8, 0.0), "FLICKER!", "#38bdf8")

func heal_unit(u: CombatUnit, amount: int) -> void:
	if u == null or u.is_dead():
		return
	u.health.heal(amount)
	floating_text_spawned.emit(u.position + Vector3(0.0, 2.6, 0.0), "+%d" % amount, "#4ade80")

func apply_damage(attacker: CombatUnit, target: CombatUnit, raw_dmg: float, is_skill: bool) -> void:
	if target == null or target.is_dead():
		return
	var scaled_dmg: float = raw_dmg
	if attacker != null and attacker.hero_data != null and attacker.hero_data.id == "laylul":
		var dist: float = attacker.position.distance_to(target.position)
		scaled_dmg *= (1.0 + minf(0.3, dist * 0.025))

	var is_crit: bool = (not is_skill) and attacker != null and randf() < attacker.crit_chance
	var dealt: int = target.health.take_damage(attacker, scaled_dmg, is_crit)
	if target.is_hero:
		target.recall_timer = 0.0

	if attacker != null and attacker.is_player:
		AudioSynthesizer.hit()
		_spawn_ring_explosion(target.position.x, target.position.z, 0.85, "#facc15" if is_crit else "#38bdf8")

	if (attacker != null and attacker.is_player) or target.is_player or target.is_hero:
		var prefix: String = "CRIT " if is_crit else ""
		floating_text_spawned.emit(
			target.position + Vector3(0.0, 2.5, 0.0),
			"%s%d" % [prefix, dealt],
			"#facc15" if is_crit else "#ef4444"
		)

	if target.is_dead():
		_handle_death(attacker, target)

func _handle_death(killer: CombatUnit, victim: CombatUnit) -> void:
	victim.visible = false
	_spawn_ring_explosion(victim.position.x, victim.position.z, 2.8, "#facc15")

	if victim.is_hero:
		victim.deaths += 1
		victim.kill_streak = 0
		victim.respawn_timer = 7.0 + float(victim.level)
		if victim.team == "red":
			blue_kills += 1
		elif victim.team == "blue":
			red_kills += 1

		var callout: String = ""
		if killer != null and killer.is_hero:
			killer.kills += 1
			killer.kill_streak += 1
			if killer.multi_kill_timer > 0.0:
				killer.multi_kill_count += 1
			else:
				killer.multi_kill_count = 1
			killer.multi_kill_timer = 12.0

			_grant_gold_and_xp(killer, victim, 203, 130)

			if not first_blood_taken:
				first_blood_taken = true
				callout = "First Blood!"
			elif killer.multi_kill_count == 2:
				callout = "Double Kill!"
			elif killer.multi_kill_count == 3:
				callout = "Triple Kill!"
			elif killer.multi_kill_count == 4:
				callout = "Maniac!"
			elif killer.multi_kill_count >= 5:
				callout = "Savage!"
			elif killer.kill_streak == 3:
				callout = "Killing Spree!"
			elif killer.kill_streak == 4:
				callout = "Mega Kill!"
			elif killer.kill_streak == 5:
				callout = "Unstoppable!"
			elif killer.kill_streak >= 6:
				callout = "Legendary!"
			elif killer.team == "blue":
				callout = "You have slain an enemy!"
			else:
				callout = "An ally has been slain!"
		else:
			callout = "An enemy has been slain!" if victim.team == "red" else "Executed!"

		var all_enemy_dead: bool = true
		for e: CombatUnit in hero_units:
			if e.team == victim.team and not e.is_dead():
				all_enemy_dead = false
				break
		if all_enemy_dead and victim.team == "red":
			callout = "Wipe Out!"

		for ally: CombatUnit in hero_units:
			if not ally.is_dead() and ally != killer and ally.team != victim.team:
				if ally.position.distance_to(victim.position) <= 14.0:
					ally.assists += 1
					_grant_gold_and_xp(ally, victim, 85, 65)

		hero_killed.emit(killer, victim, callout)
		AudioSynthesizer.kill_fanfare()
		trigger_screen_shake(0.5, 0.35)
		if callout != "":
			AudioSynthesizer.announce(callout)
	elif victim.is_creep or victim.is_minion:
		var g_rew: int = 363 if victim.is_creep else 58
		var x_rew: int = 125 if victim.is_creep else 48
		if victim.is_creep:
			victim.respawn_timer = 18.0
		if killer != null and killer.is_hero:
			_grant_gold_and_xp(killer, victim, g_rew, x_rew)
	elif victim.is_turret:
		if killer != null and killer.is_hero:
			_grant_gold_and_xp(killer, victim, 320, 180)
		AudioSynthesizer.announce("Your team destroyed a turret!" if victim.team == "red" else "Our turret has been destroyed!")
		if victim.is_nexus:
			var res: String = "VICTORY" if victim.team == "red" else "DEFEAT"
			AudioSynthesizer.announce("Victory!" if res == "VICTORY" else "Defeat!")
			running = false
			match_ended.emit(res)

func _grant_gold_and_xp(hero_u: CombatUnit, source_target: CombatUnit, gold_amt: int, xp_amt: int) -> void:
	hero_u.gold += gold_amt
	hero_u.xp += xp_amt
	if hero_u.is_player:
		AudioSynthesizer.gold()
		var p_pos: Vector3 = source_target.position if source_target != null else hero_u.position
		gold_popup_spawned.emit(p_pos + Vector3(0.0, 2.2, 0.0), gold_amt)

	var needed_xp: int = hero_u.level * 100
	if hero_u.xp >= needed_xp and hero_u.level < 15:
		hero_u.xp -= needed_xp
		hero_u.level += 1
		hero_u.health.max_hp += 185.0
		hero_u.health.heal(320)
		hero_u.atk += 14.0
		hero_u.health.defense += 4.0
		if hero_u.is_player:
			AudioSynthesizer.level_up()
			player_level_up.emit(hero_u.level)

func _spawn_projectile(opts: Dictionary) -> void:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	var r: float = float(opts.get("radius", 0.3))
	sm.radius = r
	sm.height = r * 2.0
	mi.mesh = sm
	mi.material_override = RobloxHeroBuilder.make_mat(String(opts.get("color", "#38bdf8")), 0.2, 0.2, 0.9)
	mi.position = Vector3(float(opts["x"]), 1.35, float(opts["z"]))
	arena_root.add_child(mi)
	var entry: Dictionary = opts.duplicate()
	entry["mesh"] = mi
	entry["traveled"] = 0.0
	projectiles.append(entry)

func _spawn_laser_beam(x: float, z: float, angle: float, length: float, col_hex: String, duration: float = 0.45) -> void:
	var g := Node3D.new()
	g.position = Vector3(x, 1.35, z)
	g.rotation.y = angle
	var core := RobloxHeroBuilder.make_box(Vector3(0.55, 0.55, length), RobloxHeroBuilder.make_mat("#ffffff", 0.1, 0.1, 1.4), Vector3(0.0, 0.0, length * 0.5))
	var glow_mat := RobloxHeroBuilder.make_mat(col_hex, 0.2, 0.1, 1.0)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.65
	var glow := RobloxHeroBuilder.make_box(Vector3(1.3, 1.3, length), glow_mat, Vector3(0.0, 0.0, length * 0.5))
	g.add_child(core)
	g.add_child(glow)
	arena_root.add_child(g)
	vfx_list.append({"node": g, "timer": duration, "max_timer": duration, "type": "laser"})

func _execute_unique_hero_skill(u: CombatUnit, slot_idx: int, sk: SkillData, aim_angle: float, primary: CombatUnit, total_dmg: float) -> void:
	var hid: String = u.hero_data.id if u.hero_data else "laylul"
	var key: String = "%s_%d" % [hid, slot_idx]
	floating_text_spawned.emit(u.position + Vector3(0.0, 3.2, 0.0), sk.name.to_upper() + "!", sk.color_hex)

	match key:
		# 1. LAYLUL (Void Marksman)
		"laylul_1":
			u.speed_buff_timer = 3.5
			_spawn_projectile({
				"owner": u, "x": u.position.x + sin(aim_angle) * 0.9, "z": u.position.z + cos(aim_angle) * 0.9,
				"vx": sin(aim_angle) * 29.0, "vz": cos(aim_angle) * 29.0,
				"color": "#facc15", "radius": 0.48, "max_dist": 12.0, "dmg": total_dmg, "stun": 0.0, "aoe_radius": 2.1
			})
		"laylul_2":
			_spawn_projectile({
				"owner": u, "x": u.position.x + sin(aim_angle) * 0.9, "z": u.position.z + cos(aim_angle) * 0.9,
				"vx": sin(aim_angle) * 21.0, "vz": cos(aim_angle) * 21.0,
				"color": "#a855f7", "radius": 0.65, "max_dist": 10.0, "dmg": total_dmg, "stun": 1.3, "aoe_radius": 3.4
			})
		"laylul_3":
			var length: float = 19.0
			_spawn_laser_beam(u.position.x, u.position.z, aim_angle, length, "#22d3ee", 0.55)
			for item: Dictionary in get_valid_targets(u, length + 1.5):
				var t: CombatUnit = item["target"]
				var to_x: float = t.position.x - u.position.x
				var to_z: float = t.position.z - u.position.z
				var forward: float = to_x * sin(aim_angle) + to_z * cos(aim_angle)
				var perp: float = absf(to_x * cos(aim_angle) - to_z * sin(aim_angle))
				if forward > -0.5 and forward <= length + 1.0 and perp <= 2.6:
					apply_damage(u, t, total_dmg, true)

		# 2. SABRO (Wandering Sword)
		"sabro_1":
			u.orbit_timer = 5.0
			_spawn_ring_explosion(u.position.x, u.position.z, 5.2, "#38bdf8")
			for item: Dictionary in get_valid_targets(u, 5.5):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"sabro_2":
			var sx: float = u.position.x
			var sz: float = u.position.z
			u.position.x = _clamp_map(sx + sin(aim_angle) * 6.0)
			u.position.z = _clamp_map(sz + cos(aim_angle) * 6.0)
			_spawn_laser_beam(sx, sz, aim_angle, 6.0, "#60a5fa", 0.28)
			for item: Dictionary in get_valid_targets(u, 3.8):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"sabro_3":
			if primary != null:
				u.position.x = _clamp_map(primary.position.x - sin(aim_angle) * 1.2)
				u.position.z = _clamp_map(primary.position.z - cos(aim_angle) * 1.2)
				primary.stun_timer = 1.6
				_spawn_pillar_vfx(primary.position.x, primary.position.z, 1.8, 5.5, "#ef4444", 0.55)
				_spawn_ring_explosion(primary.position.x, primary.position.z, 4.2, "#ef4444")
				apply_damage(u, primary, total_dmg, true)
				floating_text_spawned.emit(primary.position + Vector3(0.0, 3.2, 0.0), "AIRBORNE x3!", "#ef4444")
			else:
				_spawn_ring_explosion(u.position.x, u.position.z, 5.0, "#ef4444")

		# 3. YU ZONG (Black Dragon)
		"yuzong_1":
			_spawn_ring_explosion(u.position.x, u.position.z, 5.6, "#e11d48")
			_spawn_ring_explosion(u.position.x, u.position.z, 3.2, "#fb7185")
			for item: Dictionary in get_valid_targets(u, 5.6):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
			heal_unit(u, roundi(total_dmg * 0.42))
		"yuzong_2":
			var jd: float = minf(7.0, u.position.distance_to(primary.position) if primary else 5.5)
			u.position.x = _clamp_map(u.position.x + sin(aim_angle) * jd)
			u.position.z = _clamp_map(u.position.z + cos(aim_angle) * jd)
			_spawn_pillar_vfx(u.position.x, u.position.z, 2.4, 3.5, "#be123c", 0.42)
			for item: Dictionary in get_valid_targets(u, 4.5):
				var t: CombatUnit = item["target"]
				t.stun_timer = 1.1
				apply_damage(u, t, total_dmg, true)
		"yuzong_3":
			u.speed_buff_timer = 6.0
			heal_unit(u, 550)
			_spawn_pillar_vfx(u.position.x, u.position.z, 3.5, 6.0, "#f43f5e", 0.65)
			_spawn_ring_explosion(u.position.x, u.position.z, 7.5, "#e11d48")
			for item: Dictionary in get_valid_targets(u, 7.5):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)

		# 4. KAJEE (Nazar King)
		"kajee_1":
			_spawn_ring_explosion(u.position.x, u.position.z, 6.8, "#facc15")
			_spawn_ring_explosion(u.position.x, u.position.z, 4.2, "#fde047")
			for item: Dictionary in get_valid_targets(u, 6.8):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
			heal_unit(u, 260)
		"kajee_2":
			var sx: float = u.position.x
			var sz: float = u.position.z
			for bi: int in range(1, 4):
				var bx: float = sx + sin(aim_angle) * float(bi) * 1.8
				var bz: float = sz + cos(aim_angle) * float(bi) * 1.8
				_spawn_pillar_vfx(bx, bz, 0.95, 2.4, "#fde047", 0.5)
			u.position.x = _clamp_map(sx + sin(aim_angle) * 5.8)
			u.position.z = _clamp_map(sz + cos(aim_angle) * 5.8)
			for item: Dictionary in get_valid_targets(u, 4.8):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"kajee_3":
			if primary != null:
				var dist_t: float = u.position.distance_to(primary.position)
				var ang_t: float = atan2(primary.position.x - u.position.x, primary.position.z - u.position.z)
				_spawn_laser_beam(u.position.x, u.position.z, ang_t, dist_t, "#eab308", 0.6)
				primary.position.x = _clamp_map(lerpf(primary.position.x, u.position.x, 0.55))
				primary.position.z = _clamp_map(lerpf(primary.position.z, u.position.z, 0.55))
				primary.stun_timer = 1.7
				apply_damage(u, primary, total_dmg, true)
				floating_text_spawned.emit(primary.position + Vector3(0.0, 3.0, 0.0), "SUPPRESSED!", "#facc15")
			else:
				_spawn_ring_explosion(u.position.x, u.position.z, 5.5, "#eab308")

		# 5. YEEN (Martial Genius)
		"yeen_1":
			u.speed_buff_timer = 2.8
			u.position.x = _clamp_map(u.position.x + sin(aim_angle) * 3.8)
			u.position.z = _clamp_map(u.position.z + cos(aim_angle) * 3.8)
			_spawn_ring_explosion(u.position.x, u.position.z, 3.8, "#f97316")
			for item: Dictionary in get_valid_targets(u, 4.2):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"yeen_2":
			var sx: float = u.position.x
			var sz: float = u.position.z
			u.position.x = _clamp_map(sx + sin(aim_angle) * 5.5)
			u.position.z = _clamp_map(sz + cos(aim_angle) * 5.5)
			_spawn_ring_explosion(sx, sz, 2.8, "#fbbf24")
			_spawn_ring_explosion(u.position.x, u.position.z, 3.6, "#fbbf24")
			for item: Dictionary in get_valid_targets(u, 4.2):
				var t: CombatUnit = item["target"]
				t.stun_timer = 1.1
				apply_damage(u, t, total_dmg, true)
		"yeen_3":
			var center_p: Vector3 = primary.position if primary != null else u.position
			_spawn_pillar_vfx(center_p.x, center_p.z, 6.2, 2.8, "#dc2626", 1.1)
			_spawn_ring_explosion(center_p.x, center_p.z, 6.5, "#f97316")
			for item: Dictionary in get_valid_targets(u, 6.8):
				var t: CombatUnit = item["target"]
				t.stun_timer = 1.4
				apply_damage(u, t, total_dmg, true)

		# 6. KIMEE (Jetpack Alchemist)
		"kimee_1":
			for ang_off: float in [-0.20, 0.0, 0.20]:
				var a: float = aim_angle + ang_off
				_spawn_projectile({
					"owner": u, "x": u.position.x + sin(a) * 0.9, "z": u.position.z + cos(a) * 0.9,
					"vx": sin(a) * 25.0, "vz": cos(a) * 25.0,
					"color": "#ec4899", "radius": 0.38, "max_dist": 10.5, "dmg": total_dmg * 0.45, "stun": 0.0, "aoe_radius": 1.6
				})
		"kimee_2":
			var sx: float = u.position.x
			var sz: float = u.position.z
			_spawn_pillar_vfx(sx, sz, 3.2, 0.4, "#4ade80", 0.9)
			u.position.x = _clamp_map(sx - sin(aim_angle) * 5.2)
			u.position.z = _clamp_map(sz - cos(aim_angle) * 5.2)
			for item: Dictionary in get_valid_targets(u, 6.0):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"kimee_3":
			_spawn_projectile({
				"owner": u, "x": u.position.x + sin(aim_angle) * 1.1, "z": u.position.z + cos(aim_angle) * 1.1,
				"vx": sin(aim_angle) * 24.0, "vz": cos(aim_angle) * 24.0,
				"color": "#f43f5e", "radius": 0.85, "max_dist": 16.0, "dmg": total_dmg, "stun": 0.8, "aoe_radius": 4.8
			})

		# 7. MINOTOR (Son of Minos)
		"minotor_1":
			var jd: float = minf(6.5, u.position.distance_to(primary.position) if primary else 5.0)
			u.position.x = _clamp_map(u.position.x + sin(aim_angle) * jd)
			u.position.z = _clamp_map(u.position.z + cos(aim_angle) * jd)
			_spawn_ring_explosion(u.position.x, u.position.z, 4.8, "#f97316")
			for item: Dictionary in get_valid_targets(u, 4.8):
				var t: CombatUnit = item["target"]
				t.stun_timer = 0.9
				apply_damage(u, t, total_dmg, true)
		"minotor_2":
			_spawn_pillar_vfx(u.position.x, u.position.z, 4.5, 2.5, "#4ade80", 0.55)
			for ally: CombatUnit in hero_units:
				if not ally.is_dead() and ally.team == u.team and ally.position.distance_to(u.position) <= 7.5:
					heal_unit(ally, roundi(total_dmg))
		"minotor_3":
			trigger_screen_shake(0.65, 0.5)
			for r_rad: float in [3.2, 5.4, 7.6]:
				_spawn_ring_explosion(u.position.x, u.position.z, r_rad, "#ea580c")
			_spawn_pillar_vfx(u.position.x, u.position.z, 3.8, 4.0, "#f97316", 0.6)
			for item: Dictionary in get_valid_targets(u, 7.6):
				var t: CombatUnit = item["target"]
				t.stun_timer = 1.6
				apply_damage(u, t, total_dmg, true)
				floating_text_spawned.emit(t.position + Vector3(0.0, 3.0, 0.0), "MEGA QUAKE!", "#fb923c")

		# 8. ESTEEZ (Moonlight King)
		"esteez_1":
			var lowest_ally: CombatUnit = u
			for ally: CombatUnit in hero_units:
				if not ally.is_dead() and ally.team == u.team and ally.position.distance_to(u.position) <= 9.0:
					if ally.health.current_hp < lowest_ally.health.current_hp:
						lowest_ally = ally
			heal_unit(u, roundi(total_dmg * 0.7))
			heal_unit(lowest_ally, roundi(total_dmg))
			if lowest_ally != u:
				var ang_a: float = atan2(lowest_ally.position.x - u.position.x, lowest_ally.position.z - u.position.z)
				_spawn_laser_beam(u.position.x, u.position.z, ang_a, u.position.distance_to(lowest_ally.position), "#4ade80", 0.55)
		"esteez_2":
			var tp: Vector3 = primary.position if primary != null else (u.position + Vector3(sin(aim_angle) * 6.0, 0.0, cos(aim_angle) * 6.0))
			_spawn_pillar_vfx(tp.x, tp.z, 3.8, 3.0, "#38bdf8", 0.65)
			_spawn_ring_explosion(tp.x, tp.z, 4.2, "#38bdf8")
			for item: Dictionary in get_valid_targets(u, 11.0):
				var t: CombatUnit = item["target"]
				if t.position.distance_to(tp) <= 4.2:
					t.stun_timer = 0.8
					apply_damage(u, t, total_dmg, true)
		"esteez_3":
			_spawn_pillar_vfx(u.position.x, u.position.z, 7.5, 3.5, "#22c55e", 0.85)
			for ally: CombatUnit in hero_units:
				if not ally.is_dead() and ally.team == u.team and ally.position.distance_to(u.position) <= 9.5:
					heal_unit(ally, roundi(total_dmg * 1.15))
					_spawn_ring_explosion(ally.position.x, ally.position.z, 2.5, "#4ade80")

		# 9. MASTER YEE (Wuju Blademaster)
		"masteryee_1":
			var targets: Array[Dictionary] = get_valid_targets(u, 7.5)
			var limit: int = mini(4, targets.size())
			for idx: int in range(limit):
				var t: CombatUnit = targets[idx]["target"]
				var ang_t: float = atan2(t.position.x - u.position.x, t.position.z - u.position.z)
				_spawn_laser_beam(u.position.x, u.position.z, ang_t, u.position.distance_to(t.position), "#84cc16", 0.25)
				apply_damage(u, t, total_dmg, true)
			if limit > 0:
				var last_t: CombatUnit = targets[limit - 1]["target"]
				u.position.x = _clamp_map(last_t.position.x - sin(aim_angle) * 1.2)
				u.position.z = _clamp_map(last_t.position.z - cos(aim_angle) * 1.2)
		"masteryee_2":
			u.regen_timer = 3.0
			heal_unit(u, roundi(total_dmg))
			_spawn_pillar_vfx(u.position.x, u.position.z, 2.2, 4.2, "#a3e635", 0.65)
		"masteryee_3":
			u.speed_buff_timer = 6.0
			var sx: float = u.position.x
			var sz: float = u.position.z
			u.position.x = _clamp_map(sx + sin(aim_angle) * 6.5)
			u.position.z = _clamp_map(sz + cos(aim_angle) * 6.5)
			_spawn_laser_beam(sx, sz, aim_angle, 6.5, "#65a30d", 0.35)
			for item: Dictionary in get_valid_targets(u, 5.5):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)

		# 10. KETOOTOO (Arcane Trickster)
		"ketootoo_1":
			for side: float in [-0.35, 0.35]:
				var ox: float = u.position.x + cos(aim_angle) * side
				var oz: float = u.position.z - sin(aim_angle) * side
				_spawn_projectile({
					"owner": u, "x": ox, "z": oz,
					"vx": sin(aim_angle) * 30.0, "vz": cos(aim_angle) * 30.0,
					"color": "#38bdf8", "radius": 0.35, "max_dist": 11.5, "dmg": total_dmg * 0.65, "stun": 0.0, "aoe_radius": 1.4
				})
		"ketootoo_2":
			u.position.x = _clamp_map(u.position.x + cos(aim_angle) * 4.2)
			u.position.z = _clamp_map(u.position.z - sin(aim_angle) * 4.2)
			_spawn_projectile({
				"owner": u, "x": u.position.x, "z": u.position.z,
				"vx": sin(aim_angle) * 24.0, "vz": cos(aim_angle) * 24.0,
				"color": "#60a5fa", "radius": 0.52, "max_dist": 9.0, "dmg": total_dmg, "stun": 1.0, "aoe_radius": 2.2
			})
		"ketootoo_3":
			for ang_off: float in [-0.36, -0.18, 0.0, 0.18, 0.36]:
				var a: float = aim_angle + ang_off
				_spawn_projectile({
					"owner": u, "x": u.position.x + sin(a) * 0.9, "z": u.position.z + cos(a) * 0.9,
					"vx": sin(a) * 26.0, "vz": cos(a) * 26.0,
					"color": "#3b82f6", "radius": 0.42, "max_dist": 14.0, "dmg": total_dmg * 0.38, "stun": 0.0, "aoe_radius": 1.8
				})

		# 11. ALUCARDOX (Demon Hunter)
		"alucardox_1":
			var jd: float = minf(7.0, u.position.distance_to(primary.position) if primary else 5.5)
			u.position.x = _clamp_map(u.position.x + sin(aim_angle) * jd)
			u.position.z = _clamp_map(u.position.z + cos(aim_angle) * jd)
			_spawn_pillar_vfx(u.position.x, u.position.z, 3.2, 1.5, "#3b82f6", 0.45)
			for item: Dictionary in get_valid_targets(u, 4.5):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
		"alucardox_2":
			_spawn_ring_explosion(u.position.x, u.position.z, 5.2, "#60a5fa")
			for item: Dictionary in get_valid_targets(u, 5.2):
				apply_damage(u, item["target"] as CombatUnit, total_dmg, true)
			heal_unit(u, roundi(total_dmg * 0.45))
		"alucardox_3":
			heal_unit(u, 380)
			_spawn_laser_beam(u.position.x, u.position.z, aim_angle, 13.0, "#2563eb", 0.45)
			for item: Dictionary in get_valid_targets(u, 13.0):
				var t: CombatUnit = item["target"]
				var to_x: float = t.position.x - u.position.x
				var to_z: float = t.position.z - u.position.z
				var forward: float = to_x * sin(aim_angle) + to_z * cos(aim_angle)
				var perp: float = absf(to_x * cos(aim_angle) - to_z * sin(aim_angle))
				if forward > -0.5 and forward <= 13.5 and perp <= 2.8:
					apply_damage(u, t, total_dmg, true)

		# 12. GUSIONOX (Holy Blade)
		"gusionox_1":
			if primary != null:
				var sx: float = u.position.x
				var sz: float = u.position.z
				u.position.x = _clamp_map(primary.position.x + sin(aim_angle) * 1.4)
				u.position.z = _clamp_map(primary.position.z + cos(aim_angle) * 1.4)
				_spawn_laser_beam(sx, sz, aim_angle, Vector2(primary.position.x - sx, primary.position.z - sz).length(), "#22d3ee", 0.3)
				apply_damage(u, primary, total_dmg, true)
			else:
				_spawn_projectile({
					"owner": u, "x": u.position.x, "z": u.position.z,
					"vx": sin(aim_angle) * 28.0, "vz": cos(aim_angle) * 28.0,
					"color": "#22d3ee", "radius": 0.36, "max_dist": 8.5, "dmg": total_dmg, "stun": 0.0, "aoe_radius": 1.2
				})
		"gusionox_2":
			for ang_off: float in [-0.40, -0.20, 0.0, 0.20, 0.40]:
				var a: float = aim_angle + ang_off
				_spawn_projectile({
					"owner": u, "x": u.position.x + sin(a) * 0.8, "z": u.position.z + cos(a) * 0.8,
					"vx": sin(a) * 23.0, "vz": cos(a) * 23.0,
					"color": "#38bdf8", "radius": 0.32, "max_dist": 7.5, "dmg": total_dmg * 0.35, "stun": 0.0, "aoe_radius": 1.2
				})
		"gusionox_3":
			u.skills_comp.cooldowns["1"] = 0.0
			u.skills_comp.cooldowns["2"] = 0.0
			u.position.x = _clamp_map(u.position.x + sin(aim_angle) * 4.5)
			u.position.z = _clamp_map(u.position.z + cos(aim_angle) * 4.5)
			for i: int in range(8):
				var a: float = (float(i) / 8.0) * TAU
				_spawn_projectile({
					"owner": u, "x": u.position.x + sin(a) * 0.6, "z": u.position.z + cos(a) * 0.6,
					"vx": sin(a) * 22.0, "vz": cos(a) * 22.0,
					"color": "#06b6d4", "radius": 0.32, "max_dist": 7.0, "dmg": total_dmg * 0.35, "stun": 0.0, "aoe_radius": 1.2
				})

func _spawn_pillar_vfx(x: float, z: float, radius: float, height: float, col_hex: String, duration: float = 0.5) -> void:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	mi.mesh = cm
	var mat := RobloxHeroBuilder.make_mat(col_hex, 0.2, 0.2, 1.1)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.55
	mi.material_override = mat
	mi.position = Vector3(x, height * 0.5, z)
	arena_root.add_child(mi)
	vfx_list.append({"node": mi, "timer": duration, "max_timer": duration, "type": "pillar"})

func _spawn_ring_explosion(x: float, z: float, max_r: float, col_hex: String) -> void:
	var mi := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = maxf(0.2, max_r * 0.72)
	tm.outer_radius = maxf(0.4, max_r)
	mi.mesh = tm
	var mat := RobloxHeroBuilder.make_mat(col_hex, 0.2, 0.2, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	mi.material_override = mat
	mi.position = Vector3(x, 0.14, z)
	mi.scale = Vector3(0.25, 1.0, 0.25)
	arena_root.add_child(mi)
	vfx_list.append({"node": mi, "timer": 0.36, "max_timer": 0.36, "type": "ring"})

func _clamp_map(val: float) -> float:
	return clampf(val, -41.0, 41.0)

func _resolve_unit_collisions(u: CombatUnit) -> void:
	var all_units: Array[CombatUnit] = []
	all_units.append_array(hero_units)
	all_units.append_array(minion_units)
	all_units.append_array(creep_units)
	for other: CombatUnit in all_units:
		if other == null or other == u or other.is_dead():
			continue
		var dx: float = u.position.x - other.position.x
		var dz: float = u.position.z - other.position.z
		var dist: float = sqrt(dx * dx + dz * dz)
		var min_sep: float = u.unit_radius + other.unit_radius * 0.82
		if dist < min_sep and dist > 0.001:
			var push: float = (min_sep - dist) * 0.48
			u.position.x += (dx / dist) * push
			u.position.z += (dz / dist) * push

	for obs: Dictionary in obstacles:
		var ox: float = float(obs["x"])
		var oz: float = float(obs["z"])
		var orad: float = float(obs["r"])
		var dx: float = u.position.x - ox
		var dz: float = u.position.z - oz
		var dist: float = sqrt(dx * dx + dz * dz)
		var min_dist: float = u.unit_radius + orad
		if dist < min_dist and dist > 0.001:
			var push: float = min_dist - dist
			u.position.x += (dx / dist) * push
			u.position.z += (dz / dist) * push

	u.position.x = _clamp_map(u.position.x)
	u.position.z = _clamp_map(u.position.z)

func _physics_process(delta: float) -> void:
	if mode == "LOBBY":
		if lobby_hero_rig != null and is_instance_valid(lobby_hero_rig):
			lobby_hero_rig.animate_character(delta, false, false)
		return

	if mode == "BATTLE" and running:
		_update_battle(delta)

func _update_battle(dt: float) -> void:
	match_time += dt
	minion_wave_timer -= dt
	if minion_wave_timer <= 0.0:
		minion_wave_timer = 22.0
		spawn_minion_wave()

	for u: CombatUnit in hero_units:
		if u.is_dead():
			u.respawn_timer -= dt
			if u.respawn_timer <= 0.0:
				u.health.reset_full()
				u.position = Vector3(-28.0, 0.0, 28.0) if u.team == "blue" else Vector3(28.0, 0.0, -28.0)
				u.visible = true
				_spawn_ring_explosion(u.position.x, u.position.z, 2.5, "#38bdf8")
			continue

		if u.atk_cd > 0.0:
			u.atk_cd = maxf(0.0, u.atk_cd - dt)
		if u.multi_kill_timer > 0.0:
			u.multi_kill_timer = maxf(0.0, u.multi_kill_timer - dt)
		u.skills_comp.tick_cooldowns(dt)
		if u.stun_timer > 0.0:
			u.stun_timer = maxf(0.0, u.stun_timer - dt)
		if u.speed_buff_timer > 0.0:
			u.speed_buff_timer = maxf(0.0, u.speed_buff_timer - dt)

		if u.aura_ring_mesh != null:
			u.aura_ring_mesh.visible = (u.orbit_timer > 0.0)
			u.aura_ring_mesh.rotation.y += dt * 4.5
		if u.rig != null:
			u.rig.set_orbit_swords_active(u.orbit_timer > 0.0, dt)
			u.rig.set_dragon_form_active(u.hero_data != null and u.hero_data.id == "yuzong" and u.speed_buff_timer > 1.5)

		if u.orbit_timer > 0.0:
			u.orbit_timer -= dt
			if randf() < dt * 3.5:
				for item: Dictionary in get_valid_targets(u, 4.8):
					apply_damage(u, item["target"] as CombatUnit, roundf(u.atk * 0.45), true)

		u.health.restore_mana(dt * 8.0)
		if u.regen_timer > 0.0:
			var prev_t: int = int(floor(u.regen_timer * 2.2))
			u.regen_timer = maxf(0.0, u.regen_timer - dt)
			var next_t: int = int(floor(u.regen_timer * 2.2))
			if prev_t != next_t:
				heal_unit(u, 48 + randi() % 18)
				u.health.restore_mana(30.0)

		if u.recall_timer > 0.0:
			u.recall_timer -= dt
			if u.recall_timer <= 0.0:
				u.position = Vector3(-30.0, 0.0, 30.0) if u.team == "blue" else Vector3(30.0, 0.0, -30.0)
				u.health.reset_full()
				_spawn_ring_explosion(u.position.x, u.position.z, 3.0, "#38bdf8")
				floating_text_spawned.emit(u.position + Vector3(0.0, 2.8, 0.0), "RECALLED!", "#38bdf8")

		var is_moving: bool = false
		var cur_spd: float = u.move_speed * (1.35 if u.speed_buff_timer > 0.0 else 1.0)

		if u.stun_timer <= 0.0:
			if u.is_player:
				var mx: float = joy_vec.x
				var mz: float = joy_vec.y
				if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
					mz -= 1.0
				if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
					mz += 1.0
				if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
					mx -= 1.0
				if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
					mx += 1.0

				var move_v := Vector2(mx, mz)
				if move_v.length() > 0.08:
					move_v = move_v.normalized()
					u.position.x += move_v.x * cur_spd * dt
					u.position.z += move_v.y * cur_spd * dt
					var desired_rot: float = atan2(move_v.x, move_v.y)
					u.rotation.y = lerp_angle(u.rotation.y, desired_rot, minf(1.0, dt * 18.0))
					u.recall_timer = 0.0
					is_moving = true

				if (Input.is_key_pressed(KEY_SPACE) or holding_attack) and u.atk_cd <= 0.0:
					var in_range: Array[Dictionary] = get_valid_targets(u, u.attack_range + 0.9)
					if in_range.size() > 0:
						trigger_basic_attack(u)
					elif not is_moving:
						var nearby: Array[Dictionary] = get_valid_targets(u, 14.5)
						if nearby.size() > 0:
							var t: CombatUnit = nearby[0]["target"]
							var ang: float = atan2(t.position.x - u.position.x, t.position.z - u.position.z)
							u.rotation.y = ang
							u.position.x += sin(ang) * cur_spd * dt
							u.position.z += cos(ang) * cur_spd * dt
							is_moving = true
						else:
							trigger_basic_attack(u)

				var lock_cands: Array[Dictionary] = get_valid_targets(u, u.attack_range + 3.5)
				if lock_cands.size() > 0:
					var locked: CombatUnit = lock_cands[0]["target"]
					target_lock_ring.visible = true
					target_lock_ring.position = Vector3(locked.position.x, 0.08, locked.position.z)
					target_lock_ring.rotation.y += dt * 3.5
				else:
					target_lock_ring.visible = false
			else:
				is_moving = _update_hero_ai(u, dt, cur_spd)

		_resolve_unit_collisions(u)
		u.in_bush = false
		for b: Dictionary in bushes:
			if Vector2(u.position.x - float(b["x"]), u.position.z - float(b["z"])).length() <= float(b["r"]):
				u.in_bush = true
				break

		if u.rig != null:
			u.rig.animate_character(dt, is_moving, false)

	for idx: int in range(minion_units.size() - 1, -1, -1):
		var m: CombatUnit = minion_units[idx]
		if m.is_dead():
			m.queue_free()
			minion_units.remove_at(idx)
			continue
		if m.atk_cd > 0.0:
			m.atk_cd -= dt
		var targets: Array[Dictionary] = get_valid_targets(m, 14.0)
		if targets.size() > 0:
			var t: CombatUnit = targets[0]["target"]
			var dist: float = float(targets[0]["dist"])
			var ang: float = atan2(t.position.x - m.position.x, t.position.z - m.position.z)
			m.rotation.y = ang
			if dist <= m.attack_range:
				if m.atk_cd <= 0.0:
					m.atk_cd = 1.1
					apply_damage(m, t, m.atk, false)
			else:
				m.position.x += sin(ang) * m.move_speed * dt
				m.position.z += cos(ang) * m.move_speed * dt
		else:
			var gx: float = 30.0 if m.team == "blue" else -30.0
			var gz: float = -30.0 if m.team == "blue" else 30.0
			var ang: float = atan2(gx - m.position.x, gz - m.position.z)
			m.rotation.y = ang
			m.position.x += sin(ang) * m.move_speed * dt
			m.position.z += cos(ang) * m.move_speed * dt

	for c: CombatUnit in creep_units:
		if c.is_dead():
			c.respawn_timer -= dt
			if c.respawn_timer <= 0.0:
				c.health.reset_full()
				c.position = c.home_pos
				c.visible = true
			continue
		if c.atk_cd > 0.0:
			c.atk_cd -= dt
		var nearest: CombatUnit = null
		var min_d: float = 6.5
		for h: CombatUnit in hero_units:
			if not h.is_dead():
				var d: float = h.position.distance_to(c.position)
				if d < min_d:
					min_d = d
					nearest = h
		if nearest != null and (c.health.current_hp < c.health.max_hp or min_d < 3.8):
			var ang: float = atan2(nearest.position.x - c.position.x, nearest.position.z - c.position.z)
			c.rotation.y = ang
			if min_d <= c.attack_range:
				if c.atk_cd <= 0.0:
					c.atk_cd = 1.25
					apply_damage(c, nearest, c.atk, false)
			elif c.position.distance_to(c.home_pos) < 8.0:
				c.position.x += sin(ang) * c.move_speed * dt
				c.position.z += cos(ang) * c.move_speed * dt
		else:
			c.health.current_hp = minf(c.health.max_hp, c.health.current_hp + dt * 40.0)

	for t: CombatUnit in turret_units:
		if t.is_dead():
			continue
		if t.crystal_mesh != null:
			t.crystal_mesh.rotation.y += dt * 1.8
		if t.atk_cd > 0.0:
			t.atk_cd -= dt
		var targets: Array[Dictionary] = get_valid_targets(t, t.attack_range)
		if targets.size() > 0 and t.atk_cd <= 0.0:
			t.atk_cd = 1.35
			var victim: CombatUnit = targets[0]["target"]
			var ang: float = atan2(victim.position.x - t.position.x, victim.position.z - t.position.z)
			_spawn_projectile({
				"owner": t,
				"x": t.position.x,
				"z": t.position.z,
				"vx": sin(ang) * 20.0,
				"vz": cos(ang) * 20.0,
				"color": "#3b82f6" if t.team == "blue" else "#ef4444",
				"radius": 0.42,
				"max_dist": t.attack_range + 2.0,
				"dmg": t.atk,
				"stun": 0.0,
				"aoe_radius": 0.0
			})

	for idx: int in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[idx]
		var step_x: float = float(p["vx"]) * dt
		var step_z: float = float(p["vz"]) * dt
		var px: float = float(p["x"]) + step_x
		var pz: float = float(p["z"]) + step_z
		var traveled: float = float(p["traveled"]) + sqrt(step_x * step_x + step_z * step_z)
		p["x"] = px
		p["z"] = pz
		p["traveled"] = traveled
		var mi: MeshInstance3D = p["mesh"]
		if is_instance_valid(mi):
			mi.position = Vector3(px, 1.35, pz)

		var owner_u: CombatUnit = p["owner"]
		var hit_target: CombatUnit = null
		var all_groups: Array = [hero_units, minion_units, creep_units, turret_units]
		for grp: Array in all_groups:
			if hit_target != null:
				break
			for cand: CombatUnit in grp:
				if cand == null or cand.is_dead() or (owner_u != null and cand.team == owner_u.team):
					continue
				var d: float = Vector2(cand.position.x - px, cand.position.z - pz).length()
				if d <= cand.unit_radius + float(p["radius"]):
					hit_target = cand
					break

		if hit_target != null or traveled >= float(p["max_dist"]):
			if hit_target != null:
				var stun_v: float = float(p.get("stun", 0.0))
				var aoe_r: float = float(p.get("aoe_radius", 0.0))
				apply_damage(owner_u, hit_target, float(p["dmg"]), stun_v > 0.0 or aoe_r > 0.0)
				if stun_v > 0.0 and hit_target.is_hero:
					hit_target.stun_timer = maxf(hit_target.stun_timer, stun_v)
					floating_text_spawned.emit(hit_target.position + Vector3(0.0, 2.8, 0.0), "STUNNED!", "#fde047")
				if aoe_r > 0.0:
					_spawn_ring_explosion(px, pz, aoe_r, String(p["color"]))
			if is_instance_valid(mi):
				mi.queue_free()
			projectiles.remove_at(idx)

	for idx: int in range(vfx_list.size() - 1, -1, -1):
		var v: Dictionary = vfx_list[idx]
		var rem: float = float(v["timer"]) - dt
		v["timer"] = rem
		var prog: float = 1.0 - maxf(0.0, rem / float(v["max_timer"]))
		var node: Node3D = v["node"]
		if is_instance_valid(node) and String(v["type"]) == "ring":
			var s: float = 0.25 + prog * 0.85
			node.scale = Vector3(s, 1.0, s)
		if rem <= 0.0:
			if is_instance_valid(node):
				node.queue_free()
			vfx_list.remove_at(idx)

	if player_unit != null and is_instance_valid(player_unit):
		var sx: float = 0.0
		var sz: float = 0.0
		if shake_timer > 0.0:
			shake_timer = maxf(0.0, shake_timer - dt)
			sx = randf_range(-0.5, 0.5) * shake_intensity
			sz = randf_range(-0.5, 0.5) * shake_intensity
		var target_pos := Vector3(player_unit.position.x + sx, 21.5, player_unit.position.z + 17.5 + sz)
		battle_camera.position = battle_camera.position.lerp(target_pos, 0.16)
		battle_camera.look_at(Vector3(player_unit.position.x + sx * 0.5, 0.8, player_unit.position.z - 1.2 + sz * 0.5), Vector3.UP)

func _update_hero_ai(bot: CombatUnit, dt: float, cur_spd: float) -> bool:
	if bot.health.current_hp < bot.health.max_hp * 0.28:
		if bot.skills_comp.is_ready("regen"):
			trigger_battle_action(bot, "regen")
		var hx: float = -28.0 if bot.team == "blue" else 28.0
		var hz: float = 28.0 if bot.team == "blue" else -28.0
		var ang: float = atan2(hx - bot.position.x, hz - bot.position.z)
		bot.rotation.y = ang
		bot.position.x += sin(ang) * cur_spd * dt
		bot.position.z += cos(ang) * cur_spd * dt
		return true

	var targets: Array[Dictionary] = get_valid_targets(bot, 15.5)
	if targets.size() > 0:
		var best: CombatUnit = targets[0]["target"]
		var dist: float = float(targets[0]["dist"])
		var ang: float = atan2(best.position.x - bot.position.x, best.position.z - bot.position.z)
		bot.rotation.y = ang

		if best.is_hero and dist <= 8.5:
			if bot.skills_comp.is_ready("3") and best.health.current_hp < best.health.max_hp * 0.65:
				trigger_skill(bot, 3)
			elif bot.skills_comp.is_ready("2"):
				trigger_skill(bot, 2)
			elif bot.skills_comp.is_ready("1"):
				trigger_skill(bot, 1)

		if dist <= bot.attack_range * 0.92:
			trigger_basic_attack(bot)
			if bot.attack_range > 5.0 and dist < bot.attack_range * 0.55:
				bot.position.x -= sin(ang) * cur_spd * 0.75 * dt
				bot.position.z -= cos(ang) * cur_spd * 0.75 * dt
				return true
			return false
		else:
			bot.position.x += sin(ang) * cur_spd * dt
			bot.position.z += cos(ang) * cur_spd * dt
			return true

	var lane_wp := Vector2.ZERO
	if bot.hero_data != null:
		match bot.hero_data.lane:
			"Gold Lane":
				lane_wp = Vector2(-16.0, -16.0)
			"Exp Lane":
				lane_wp = Vector2(16.0, 16.0)
			"Jungling":
				lane_wp = Vector2(-9.0, 6.0) if bot.team == "blue" else Vector2(9.0, -6.0)
			"Roaming":
				lane_wp = Vector2(3.0, -3.0) if bot.team == "blue" else Vector2(-3.0, 3.0)

	var d_wp: float = Vector2(lane_wp.x - bot.position.x, lane_wp.y - bot.position.z).length()
	if d_wp > 3.2:
		var ang: float = atan2(lane_wp.x - bot.position.x, lane_wp.y - bot.position.z)
		bot.rotation.y = ang
		bot.position.x += sin(ang) * cur_spd * dt
		bot.position.z += cos(ang) * cur_spd * dt
		return true
	return false


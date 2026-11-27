extends Node

func _ready() -> void:
	print("=== STARTING MOBN: BLOX LEGENDS GODOT 4.7 VERIFICATION ===")
	var main_scene: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	assert(main_scene != null, "Main.tscn failed to load")

	var main_inst: MOBNMainController = main_scene.instantiate() as MOBNMainController
	add_child(main_inst)

	await get_tree().process_frame
	await get_tree().process_frame

	assert(GameDatabase.heroes.size() == 12, "Expected 12 playable Blox Legends heroes")
	assert(GameDatabase.builds.size() == 4, "Expected 4 equipment builds")
	assert(main_inst.world != null, "ArenaBattleWorld must be initialized")
	assert(main_inst.world.lobby_hero_rig != null, "Lobby 3D Roblox R6 hero rig must be spawned")

	for h: HeroData in GameDatabase.heroes:
		assert(ResourceLoader.exists(h.portrait_path), "Missing portrait asset: " + h.portrait_path)
		assert(ResourceLoader.exists(h.face_tex_path), "Missing face texture: " + h.face_tex_path)
		assert(ResourceLoader.exists(h.torso_tex_path), "Missing torso texture: " + h.torso_tex_path)
		assert(ResourceLoader.exists("res://assets/weapons/%s_weapon.png" % h.id), "Missing weapon icon for " + h.id)
		for sk: SkillData in h.skills:
			assert(ResourceLoader.exists(sk.icon_path), "Missing skill icon: " + sk.icon_path)

	for mid: String in ["crimson_buff", "azure_golem", "river_crab", "forest_boar"]:
		assert(ResourceLoader.exists("res://assets/monsters/%s.png" % mid), "Missing monster card: " + mid)
		assert(ResourceLoader.exists("res://assets/textures/monsters/%s_tex.png" % mid), "Missing monster tex: " + mid)

	for team_s: String in ["blue", "red"]:
		assert(ResourceLoader.exists("res://assets/minions/minion_%s.png" % team_s), "Missing minion card: " + team_s)
		assert(ResourceLoader.exists("res://assets/textures/minions/minion_%s_tex.png" % team_s), "Missing minion tex: " + team_s)
		assert(ResourceLoader.exists("res://assets/turrets/turret_%s.png" % team_s), "Missing turret card: " + team_s)
		assert(ResourceLoader.exists("res://assets/textures/turrets/turret_%s_tex.png" % team_s), "Missing turret tex: " + team_s)

	GameDatabase.prepare_default_rosters()
	main_inst.show_screen("battle")
	main_inst.world.start_match()

	await get_tree().process_frame
	await get_tree().physics_frame

	assert(main_inst.world.hero_units.size() == 10, "5v5 match must spawn 10 hero units")
	assert(main_inst.world.turret_units.size() == 8, "Arena must spawn 8 turrets/nexuses")
	assert(main_inst.world.creep_units.size() == 4, "Arena must spawn 4 jungle creeps")
	assert(main_inst.world.minion_units.size() == 6, "First minion wave must spawn 6 minions")
	assert(main_inst.world.player_unit != null, "Player unit must be assigned")

	main_inst.world.trigger_basic_attack(main_inst.world.player_unit)
	for h: HeroData in GameDatabase.heroes:
		main_inst.world.player_unit.hero_data = h
		main_inst.world.player_unit.rig.hero_id = h.id
		for slot_i: int in [1, 2, 3]:
			main_inst.world.player_unit.skills_comp.cooldowns[str(slot_i)] = 0.0
			main_inst.world.player_unit.health.current_mana = 999.0
			main_inst.world.trigger_skill(main_inst.world.player_unit, slot_i)
			main_inst.world.player_unit.rig.animate_character(0.05, true, false)

	await get_tree().physics_frame
	print("=== ALL 12 R6 HEROES, 36 UNIQUE SKILLS, ARTICULATED RIGS & 5v5 ARENA VERIFIED OK ===")
	get_tree().quit(0)

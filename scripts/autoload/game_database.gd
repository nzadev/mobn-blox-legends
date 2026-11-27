extends Node

var heroes: Array[HeroData] = []
var builds: Array[BuildData] = []
var bot_names: Array[String] = [
	"Frenchzko", "KENZO", "Kezzy", "merely_cat", "sel",
	"The_Bacon", "chicken_masala", "Marss", "cla_taralaro", "RizkyBlox",
	"ShadowKing99", "NoobSlayer_ID", "xX_Viper_Xx", "AetherBlox"
]

var selected_hero: HeroData = null
var selected_skin: Dictionary = {}
var selected_build: BuildData = null
var selected_lane: String = "Gold Lane"
var game_mode: String = "CLASSIC"

var coins: int = 1600
var gems: int = 0

var blue_roster: Array[Dictionary] = []
var red_roster: Array[Dictionary] = []

func _ready() -> void:
	_init_heroes()
	_init_builds()
	if heroes.size() > 0:
		selected_hero = heroes[0]
		if selected_hero.skins.size() > 0:
			selected_skin = selected_hero.skins[0]
	if builds.size() > 1:
		selected_build = builds[1]
	elif builds.size() > 0:
		selected_build = builds[0]

func get_hero_by_id(hero_id: String) -> HeroData:
	for h: HeroData in heroes:
		if h.id == hero_id:
			return h
	return heroes[0]

func _add_hero(
	p_id: String, p_name: String, p_title: String, p_role: String, p_lane: String, p_lane_key: String,
	p_price: int, p_hp: float, p_mana: float, p_atk: float, p_def: float, p_spd: float, p_range: float, p_aspd: float,
	p_skin: String, p_hair: String, p_hair_style: String, p_torso: String, p_coat: String, p_trim: String, p_pants: String,
	p_weapon: String, p_weapon_col: String, p_aura: String,
	p_passive_name: String, p_passive_desc: String,
	p_skills: Array[SkillData], p_skins: Array[Dictionary]
) -> void:
	var h := HeroData.new()
	h.id = p_id
	h.name = p_name
	h.title = p_title
	h.role = p_role
	h.lane = p_lane
	h.lane_key = p_lane_key
	h.price = p_price
	h.unlocked = true
	h.max_hp = p_hp
	h.max_mana = p_mana
	h.base_atk = p_atk
	h.base_def = p_def
	h.move_speed = p_spd
	h.attack_range = p_range
	h.attack_speed = p_aspd
	h.skin_color = p_skin
	h.hair_color = p_hair
	h.hair_style = p_hair_style
	h.torso_color = p_torso
	h.coat_color = p_coat
	h.trim_color = p_trim
	h.pants_color = p_pants
	h.weapon_type = p_weapon
	h.weapon_color = p_weapon_col
	h.aura_color = p_aura
	h.passive_name = p_passive_name
	h.passive_desc = p_passive_desc
	h.skills = p_skills
	h.skins = p_skins
	h.portrait_path = "res://assets/portraits/%s.png" % p_id
	h.face_tex_path = "res://assets/textures/faces/%s_face.png" % p_id
	h.torso_tex_path = "res://assets/textures/torsos/%s_torso.png" % p_id
	heroes.append(h)

func _init_heroes() -> void:
	heroes.clear()

	_add_hero(
		"laylul", "Laylul", "Void Marksman", "Marksman", "Gold Lane", "G",
		0, 2272.0, 480.0, 128.0, 18.0, 5.8, 9.5, 1.25,
		"#f8d2b4", "#ffcf24", "twintails", "#e8e4f0", "#d8cfe8", "#d49b27", "#1e1b2e",
		"cannon", "#6b4fa0", "#38bdf8",
		"Malefic Gun", "Basic attacks and skills deal up to 130% extra damage the farther the target is.",
		[
			SkillData.create("ATK", "Rifle Shot", "Hex Shot · Cooldown 0.8s", "[Ranged] [Physical]", "Fire a void-charged round from her cannon, dealing physical damage scaled with distance.", 0.8, 0.0, 128.0, 1.0, "basic", "#38bdf8", 9.5, "res://assets/skills/laylul_atk.png"),
			SkillData.create("1", "Speed Shot", "Malefic Bomb · Cooldown 5s · Mana 50", "[Skillshot] [Damage] [Speed Boost]", "Fires a malefic energy blast forward, dealing 280 (+95% ATK) damage and boosting movement speed & range.", 5.0, 50.0, 280.0, 0.95, "line_bolt", "#facc15", 11.5, "res://assets/skills/laylul_1.png"),
			SkillData.create("2", "Stun Blast", "Malefic Orb · Cooldown 8s · Mana 45", "[Targeted] [Area Damage] [Stun]", "Fires an energy orb that explodes on impact, dealing 240 (+75% ATK) damage and stunning enemies for 1.2s.", 8.0, 45.0, 240.0, 0.75, "stun_orb", "#a855f7", 9.5, "res://assets/skills/laylul_2.png"),
			SkillData.create("3", "Destruction Rush", "Void Laser · Cooldown 22s · Mana 100", "[Mega Laser] [Burst] [Long Range]", "Fires a massive cyan void laser beam across the battlefield, dealing 620 (+150% ATK) devastating damage to all enemies in the line.", 22.0, 100.0, 620.0, 1.5, "mega_laser", "#22d3ee", 18.0, "res://assets/skills/laylul_3.png")
		],
		[
			{"id": "default", "name": "Archer Gunner", "tag": "DEFAULT", "coat": "#d8cfe8", "hair": "#ffcf24", "trim": "#d49b27"},
			{"id": "elite", "name": "Bunny Babe", "tag": "ELITE", "coat": "#2b2d42", "hair": "#ffcf24", "trim": "#ef233c"},
			{"id": "epic", "name": "Blazing Gun", "tag": "EPIC", "coat": "#3b1c32", "hair": "#ff7eb3", "trim": "#00f5d4"},
			{"id": "legend", "name": "Twilight Waltz", "tag": "COLLECTOR", "coat": "#1e293b", "hair": "#c084fc", "trim": "#38bdf8"}
		]
	)

	_add_hero(
		"sabro", "Sabro", "Wandering Sword", "Assassin", "Jungling", "J",
		0, 2450.0, 440.0, 148.0, 24.0, 6.4, 3.4, 1.3,
		"#94a3b8", "#e2e8f0", "cyber_helm", "#1e3a8a", "#172554", "#ef4444", "#0f172a",
		"dual_blades", "#38bdf8", "#3b82f6",
		"Enemy's Bane", "Attacks reduce target physical defense and deal bonus slash damage.",
		[
			SkillData.create("ATK", "Sword Slash", "Slash · Cooldown 0.7s", "[Melee]", "Slash the enemy in front of you. While Ember Orbit is up, each slash launches a flying sword.", 0.7, 0.0, 148.0, 1.0, "basic", "#38bdf8", 3.4, "res://assets/skills/sabro_atk.png"),
			SkillData.create("1", "Orbiting Swords", "Ember Orbit · Cooldown 7s · Mana 55", "[AoE] [Orbit] [Poke]", "Releases 5 spinning cyber blades that orbit around Sabro for 4s, slicing all nearby enemies for 210 (+80% ATK) per hit.", 7.0, 55.0, 210.0, 0.8, "orbit_blades", "#38bdf8", 5.5, "res://assets/skills/sabro_1.png"),
			SkillData.create("2", "Dash Strike", "Ash Dash · Cooldown 7s · Mana 45", "[Dash] [Damage] [Slow]", "Dash toward where you aim, cutting enemies in your path for 250 (+90% ATK).", 7.0, 45.0, 250.0, 0.9, "dash_slash", "#60a5fa", 7.0, "res://assets/skills/sabro_2.png"),
			SkillData.create("3", "Triple Sweep", "Sky Execution · Cooldown 24s · Mana 100", "[Airborne] [Burst] [Lock-On]", "Leaps to an enemy hero, knocking them airborne and delivering 3 consecutive lethal slashes totaling 740 (+170% ATK) damage.", 24.0, 100.0, 740.0, 1.7, "triple_sweep", "#ef4444", 8.0, "res://assets/skills/sabro_3.png")
		],
		[
			{"id": "default", "name": "Ronin Cyborg", "tag": "DEFAULT", "coat": "#172554", "hair": "#e2e8f0", "trim": "#ef4444"},
			{"id": "elite", "name": "Golden Warrior", "tag": "ELITE", "coat": "#78350f", "hair": "#fde047", "trim": "#f59e0b"},
			{"id": "epic", "name": "Onimaru", "tag": "EPIC", "coat": "#450a0a", "hair": "#f8fafc", "trim": "#dc2626"}
		]
	)

	_add_hero(
		"yuzong", "Yu Zong", "Black Dragon", "Fighter", "Exp Lane", "E",
		0, 3150.0, 400.0, 136.0, 38.0, 5.9, 3.6, 1.1,
		"#64748b", "#1e1b4b", "horns", "#18181b", "#27272a", "#e11d48", "#09090b",
		"dragon_claws", "#f43f5e", "#e11d48",
		"Cursing Touch", "Applies Sha Residue to targets; at 5 stacks, erupts to drain enemy HP and heal Yu Zong.",
		[
			SkillData.create("ATK", "Dragon Claw", "Sha Strike · Cooldown 0.85s", "[Melee] [Lifesteal]", "Claws enemies in front, stacking Sha Residue and healing for 15% of damage dealt.", 0.85, 0.0, 136.0, 1.0, "basic", "#f43f5e", 3.6, "res://assets/skills/yuzong_atk.png"),
			SkillData.create("1", "Dragon Tail", "Blood Cloak · Cooldown 6s · Mana 40", "[AoE] [Spell Vamp]", "Infuses power into his cloak and sweeps a 360-degree razor edge, dealing 310 (+100% ATK) damage and healing.", 6.0, 40.0, 310.0, 1.0, "aoe_spin", "#e11d48", 5.2, "res://assets/skills/yuzong_1.png"),
			SkillData.create("2", "Furious Dive", "Soul Grip · Cooldown 9s · Mana 55", "[Leap] [Knockup] [Slow]", "Leaps forward and slams the ground with crimson dragon force, dealing 290 (+85% ATK) and stunning hit enemies.", 9.0, 55.0, 290.0, 0.85, "leap_slam", "#be123c", 7.2, "res://assets/skills/yuzong_2.png"),
			SkillData.create("3", "Black Dragon Form", "Dragonoid · Cooldown 28s · Mana 90", "[Transform] [Max HP] [Shockwave]", "Unleashes Black Dragon supremacy, gaining shield, movement speed, and blasting a dark dragon shockwave for 580 (+140% ATK).", 28.0, 90.0, 580.0, 1.4, "dragon_form", "#f43f5e", 7.5, "res://assets/skills/yuzong_3.png")
		],
		[
			{"id": "default", "name": "Black Fierce", "tag": "DEFAULT", "coat": "#27272a", "hair": "#1e1b4b", "trim": "#e11d48"},
			{"id": "epic", "name": "Blood Serpent", "tag": "COLLECTOR", "coat": "#4c0519", "hair": "#f8fafc", "trim": "#fb7185"}
		]
	)

	_add_hero(
		"kajee", "Kajee", "Nazar King", "Support / Fighter", "Mid Lane", "M",
		0, 2780.0, 550.0, 122.0, 30.0, 6.1, 4.5, 1.15,
		"#f59e0b", "#fef08a", "bird_crest", "#4c1d95", "#3b0764", "#eab308", "#1e1b4b",
		"whip", "#facc15", "#eab308",
		"Wrath Sanction", "Every 4s his next basic attack sends lightning whip chaining between enemies.",
		[
			SkillData.create("ATK", "Lightning Whip", "Volt Lash · Cooldown 0.8s", "[Mid-Range] [Magic]", "Cracks an electric whip dealing hybrid damage.", 0.8, 0.0, 122.0, 1.0, "basic", "#facc15", 4.5, "res://assets/skills/kajee_atk.png"),
			SkillData.create("1", "Ring of Order", "Electric Ring · Cooldown 6s · Mana 50", "[Expanding AoE] [Heal]", "Releases a ringed electric wave that expands and contracts, dealing 290 (+90% ATK) damage and healing Kajee.", 6.0, 50.0, 290.0, 0.9, "ring_pulse", "#facc15", 6.8, "res://assets/skills/kajee_1.png"),
			SkillData.create("2", "Lightning Bomb", "Thunder Dash · Cooldown 8s · Mana 55", "[Dash] [Electric Orbs]", "Dashes in the target direction while leaving 3 lightning bombs that detonate for 260 (+80% ATK) damage.", 8.0, 55.0, 260.0, 0.8, "dash_slash", "#fde047", 6.5, "res://assets/skills/kajee_2.png"),
			SkillData.create("3", "Divine Judgment", "Suppression · Cooldown 25s · Mana 100", "[Suppress] [Drag] [Burst]", "Binds and shocks the nearest enemy hero with golden chains, stunning for 1.6s and dealing 540 (+135% ATK) magic damage.", 25.0, 100.0, 540.0, 1.35, "divine_chain", "#eab308", 6.5, "res://assets/skills/kajee_3.png")
		],
		[
			{"id": "default", "name": "Nazar Sovereign", "tag": "DEFAULT", "coat": "#3b0764", "hair": "#fef08a", "trim": "#eab308"},
			{"id": "epic", "name": "Skyblocker", "tag": "EPIC", "coat": "#0f172a", "hair": "#38bdf8", "trim": "#f43f5e"}
		]
	)

	_add_hero(
		"yeen", "Yeen", "Martial Genius", "Fighter", "Jungling", "J",
		0, 2820.0, 430.0, 144.0, 28.0, 6.3, 3.3, 1.25,
		"#fbd38d", "#eab308", "spiky", "#991b1b", "#7f1d1d", "#fbbf24", "#1c1917",
		"gauntlets", "#f59e0b", "#f97316",
		"Leave It To Me", "Deals 120% increased damage when fighting isolated 1v1 duels.",
		[
			SkillData.create("ATK", "Martial Combo", "Fist Flurry · Cooldown 0.7s", "[Melee] [Physical]", "Rapid martial arts strikes infused with Lieh crimson energy.", 0.7, 0.0, 144.0, 1.0, "basic", "#f97316", 3.3, "res://assets/skills/yeen_atk.png"),
			SkillData.create("1", "Charged Punch", "Fist Smash · Cooldown 5.5s · Mana 40", "[Dash Strike] [Burst]", "Charges up speed and launches a devastating two-hit smash dealing 320 (+105% ATK) damage.", 5.5, 40.0, 320.0, 1.05, "dash_slash", "#f97316", 6.0, "res://assets/skills/yeen_1.png"),
			SkillData.create("2", "Instant Blast", "Golden Rings · Cooldown 8s · Mana 50", "[Dash] [Stun Rings]", "Dashes forward, leaving golden rings that snap back to stun enemies for 1s and deal 250 (+80% ATK) damage.", 8.0, 50.0, 250.0, 0.8, "leap_slam", "#fbbf24", 6.5, "res://assets/skills/yeen_2.png"),
			SkillData.create("3", "My Turn (Domain)", "Lieh Arena · Cooldown 26s · Mana 90", "[Domain Arena] [Frenzy]", "Pulls the enemy into Lieh's Crimson Domain Ring and unleashes a relentless barrage of punches for 690 (+160% ATK) damage.", 26.0, 90.0, 690.0, 1.6, "domain_barrage", "#dc2626", 6.5, "res://assets/skills/yeen_3.png")
		],
		[
			{"id": "default", "name": "Fist of Lieh", "tag": "DEFAULT", "coat": "#7f1d1d", "hair": "#eab308", "trim": "#fbbf24"},
			{"id": "epic", "name": "M-World Yin", "tag": "EPIC", "coat": "#1e1b4b", "hair": "#38bdf8", "trim": "#a855f7"}
		]
	)

	_add_hero(
		"kimee", "Kimee", "Jetpack Alchemist", "Marksman / Mage", "Gold Lane", "G",
		0, 2350.0, 520.0, 132.0, 20.0, 6.2, 8.8, 1.55,
		"#fde68a", "#facc15", "short_bob", "#ec4899", "#f472b6", "#fdf2f8", "#831843",
		"splat_gun", "#f43f5e", "#ec4899",
		"Chemist's Instinct", "Can move while firing chemical spray bolts rapidly.",
		[
			SkillData.create("ATK", "Chem Spray", "Rapid Spray · Cooldown 0.55s", "[Ranged] [Hybrid]", "Fires fast chemical droplets while hovering on her jetpack.", 0.55, 0.0, 132.0, 1.0, "basic", "#ec4899", 8.8, "res://assets/skills/kimee_atk.png"),
			SkillData.create("1", "Energy Transformation", "Acid Volley · Cooldown 5s · Mana 45", "[Volley] [Hybrid Damage]", "Fires a high-pressure chemical volley that explodes in a small area for 300 (+95% ATK) damage.", 5.0, 45.0, 300.0, 0.95, "line_bolt", "#ec4899", 10.5, "res://assets/skills/kimee_1.png"),
			SkillData.create("2", "Chemical Refinement", "Jet Dash · Cooldown 7.5s · Mana 50", "[Blink] [Slow Trail]", "Boosts with her jetpack while leaving a corrosive puddle that slows and damages enemies for 230 (+75% ATK).", 7.5, 50.0, 230.0, 0.75, "dash_slash", "#f472b6", 6.5, "res://assets/skills/kimee_2.png"),
			SkillData.create("3", "Maximum Charge", "Mega Rocket · Cooldown 22s · Mana 95", "[Long-Range Artillery] [AoE]", "Launches a supercharged luminescent chemical warhead that detonates on impact for 640 (+150% ATK) AoE damage.", 22.0, 95.0, 640.0, 1.5, "mega_laser", "#f43f5e", 16.0, "res://assets/skills/kimee_3.png")
		],
		[
			{"id": "default", "name": "Steam Researcher", "tag": "DEFAULT", "coat": "#f472b6", "hair": "#facc15", "trim": "#fdf2f8"},
			{"id": "epic", "name": "Astrocat", "tag": "EPIC", "coat": "#6366f1", "hair": "#f8fafc", "trim": "#22d3ee"}
		]
	)

	_add_hero(
		"minotor", "Minotor", "Son of Minos", "Tank / Support", "Roaming", "R",
		0, 3750.0, 420.0, 115.0, 48.0, 5.7, 3.6, 0.95,
		"#c2410c", "#fef3c7", "bull_horns", "#9a3412", "#7c2d12", "#fbbf24", "#431407",
		"giant_hammer", "#f59e0b", "#ea580c",
		"Rage Mode", "Dealing and taking damage builds Minotaur Rage, empowering all skills with extra knockup and defense.",
		[
			SkillData.create("ATK", "Hammer Crush", "Quake Smash · Cooldown 0.95s", "[Melee] [Tank]", "Swings his colossal warhammer, shaking the ground.", 0.95, 0.0, 115.0, 1.0, "basic", "#f59e0b", 3.6, "res://assets/skills/minotor_atk.png"),
			SkillData.create("1", "Despair Stomp", "Hammer Leap · Cooldown 6.5s · Mana 45", "[Leap] [AoE Knockup]", "Jumps to a location and slams the ground, knocking enemies airborne for 0.8s and dealing 280 (+85% ATK) damage.", 6.5, 45.0, 280.0, 0.85, "leap_slam", "#f97316", 6.5, "res://assets/skills/minotor_1.png"),
			SkillData.create("2", "Motivation Roar", "War Cry · Cooldown 8s · Mana 55", "[Team Heal] [Buff]", "Lets out a mighty bull roar that heals Minotor and nearby allies by 360 HP while boosting attack speed.", 8.0, 55.0, 360.0, 0.6, "team_heal", "#4ade80", 7.0, "res://assets/skills/minotor_2.png"),
			SkillData.create("3", "Minoan Fury", "Triple Quake · Cooldown 28s · Mana 100", "[Massive AoE] [Airborne]", "Smashes the ground 3 times in a row with volcanic shockwaves, dealing 590 (+130% ATK) and stunning all surrounding enemies for 1.5s.", 28.0, 100.0, 590.0, 1.3, "minoan_quake", "#ea580c", 7.5, "res://assets/skills/minotor_3.png")
		],
		[
			{"id": "default", "name": "Labyrinth Guardian", "tag": "DEFAULT", "coat": "#7c2d12", "hair": "#fef3c7", "trim": "#fbbf24"},
			{"id": "epic", "name": "Taurus Zodiac", "tag": "ZODIAC", "coat": "#1e3a8a", "hair": "#fde047", "trim": "#38bdf8"}
		]
	)

	_add_hero(
		"esteez", "Esteez", "Moonlight King", "Support", "Roaming", "R",
		0, 2680.0, 640.0, 108.0, 28.0, 5.9, 8.2, 1.1,
		"#fef3c7", "#f8fafc", "elf_crown", "#1e3a8a", "#1d4ed8", "#facc15", "#172554",
		"tome_scroll", "#fde047", "#4ade80",
		"Scripture of the Moon Elf", "Periodically charges the Code of Moon Elves, empowering basic attacks to bounce and slow.",
		[
			SkillData.create("ATK", "Moonlight Bolt", "Lunar Ray · Cooldown 0.8s", "[Ranged] [Magic]", "Fires sacred moonlight energy from his royal scroll.", 0.8, 0.0, 108.0, 1.0, "basic", "#38bdf8", 8.2, "res://assets/skills/esteez_atk.png"),
			SkillData.create("1", "Moonlight Immersion", "Tether Heal · Cooldown 6s · Mana 55", "[Heal Link] [Support]", "Links with the lowest-HP ally and himself, restoring 440 (+110% ATK) HP immediately and granting regen.", 6.0, 55.0, 440.0, 1.1, "team_heal", "#4ade80", 8.5, "res://assets/skills/esteez_1.png"),
			SkillData.create("2", "Domain of Moon Goddess", "Lunar Ring · Cooldown 8.5s · Mana 65", "[AoE Slow] [Magic Damage]", "Drops a flood of moonlight upon the target area, dealing 280 (+85% ATK) damage and slowing enemies by 60%.", 8.5, 65.0, 280.0, 0.85, "stun_orb", "#38bdf8", 9.0, "res://assets/skills/esteez_2.png"),
			SkillData.create("3", "Blessing of Moon Goddess", "Sanctuary · Cooldown 26s · Mana 110", "[Mass Team Heal] [Shield]", "Channels the Moon Goddess for 5s, healing all nearby allies for 720 HP.", 26.0, 110.0, 720.0, 1.4, "team_heal", "#22c55e", 9.5, "res://assets/skills/esteez_3.png")
		],
		[
			{"id": "default", "name": "Moon Elf King", "tag": "DEFAULT", "coat": "#1d4ed8", "hair": "#f8fafc", "trim": "#facc15"},
			{"id": "epic", "name": "Galaxy Dominator", "tag": "M3 CHAMP", "coat": "#0f172a", "hair": "#38bdf8", "trim": "#f59e0b"}
		]
	)

	_add_hero(
		"masteryee", "Master Yee", "Wuju Blademaster", "Assassin / Fighter", "Jungling", "J",
		1200, 2520.0, 420.0, 152.0, 22.0, 6.5, 3.3, 1.45,
		"#fcd34d", "#1e293b", "goggles_helm", "#334155", "#1e293b", "#84cc16", "#0f172a",
		"katana", "#a3e635", "#84cc16",
		"Double Strike", "Every 3rd basic attack strikes twice in rapid succession.",
		[
			SkillData.create("ATK", "Wuju Slash", "Swift Cut · Cooldown 0.65s", "[Melee] [Crit]", "High-speed katana slashes that shred targets.", 0.65, 0.0, 152.0, 1.0, "basic", "#a3e635", 3.3, "res://assets/skills/masteryee_atk.png"),
			SkillData.create("1", "Alpha Strike", "Untargetable Slash · Cooldown 7s · Mana 50", "[Blink] [Multi-Hit]", "Vanishes in a blur of emerald light, striking nearby enemies for 310 (+100% ATK) physical damage.", 7.0, 50.0, 310.0, 1.0, "dash_slash", "#84cc16", 7.0, "res://assets/skills/masteryee_1.png"),
			SkillData.create("2", "Meditate Blade", "True Style · Cooldown 8s · Mana 45", "[Heal] [True Damage]", "Channels Wuju focus to restore 320 HP and empower his blade.", 8.0, 45.0, 320.0, 0.8, "team_heal", "#a3e635", 5.0, "res://assets/skills/masteryee_2.png"),
			SkillData.create("3", "Highlander", "Supreme Speed · Cooldown 24s · Mana 90", "[Hyper Speed] [Execution]", "Enters Highlander overdrive, dashing through targets with a lethal barrage for 680 (+165% ATK) damage.", 24.0, 90.0, 680.0, 1.65, "triple_sweep", "#65a30d", 8.0, "res://assets/skills/masteryee_3.png")
		],
		[
			{"id": "default", "name": "Wuju Master", "tag": "DEFAULT", "coat": "#1e293b", "hair": "#1e293b", "trim": "#84cc16"},
			{"id": "epic", "name": "Project Yi", "tag": "EPIC", "coat": "#f97316", "hair": "#f8fafc", "trim": "#38bdf8"}
		]
	)

	_add_hero(
		"ketootoo", "Ketootoo", "Arcane Trickster", "Marksman / Mage", "Gold Lane", "G",
		1200, 2390.0, 520.0, 134.0, 19.0, 6.1, 9.0, 1.3,
		"#fed7aa", "#451a03", "cap_hood", "#374151", "#1f2937", "#38bdf8", "#111827",
		"dual_pistols", "#60a5fa", "#60a5fa",
		"Twin Holster", "Fires twin arcane pistols that ricochet to nearby minions.",
		[
			SkillData.create("ATK", "Twin Shot", "Dual Bolt · Cooldown 0.75s", "[Ranged] [Physical]", "Fires twin hex bullets at the target.", 0.75, 0.0, 134.0, 1.0, "basic", "#60a5fa", 9.0, "res://assets/skills/ketootoo_atk.png"),
			SkillData.create("1", "Piercing Round", "Rail Shot · Cooldown 5.5s · Mana 45", "[Line] [Armor Break]", "Fires a high-velocity round that pierces targets for 290 (+95% ATK) damage.", 5.5, 45.0, 290.0, 0.95, "line_bolt", "#38bdf8", 11.0, "res://assets/skills/ketootoo_1.png"),
			SkillData.create("2", "Tactical Roll", "Evasion · Cooldown 7s · Mana 40", "[Dash] [Stun Shot]", "Rolls in the target direction and fires a concussive round that stuns for 0.9s.", 7.0, 40.0, 230.0, 0.75, "stun_orb", "#60a5fa", 8.5, "res://assets/skills/ketootoo_2.png"),
			SkillData.create("3", "Bullet Storm", "Full Barrage · Cooldown 23s · Mana 95", "[Cone Barrage] [Burst]", "Unleashes an energy cannon barrage forward, dealing 630 (+150% ATK) damage.", 23.0, 95.0, 630.0, 1.5, "mega_laser", "#3b82f6", 15.0, "res://assets/skills/ketootoo_3.png")
		],
		[
			{"id": "default", "name": "Street Gunner", "tag": "DEFAULT", "coat": "#1f2937", "hair": "#451a03", "trim": "#38bdf8"}
		]
	)

	_add_hero(
		"alucardox", "Alucardox", "Demon Hunter", "Fighter / Assassin", "Exp Lane", "E",
		1500, 2890.0, 0.0, 146.0, 30.0, 6.2, 3.5, 1.2,
		"#fde68a", "#fef08a", "spiky", "#1e3a8a", "#991b1b", "#fbbf24", "#172554",
		"greatsword", "#60a5fa", "#3b82f6",
		"Pursuit", "After casting a skill, his next basic attack dashes to the target and deals 1.4x damage with massive lifesteal.",
		[
			SkillData.create("ATK", "Demon Cleave", "Heavy Blade · Cooldown 0.8s", "[Melee] [Lifesteal]", "Cleaves enemies with his rune greatsword, draining HP.", 0.8, 0.0, 146.0, 1.0, "basic", "#60a5fa", 3.5, "res://assets/skills/alucardox_atk.png"),
			SkillData.create("1", "Groundsplitter", "Leap Cleave · Cooldown 6s · No Mana", "[Leap] [Slow]", "Leaps forward and slams his greatsword down for 300 (+100% ATK) physical damage.", 6.0, 0.0, 300.0, 1.0, "leap_slam", "#3b82f6", 7.0, "res://assets/skills/alucardox_1.png"),
			SkillData.create("2", "Whirling Smash", "Crimson Spin · Cooldown 5s · No Mana", "[AoE] [Lifesteal]", "Hurricanes his greatsword around himself, dealing 320 (+105% ATK) damage and healing.", 5.0, 0.0, 320.0, 1.05, "aoe_spin", "#60a5fa", 5.0, "res://assets/skills/alucardox_2.png"),
			SkillData.create("3", "Fission Wave", "Demon Slash · Cooldown 22s · No Mana", "[Wave Burst] [Drain]", "Absorbs enemy energy for huge lifesteal and fires a gigantic wave of sword energy for 660 (+155% ATK) damage.", 22.0, 0.0, 660.0, 1.55, "mega_laser", "#2563eb", 13.0, "res://assets/skills/alucardox_3.png")
		],
		[
			{"id": "default", "name": "Lone Hero", "tag": "DEFAULT", "coat": "#991b1b", "hair": "#fef08a", "trim": "#fbbf24"},
			{"id": "legend", "name": "Obsidian Blade", "tag": "LEGEND", "coat": "#09090b", "hair": "#e2e8f0", "trim": "#ef4444"}
		]
	)

	_add_hero(
		"gusionox", "Gusionox", "Holy Blade", "Assassin / Mage", "Mid Lane", "M",
		1600, 2480.0, 500.0, 145.0, 22.0, 6.4, 4.0, 1.3,
		"#fed7aa", "#78350f", "spiky", "#f8fafc", "#1e3a8a", "#38bdf8", "#0f172a",
		"dual_blades", "#22d3ee", "#22d3ee",
		"Dagger Specialist", "Each spell cast adds a rune to his dagger; stacking 3 runes heals him and deals bonus target missing HP damage.",
		[
			SkillData.create("ATK", "Dagger Strike", "Rune Slash · Cooldown 0.7s", "[Melee] [Magic]", "Slashes rapidly with glowing magic daggers.", 0.7, 0.0, 145.0, 1.0, "basic", "#22d3ee", 4.0, "res://assets/skills/gusionox_atk.png"),
			SkillData.create("1", "Sword Spike", "Mark & Blink · Cooldown 6s · Mana 45", "[Dagger Throw] [Teleport]", "Throws a dagger and teleports behind the hit target, dealing 290 (+95% ATK) magic damage.", 6.0, 45.0, 290.0, 0.95, "dash_slash", "#22d3ee", 7.5, "res://assets/skills/gusionox_1.png"),
			SkillData.create("2", "Shadowblade Slaughter", "5-Dagger Fan · Cooldown 7s · Mana 55", "[Fan Volley] [Recall Blades]", "Throws 5 glowing daggers forward and recalls them, slicing enemies for 350 (+115% ATK) magic damage.", 7.0, 55.0, 350.0, 1.15, "orbit_blades", "#38bdf8", 6.5, "res://assets/skills/gusionox_2.png"),
			SkillData.create("3", "Incandescence", "Combo Reset · Cooldown 20s · Mana 90", "[Blink] [10-Dagger Burst]", "Dashes to a location, resets his daggers, and unleashes a 10-blade storm for 710 (+165% ATK) magic damage.", 20.0, 90.0, 710.0, 1.65, "triple_sweep", "#06b6d4", 8.5, "res://assets/skills/gusionox_3.png")
		],
		[
			{"id": "default", "name": "Moonlight Sonata", "tag": "DEFAULT", "coat": "#1e3a8a", "hair": "#78350f", "trim": "#38bdf8"},
			{"id": "legend", "name": "Cosmic Gleam", "tag": "LEGEND", "coat": "#312e81", "hair": "#e0e7ff", "trim": "#c084fc"}
		]
	)

func _init_builds() -> void:
	builds.clear()

	var b1 := BuildData.new()
	b1.id = "crit"
	b1.name = "Crit Build"
	b1.cost = 11270
	b1.spell_id = "flicker"
	b1.spell_name = "Flicker"
	b1.spell_sub = "Mobility"
	b1.spell_cd = 30.0
	b1.spell_color = "#38bdf8"
	b1.spell_icon = "res://assets/spells/spell_flicker.png"
	b1.bonus_atk = 45.0
	b1.bonus_crit = 0.35
	b1.bonus_atk_spd = 0.25
	b1.bonus_hp = 200.0
	b1.bonus_spd = 0.4
	b1.items = [
		{"name": "Swift Boots", "color": "#3b82f6", "icon": "res://assets/items/item_boots.png"},
		{"name": "Windtalker", "color": "#a855f7", "icon": "res://assets/items/item_dual_swords.png"},
		{"name": "Berserker Fury", "color": "#dc2626", "icon": "res://assets/items/item_axe.png"},
		{"name": "Haas Claws", "color": "#e11d48", "icon": "res://assets/items/item_claw.png"},
		{"name": "Malefic Roar", "color": "#f59e0b", "icon": "res://assets/items/item_cannon.png"},
		{"name": "Blade of Despair", "color": "#10b981", "icon": "res://assets/items/item_emerald_blade.png"}
	]
	builds.append(b1)

	var b2 := BuildData.new()
	b2.id = "atkspd"
	b2.name = "Attack Speed Build"
	b2.cost = 10740
	b2.spell_id = "flicker"
	b2.spell_name = "Flicker"
	b2.spell_sub = "Mobility"
	b2.spell_cd = 30.0
	b2.spell_color = "#38bdf8"
	b2.spell_icon = "res://assets/spells/spell_flicker.png"
	b2.bonus_atk = 35.0
	b2.bonus_crit = 0.15
	b2.bonus_atk_spd = 0.55
	b2.bonus_hp = 300.0
	b2.bonus_spd = 0.6
	b2.items = [
		{"name": "Swift Boots", "color": "#3b82f6", "icon": "res://assets/items/item_boots.png"},
		{"name": "Corrosion Scythe", "color": "#22c55e", "icon": "res://assets/items/item_scythe.png"},
		{"name": "Demon Hunter Sword", "color": "#6366f1", "icon": "res://assets/items/item_dual_swords.png"},
		{"name": "Golden Staff", "color": "#eab308", "icon": "res://assets/items/item_staff.png"},
		{"name": "Wind of Nature", "color": "#14b8a6", "icon": "res://assets/items/item_emerald_blade.png"},
		{"name": "Malefic Gun", "color": "#a855f7", "icon": "res://assets/items/item_cannon.png"}
	]
	builds.append(b2)

	var b3 := BuildData.new()
	b3.id = "sustain"
	b3.name = "Tank / Sustain Build"
	b3.cost = 11790
	b3.spell_id = "vengeance"
	b3.spell_name = "Vengeance"
	b3.spell_sub = "Defense"
	b3.spell_cd = 28.0
	b3.spell_color = "#a855f7"
	b3.spell_icon = "res://assets/spells/spell_vengeance.png"
	b3.bonus_atk = 25.0
	b3.bonus_crit = 0.1
	b3.bonus_atk_spd = 0.15
	b3.bonus_hp = 950.0
	b3.bonus_spd = 0.3
	b3.items = [
		{"name": "Tough Boots", "color": "#0ea5e9", "icon": "res://assets/items/item_boots.png"},
		{"name": "War Axe", "color": "#ef4444", "icon": "res://assets/items/item_axe.png"},
		{"name": "Brute Force Plate", "color": "#f97316", "icon": "res://assets/items/item_armor.png"},
		{"name": "Oracle", "color": "#22d3ee", "icon": "res://assets/items/item_shield.png"},
		{"name": "Queen Wings", "color": "#e11d48", "icon": "res://assets/items/item_wings.png"},
		{"name": "Immortality", "color": "#facc15", "icon": "res://assets/items/item_staff.png"}
	]
	builds.append(b3)

	var b4 := BuildData.new()
	b4.id = "recommended"
	b4.name = "Recommended Pro"
	b4.cost = 11270
	b4.spell_id = "execute"
	b4.spell_name = "Execute"
	b4.spell_sub = "Offense"
	b4.spell_cd = 25.0
	b4.spell_color = "#f43f5e"
	b4.spell_icon = "res://assets/spells/spell_execute.png"
	b4.bonus_atk = 55.0
	b4.bonus_crit = 0.25
	b4.bonus_atk_spd = 0.3
	b4.bonus_hp = 350.0
	b4.bonus_spd = 0.5
	b4.items = [
		{"name": "Rapid Boots", "color": "#2563eb", "icon": "res://assets/items/item_boots.png"},
		{"name": "Hunter Strike", "color": "#9333ea", "icon": "res://assets/items/item_dual_swords.png"},
		{"name": "Endless Battle", "color": "#dc2626", "icon": "res://assets/items/item_axe.png"},
		{"name": "Malefic Roar", "color": "#f59e0b", "icon": "res://assets/items/item_cannon.png"},
		{"name": "Sea Halberd", "color": "#06b6d4", "icon": "res://assets/items/item_scythe.png"},
		{"name": "Blade of Despair", "color": "#10b981", "icon": "res://assets/items/item_emerald_blade.png"}
	]
	builds.append(b4)

func prepare_default_rosters() -> void:
	blue_roster.clear()
	red_roster.clear()

	var used_ids: Dictionary = {selected_hero.id: true}
	blue_roster.append({
		"hero": selected_hero,
		"player_name": "You (Warrior III)",
		"lane": selected_lane,
		"is_player": true
	})

	var blue_defaults: Array[String] = ["yeen", "kajee", "yuzong", "esteez", "minotor"]
	var red_defaults: Array[String] = ["sabro", "kimee", "alucardox", "gusionox", "masteryee", "ketootoo"]
	var lanes: Array[String] = ["Jungling", "Mid Lane", "Exp Lane", "Roaming", "Gold Lane"]

	var b_idx: int = 0
	for hid: String in blue_defaults:
		if blue_roster.size() >= 5:
			break
		if not used_ids.has(hid):
			used_ids[hid] = true
			var h: HeroData = get_hero_by_id(hid)
			blue_roster.append({
				"hero": h,
				"player_name": bot_names[b_idx % bot_names.size()],
				"lane": lanes[blue_roster.size() % lanes.size()],
				"is_player": false
			})
			b_idx += 1

	for hid: String in red_defaults:
		if red_roster.size() >= 5:
			break
		var h: HeroData = get_hero_by_id(hid)
		red_roster.append({
			"hero": h,
			"player_name": bot_names[(b_idx + 4) % bot_names.size()],
			"lane": lanes[red_roster.size() % lanes.size()],
			"is_player": false
		})
		b_idx += 1

